// AOT で convertlib の decode だけが遅くなる原因を切り分けるためのプローブ。
//
// 検証したい仮説:
//   1. decode の入力が `String.codeUnits`（遅延ビュー `CodeUnits`）であること
//      が原因で、要素アクセスが 2 段の仮想呼び出しになっている
//   2. hex encode の劣化は変換ループ側か、`String.fromCharCodes` 側か
//   3. リンクするクラスが増えると AOT の脱仮想化が失敗する（TFA 要因）
//
// 実行（variant ごとに必ずプロセスとバイナリを分けること）:
//   fvm dart run -Dvariant=decode/uint8list benchmark/probe_aot_gap.dart
//   fvm dart compile exe -Dvariant=decode/uint8list benchmark/probe_aot_gap.dart \
//       -o build/probe_decode_uint8list
//
// variant は実行時引数ではなく `String.fromEnvironment` の定数で切り替える。
// 実行時引数にすると、
//   - JIT: 1 プロセスで複数 variant を測った場合、同じ
//     `_Base16Decoder.convert` に複数の List 実装が渡ってインラインキャッシュ
//     がポリモーフィックになる（実測で 4 KiB が 10.5µs → 14.2µs に劣化した）
//   - AOT: プロセスを分けても 1 つのバイナリに全 variant が残るため、TFA から
//     見た `convert` の引数は常に 3 クラス。脱仮想化の有無を比較できない
// という二重の汚染が起きる。定数にすればビルド時に他の variant が落ちる。
//
// `-Dfat=true` を付けると dart:convert / package:convert / package:base32 の
// 変換も到達可能になり、List<int> と String の実装クラスが増える。false の
// ときは定数畳み込みでツリーシェイクされる。

import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:base32/base32.dart' as b32;
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:convert/convert.dart' as pkg_convert;
import 'package:convertlib/convertlib.dart' as cl;

// umbrella export ではなく base16 だけを深く import した場合の比較用。
import 'package:convertlib/src/base16.dart' as cl16;
import 'package:convertlib/src/codecs/base16.dart' as cl16c;

import 'vendor/base16.dart' as vendor;
import 'vendor/base16_codec.dart' as vendor_codec;

const bool kFat = bool.fromEnvironment('fat');

const int kWarmupMillis = 100;
const int kMeasureMillis = 500;

Object? blackhole;

double measure(Object? Function() body) {
  void run() {
    blackhole = body();
  }

  BenchmarkBase.measureFor(run, kWarmupMillis);
  return BenchmarkBase.measureFor(run, kMeasureMillis);
}

Uint8List randomBytes(int length, {int seed = 42}) {
  var state = seed;
  final out = Uint8List(length);
  for (var i = 0; i < length; i++) {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF;
    out[i] = (state >>> 16) & 0xFF;
  }
  return out;
}

/// `-Dfat=true` のときだけ到達可能になる。他パッケージの変換をリンクさせ、
/// `List<int>` / `String` の実装クラスを TFA から見えるようにするためのもの。
void touchOtherCodecs(Uint8List bytes) {
  if (!kFat) return;
  blackhole = dc.base64.decode(dc.base64.encode(bytes));
  blackhole = pkg_convert.hex.decode(pkg_convert.hex.encode(bytes));
  blackhole = b32.base32.decode(b32.base32.encode(bytes));
  blackhole = dc.utf8.decode(dc.utf8.encode('probe'));
}

// ---------------------------------------------------------------------------
// 実験 4: convertlib の decode ループをそのまま写し、受け手の静的型だけを
// 変えた 3 版。ロジックは同一なので、差が出れば原因は型の側にある。
// ---------------------------------------------------------------------------

const int _zero = 0x30;
const int _bigA = 0x41;
const int _smallA = 0x61;

@pragma('vm:prefer-inline')
int _decListInt(List<int> src, int p) {
  int x = src[p] & 0xFF;
  if (x >= _smallA) {
    x -= _smallA - 10;
  } else if (x >= _bigA) {
    x -= _bigA - 10;
  } else {
    x -= _zero;
  }
  if (x < 0 || x > 15) {
    throw FormatException('Invalid character at $p');
  }
  return x;
}

@pragma('vm:prefer-inline')
int _decUint8(Uint8List src, int p) {
  int x = src[p] & 0xFF;
  if (x >= _smallA) {
    x -= _smallA - 10;
  } else if (x >= _bigA) {
    x -= _bigA - 10;
  } else {
    x -= _zero;
  }
  if (x < 0 || x > 15) {
    throw FormatException('Invalid character at $p');
  }
  return x;
}

@pragma('vm:prefer-inline')
int _decUint8NoThrow(Uint8List src, int p) {
  int x = src[p] & 0xFF;
  if (x >= _smallA) {
    x -= _smallA - 10;
  } else if (x >= _bigA) {
    x -= _bigA - 10;
  } else {
    x -= _zero;
  }
  return x & 0xF;
}

/// [localDecodeListInt] と同一だが、インライン化を禁止したもの。
@pragma('vm:never-inline')
Uint8List localDecodeNeverInline(List<int> encoded) {
  int p, n;
  n = encoded.length;
  p = (n >>> 1) + (n & 1);
  var out = Uint8List(p);
  for (p--; n >= 2; n -= 2, p--) {
    out[p] = _decListInt(encoded, n - 1) ^ (_decListInt(encoded, n - 2) << 4);
  }
  if (n == 1) {
    out[p] = _decListInt(encoded, 0);
  }
  return out;
}

/// 受け手が `List<int>`（convertlib と同じ）。
Uint8List localDecodeListInt(List<int> encoded) {
  int p, n;
  n = encoded.length;
  p = (n >>> 1) + (n & 1);
  var out = Uint8List(p);
  for (p--; n >= 2; n -= 2, p--) {
    out[p] = _decListInt(encoded, n - 1) ^ (_decListInt(encoded, n - 2) << 4);
  }
  if (n == 1) {
    out[p] = _decListInt(encoded, 0);
  }
  return out;
}

/// 受け手が `Uint8List`。ロジックは [localDecodeListInt] と同一。
Uint8List localDecodeUint8(Uint8List encoded) {
  int p, n;
  n = encoded.length;
  p = (n >>> 1) + (n & 1);
  var out = Uint8List(p);
  for (p--; n >= 2; n -= 2, p--) {
    out[p] = _decUint8(encoded, n - 1) ^ (_decUint8(encoded, n - 2) << 4);
  }
  if (n == 1) {
    out[p] = _decUint8(encoded, 0);
  }
  return out;
}

/// 受け手が `Uint8List` で、例外パスも持たない版。
Uint8List localDecodeUint8NoThrow(Uint8List encoded) {
  int p, n;
  n = encoded.length;
  p = (n >>> 1) + (n & 1);
  var out = Uint8List(p);
  for (p--; n >= 2; n -= 2, p--) {
    out[p] =
        _decUint8NoThrow(encoded, n - 1) ^ (_decUint8NoThrow(encoded, n - 2) << 4);
  }
  if (n == 1) {
    out[p] = _decUint8NoThrow(encoded, 0);
  }
  return out;
}

// ---------------------------------------------------------------------------
// 実験 5: 同じループを「仮想呼び出しの向こう側」に置く。convertlib は
// `codec.decoder.convert(...)` という Converter 経由の呼び出しなので、それを
// 再現する。実装を 2 つ用意し、両方を実行時に生成した List に入れることで
// 脱仮想化できないようにする。
// ---------------------------------------------------------------------------

abstract class LocalDecoder {
  const LocalDecoder();
  Uint8List convert(List<int> encoded);
}

class LocalHexDecoder extends LocalDecoder {
  const LocalHexDecoder();

  @override
  Uint8List convert(List<int> encoded) => localDecodeListInt(encoded);
}

class LocalNoopDecoder extends LocalDecoder {
  const LocalNoopDecoder();

  @override
  Uint8List convert(List<int> encoded) => Uint8List(0);
}

// ---------------------------------------------------------------------------
// 実験 6: convertlib の継承構造をそのまま再現する。dart:convert の
// `Converter<Iterable<int>, Iterable<int>>` を継承し、covariant で
// `List<int>` に絞った override を挟む。ループ本体は実験 4 と同一。
// ---------------------------------------------------------------------------

abstract class LocalBitDecoder extends dc.Converter<Iterable<int>, Iterable<int>> {
  const LocalBitDecoder();

  @override
  Uint8List convert(covariant Iterable<int> input);
}

abstract class LocalByteDecoder extends LocalBitDecoder {
  const LocalByteDecoder();

  @override
  Uint8List convert(covariant List<int> encoded);
}

class LocalConverterDecoder extends LocalByteDecoder {
  const LocalConverterDecoder();

  @override
  Uint8List convert(List<int> encoded) {
    int p, n;
    n = encoded.length;
    p = (n >>> 1) + (n & 1);
    var out = Uint8List(p);
    for (p--; n >= 2; n -= 2, p--) {
      out[p] = _decListInt(encoded, n - 1) ^ (_decListInt(encoded, n - 2) << 4);
    }
    if (n == 1) {
      out[p] = _decListInt(encoded, 0);
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// 実験 7: convertlib の継承チェーン（BitConverter → BitDecoder → ByteDecoder
// → _Base16Decoder）を丸ごと複製する。BitDecoder は Iterable を回す汎用の
// 具象 convert を持ち、_Base16Decoder がそれを上書きしている。
// `-Dnoengine=true` でその具象実装を abstract に落とし、差分を見る。
// ---------------------------------------------------------------------------

const bool kNoEngine = bool.fromEnvironment('noengine');

abstract class ChainConverter extends dc.Converter<Iterable<int>, Iterable<int>> {
  const ChainConverter();
  int get source;
  int get target;
  @override
  Iterable<int> convert(covariant Iterable<int> input);
}

abstract class ChainBitDecoder extends ChainConverter {
  const ChainBitDecoder();

  // convertlib の BitDecoder.convert と同じ汎用エンジン。
  @override
  List<int> convert(covariant List<int> encoded) {
    if (kNoEngine) throw UnimplementedError();
    final sb = source;
    final tb = target;
    if (sb < 2 || sb > 64) {
      throw ArgumentError.value(source, 'source', 'should be between 2 to 64');
    }
    if (tb < 2 || tb > 64) {
      throw ArgumentError.value(target, 'target', 'should be between 2 to 64');
    }
    int p, s, t, l, n;
    l = encoded.length * sb;
    var out = Uint8List(l ~/ tb);
    p = n = t = l = 0;
    s = 1 << (sb - 1);
    s = s ^ (s - 1);
    for (final x in encoded) {
      if (x < 0 || x > s) break;
      p = (p << sb) ^ x;
      t = (t << sb) ^ s;
      n += sb;
      while (n >= tb) {
        n -= tb;
        out[l++] = p >>> n;
        t >>>= tb;
        p &= t;
      }
    }
    if (p > 0) {
      throw FormatException('Invalid length or non-zero trailing bits');
    }
    if (l < out.length) {
      return out.sublist(0, l);
    }
    return out;
  }
}

abstract class ChainByteDecoder extends ChainBitDecoder {
  final int bits;
  const ChainByteDecoder({required this.bits});

  @override
  int get source => bits;

  @override
  final int target = 8;

  @override
  Uint8List convert(covariant List<int> encoded);
}

class ChainHexDecoder extends ChainByteDecoder {
  const ChainHexDecoder() : super(bits: 4);

  @override
  Uint8List convert(List<int> encoded) {
    int p, n;
    n = encoded.length;
    p = (n >>> 1) + (n & 1);
    var out = Uint8List(p);
    for (p--; n >= 2; n -= 2, p--) {
      out[p] = _decListInt(encoded, n - 1) ^ (_decListInt(encoded, n - 2) << 4);
    }
    if (n == 1) {
      out[p] = _decListInt(encoded, 0);
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// 実験 8: convertlib と同じく、要素の取り出しを無名 extension のメソッドに
// する。ロジックは _decListInt と 1 文字も変わらない。
// ---------------------------------------------------------------------------

extension on List<int> {
  @pragma('vm:prefer-inline')
  int dec(int p) {
    int x = this[p] & 0xFF;
    if (x >= _smallA) {
      x -= _smallA - 10;
    } else if (x >= _bigA) {
      x -= _bigA - 10;
    } else {
      x -= _zero;
    }
    if (x < 0 || x > 15) {
      throw FormatException('Invalid character at $p');
    }
    return x;
  }
}

Uint8List localDecodeExtension(List<int> encoded) {
  int p, n;
  n = encoded.length;
  p = (n >>> 1) + (n & 1);
  var out = Uint8List(p);
  for (p--; n >= 2; n -= 2, p--) {
    out[p] = encoded.dec(n - 1) ^ (encoded.dec(n - 2) << 4);
  }
  if (n == 1) {
    out[p] = encoded.dec(0);
  }
  return out;
}

class Row {
  Row(this.group, this.label, this.microsPerOp, this.payloadBytes);

  final String group;
  final String label;
  final double microsPerOp;
  final int payloadBytes;

  double get megabytesPerSecond => payloadBytes / microsPerOp;
}

/// 計測する variant。ビルド時に `-Dvariant=...` で 1 つだけ選ぶ。
const String kVariant = String.fromEnvironment('variant');

const List<String> kVariants = [
  'decode/fromHex-string', // 現状の API: String.codeUnits 経由
  'decode/codeunits-view', // 同上（トップレベル関数の分を除いた素の呼び出し）
  'decode/uint8list', // 実体化した Uint8List を渡す
  'decode/growable-list', // 実体化した _GrowableList を渡す
  'encode/toHex', // 変換ループ + String.fromCharCodes
  'encode/toHexBytes', // 変換ループのみ
  'encode/fromCharCodes', // String 生成のみ
  'local/listint', // 同一ロジック・受け手が List<int>
  'local/uint8list', // 同一ロジック・受け手が Uint8List
  'local/uint8list-nothrow', // 同上・例外パスなし
  'local/virtual', // 同一ロジックを仮想呼び出しの向こうに置く
  'local/never-inline', // 同一ロジックをインライン化禁止にする
  'local/converter', // convertlib と同じ Converter + covariant の構造
  'local/fullchain', // convertlib の継承チェーンを丸ごと複製
  'local/fullchain-noengine', // 同上から親の具象 convert を取り除いたもの
  'local/extension', // 同一ロジックを extension メソッド経由で書く
  'decode/no-codeunits', // 入力を toHexBytes で作り CodeUnits を一切生成しない
  'local/no-codeunits', // 同上の入力を複製版に渡す
  'vendor/decode', // convertlib のソースをそのままエントリ側に置いた版
  'ab/both', // package 版と vendor 版を同一バイナリ・同一プロセスで比較
  'deep/base16', // umbrella ではなく base16 だけを深く import した版
];

void main(List<String> args) {
  if (!kVariants.contains(kVariant)) {
    print('usage: compile or run with -Dvariant=<variant>');
    for (final v in kVariants) {
      print('  $v');
    }
    return;
  }
  final rows = <Row>[];

  for (final size in const [256, 4096, 65536]) {
    final bytes = randomBytes(size);
    final label = size >= 1024 ? '${size ~/ 1024} KiB' : '$size B';
    touchOtherCodecs(bytes);

    final text = cl.toHex(bytes);
    final decoder = cl.Base16Codec.lower.decoder;

    final double micros;
    // 定数比較なので、選ばれなかった枝は AOT のツリーシェイクで消える。
    if (kVariant == 'decode/fromHex-string') {
      // ---- 実験 1: decode の入力の持ち方だけを変える ---------------------
      micros = measure(() => cl.fromHex(text));
    } else if (kVariant == 'decode/codeunits-view') {
      final view = text.codeUnits; // 遅延ビュー（CodeUnits）
      micros = measure(() => decoder.convert(view));
    } else if (kVariant == 'decode/uint8list') {
      final materialized = Uint8List.fromList(text.codeUnits);
      micros = measure(() => decoder.convert(materialized));
    } else if (kVariant == 'decode/growable-list') {
      final growable = List<int>.from(text.codeUnits);
      micros = measure(() => decoder.convert(growable));
    } else if (kVariant == 'encode/toHex') {
      // ---- 実験 2: hex encode の劣化は変換ループか String 生成か ---------
      micros = measure(() => cl.toHex(bytes));
    } else if (kVariant == 'encode/toHexBytes') {
      micros = measure(() => cl.toHexBytes(bytes));
    } else if (kVariant == 'encode/fromCharCodes') {
      final encodedBytes = cl.toHexBytes(bytes);
      micros = measure(() => String.fromCharCodes(encodedBytes));
    } else if (kVariant == 'local/listint') {
      // ---- 実験 4: 受け手の静的型だけを変えた同一ロジック ---------------
      final src = Uint8List.fromList(text.codeUnits);
      micros = measure(() => localDecodeListInt(src));
    } else if (kVariant == 'local/uint8list') {
      final src = Uint8List.fromList(text.codeUnits);
      micros = measure(() => localDecodeUint8(src));
    } else if (kVariant == 'local/uint8list-nothrow') {
      final src = Uint8List.fromList(text.codeUnits);
      micros = measure(() => localDecodeUint8NoThrow(src));
    } else if (kVariant == 'local/never-inline') {
      final src = Uint8List.fromList(text.codeUnits);
      micros = measure(() => localDecodeNeverInline(src));
    } else if (kVariant == 'local/converter') {
      final src = Uint8List.fromList(text.codeUnits);
      const LocalByteDecoder dec = LocalConverterDecoder();
      micros = measure(() => dec.convert(src));
    } else if (kVariant == 'local/fullchain' ||
        kVariant == 'local/fullchain-noengine') {
      final src = Uint8List.fromList(text.codeUnits);
      const ChainByteDecoder dec = ChainHexDecoder();
      micros = measure(() => dec.convert(src));
    } else if (kVariant == 'deep/base16') {
      // 実験 12: convertlib.dart（全 codec を export）ではなく base16 だけを
      // import する。ByteDecoder の具象サブクラスが 1 つだけになる。
      final src = cl16.toHexBytes(bytes);
      final ddec = cl16c.Base16Codec.lower.decoder;
      micros = measure(() => ddec.convert(src));
    } else if (kVariant == 'ab/both') {
      // 実験 11: 同じバイナリ・同じプロセスで package 版と vendor 版を測る
      final src = cl.toHexBytes(bytes);
      final vsrc = vendor.toHexBytes(bytes);
      final vdec = vendor_codec.Base16Codec.lower.decoder;
      final a = decoder.convert(src);
      final b = vdec.convert(vsrc);
      if (a.length != b.length) throw StateError('length mismatch');
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) throw StateError('output mismatch at \$i');
      }
      final pkg = measure(() => decoder.convert(src));
      final ven = measure(() => vdec.convert(vsrc));
      final loc = measure(() => localDecodeListInt(src));
      rows
        ..add(Row(label, 'ab/package', pkg, size))
        ..add(Row(label, 'ab/vendor', ven, size))
        ..add(Row(label, 'ab/local', loc, size));
      continue;
    } else if (kVariant == 'vendor/decode') {
      // 実験 10: convertlib のソースを丸ごとエントリ側にコピーして同じ計測
      final src = vendor.toHexBytes(bytes);
      final vdec = vendor_codec.Base16Codec.lower.decoder;
      micros = measure(() => vdec.convert(src));
    } else if (kVariant == 'decode/no-codeunits') {
      // 実験 9: プログラム中に CodeUnits を 1 つも作らずに decode する
      final src = cl.toHexBytes(bytes);
      micros = measure(() => decoder.convert(src));
    } else if (kVariant == 'local/no-codeunits') {
      final src = cl.toHexBytes(bytes);
      micros = measure(() => localDecodeListInt(src));
    } else if (kVariant == 'local/extension') {
      final src = Uint8List.fromList(text.codeUnits);
      micros = measure(() => localDecodeExtension(src));
    } else if (kVariant == 'local/virtual') {
      // ---- 実験 5: 仮想呼び出しを挟むだけ。ループ本体は実験 4 と同一 -----
      final src = Uint8List.fromList(text.codeUnits);
      final decoders = <LocalDecoder>[
        const LocalHexDecoder(),
        const LocalNoopDecoder(),
      ];
      blackhole = decoders[1].convert(src); // 2 実装とも到達させる
      final chosen = decoders[0];
      micros = measure(() => chosen.convert(src));
    } else {
      throw StateError('unreachable');
    }
    rows.add(Row(label, kVariant, micros, size));
  }

  if (blackhole == null) {
    throw StateError('probe produced no result');
  }

  for (final row in rows) {
    print('${row.group}\t${row.label}\t'
        '${row.microsPerOp.toStringAsFixed(3)}\t'
        '${row.megabytesPerSecond.toStringAsFixed(1)}');
  }
}
