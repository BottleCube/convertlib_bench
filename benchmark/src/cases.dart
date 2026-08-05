import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:base32/base32.dart' as b32;
import 'package:convert/convert.dart' as pkg_convert;
import 'package:convertlib/convertlib.dart' as cl;

import 'baselines.dart';
import 'datasets.dart';

/// 実装のラベル。レポートに出したい順に並べてある。
const String implConvertlib = 'convertlib';
const String implDartConvert = 'dart:convert';
const String implPackageConvert = 'package:convert';
const String implPackageBase32 = 'package:base32';
const String implHandwritten = 'handwritten';

/// 計測の最小単位。1 つのペイロードを 1 つのライブラリで 1 回変換する。
class BenchCase {
  const BenchCase({
    required this.format,
    required this.direction,
    required this.impl,
    required this.dataLabel,
    required this.payloadBytes,
    required this.body,
  });

  /// `hex`、`base64`、`utf8` など。
  final String format;

  /// `encode`、`decode`、`compare` のいずれか。
  final String direction;

  /// 変換を行うライブラリ。
  final String impl;

  /// 変換するペイロード。`4 KiB` や `ja/64 KiB` など。
  final String dataLabel;

  /// スループット算出に使うバイナリのサイズ。デコード側は *デコード後* の
  /// サイズを入れてあるので、エンコードと直接比較できる。
  final int payloadBytes;

  /// 計測対象の処理。結果を返すことで、ランナー側が値を保持でき（デッドコード
  /// 削除の防止）、等価性チェックでも実装同士を比較できる。
  final Object? Function() body;

  /// このキーが同じケース同士は、同じ結果を返さなければならない。
  String get groupKey => '$format/$direction/$dataLabel';

  String get name => '$groupKey/$impl';
}

/// 2 つの変換結果が等価かどうか。
bool resultsEqual(Object? a, Object? b) {
  if (a is List<int> && b is List<int>) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  return a == b;
}

List<BenchCase> _cases(
  String format,
  String direction,
  String dataLabel,
  int payloadBytes,
  Map<String, Object? Function()> impls,
) => [
  for (final entry in impls.entries)
    BenchCase(
      format: format,
      direction: direction,
      impl: entry.key,
      dataLabel: dataLabel,
      payloadBytes: payloadBytes,
      body: entry.value,
    ),
];

/// [data] に対する計測ケースをすべて組み立てる。
///
/// デコード系の入力は事前にエンコードしておき、デコードの計測にエンコードの
/// 時間が混ざらないようにしている。
List<BenchCase> buildCases(Datasets data) {
  final cases = <BenchCase>[];

  // --- Base-16 (hex) -------------------------------------------------------
  for (final sample in data.byteSamples) {
    final bytes = sample.bytes;
    final encoded = cl.toHex(bytes);
    cases
      ..addAll(
        _cases('hex', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toHex(bytes),
          implPackageConvert: () => pkg_convert.hex.encode(bytes),
          implHandwritten: () => handwrittenHexEncode(bytes),
        }),
      )
      ..addAll(
        _cases('hex', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromHex(encoded),
          implPackageConvert: () => pkg_convert.hex.decode(encoded),
          implHandwritten: () => handwrittenHexDecode(encoded),
        }),
      );
  }

  // --- Base-64 -------------------------------------------------------------
  for (final sample in data.byteSamples) {
    final bytes = sample.bytes;
    final encoded = cl.toBase64(bytes);
    final encodedUrl = cl.toBase64(bytes, url: true);
    cases
      ..addAll(
        _cases('base64', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toBase64(bytes),
          implDartConvert: () => dc.base64.encode(bytes),
        }),
      )
      ..addAll(
        _cases('base64', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromBase64(encoded),
          implDartConvert: () => dc.base64.decode(encoded),
        }),
      )
      ..addAll(
        _cases('base64url', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toBase64(bytes, url: true),
          implDartConvert: () => dc.base64Url.encode(bytes),
        }),
      )
      ..addAll(
        _cases('base64url', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromBase64(encodedUrl),
          implDartConvert: () => dc.base64Url.decode(encodedUrl),
        }),
      );
  }

  // --- Base-32（RFC 4648 標準アルファベット・パディングあり） --------------
  for (final sample in data.byteSamples) {
    final bytes = sample.bytes;
    final encoded = cl.toBase32(bytes);
    cases
      ..addAll(
        _cases('base32', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toBase32(bytes),
          implPackageBase32: () => b32.base32.encode(bytes),
          implHandwritten: () => handwrittenBase32Encode(bytes),
        }),
      )
      ..addAll(
        _cases('base32', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromBase32(encoded),
          implPackageBase32: () => b32.base32.decode(encoded),
          implHandwritten: () => handwrittenBase32Decode(encoded),
        }),
      );
  }

  // --- Base-2（binary）と Base-8（octal）: 標準に相当物なし ----------------
  for (final sample in data.bytesUpTo(kMaxExpandingSize)) {
    final bytes = sample.bytes;
    final binary = cl.toBinary(bytes);
    final octal = cl.toOctal(bytes);
    cases
      ..addAll(
        _cases('binary', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toBinary(bytes),
          implHandwritten: () => handwrittenBinaryEncode(bytes),
        }),
      )
      ..addAll(
        _cases('binary', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromBinary(binary),
          implHandwritten: () => handwrittenBinaryDecode(binary),
        }),
      )
      ..addAll(
        _cases('octal', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toOctal(bytes),
          implHandwritten: () => handwrittenOctalEncode(bytes),
        }),
      )
      ..addAll(
        _cases('octal', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromOctal(octal),
          implHandwritten: () => handwrittenOctalDecode(octal),
        }),
      );
  }

  // --- UTF-8 ---------------------------------------------------------------
  for (final sample in data.textSamples) {
    final text = sample.text;
    final bytes = sample.utf8Bytes;
    cases
      ..addAll(
        _cases('utf8', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toUtf8(text),
          implDartConvert: () => dc.utf8.encode(text),
        }),
      )
      ..addAll(
        _cases('utf8', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromUtf8(bytes),
          implDartConvert: () => dc.utf8.decode(bytes),
        }),
      );
  }

  // --- BigInt（convertlib の既定に合わせてリトルエンディアン） -------------
  for (final sample in data.bytesUpTo(kMaxBigIntSize)) {
    final bytes = sample.bytes;
    final number = cl.toBigInt(bytes);
    cases
      ..addAll(
        _cases('bigint', 'encode', sample.label, sample.length, {
          implConvertlib: () => cl.toBigInt(bytes),
          implHandwritten: () => handwrittenBytesToBigInt(bytes),
        }),
      )
      ..addAll(
        _cases('bigint', 'decode', sample.label, sample.length, {
          implConvertlib: () => cl.fromBigInt(number),
          implHandwritten: () => handwrittenBigIntToBytes(number),
        }),
      );
  }

  // --- 定数時間比較（最悪ケースとして、内容が一致する 2 つを比較） ---------
  for (final sample in data.byteSamples) {
    final a = sample.bytes;
    final b = Uint8List.fromList(sample.bytes);
    cases.addAll(
      _cases('constant_time', 'compare', sample.label, sample.length, {
        implConvertlib: () => cl.constantTimeEquals(a, b),
        implHandwritten: () => handwrittenConstantTimeEquals(a, b),
      }),
    );
  }

  return cases;
}

/// 互いに結果が一致していなければならないケースの集まり。
class CaseGroup {
  CaseGroup(this.key, this.cases);

  final String key;
  final List<BenchCase> cases;
}

List<CaseGroup> groupCases(List<BenchCase> cases) {
  final byKey = <String, List<BenchCase>>{};
  for (final c in cases) {
    byKey.putIfAbsent(c.groupKey, () => []).add(c);
  }
  return [for (final e in byKey.entries) CaseGroup(e.key, e.value)];
}

/// 同じ変換に対する 2 つの実装の食い違い。
class EquivalenceFailure {
  EquivalenceFailure(this.groupKey, this.impl, this.expected, this.actual);

  final String groupKey;
  final String impl;
  final Object? expected;
  final Object? actual;

  @override
  String toString() =>
      '$groupKey: $impl disagrees with $implConvertlib '
      '(expected ${_preview(expected)}, got ${_preview(actual)})';

  static String _preview(Object? value) {
    final text = value is List<int> ? value.take(16).toList().toString() : '$value';
    return text.length <= 64 ? text : '${text.substring(0, 64)}...';
  }
}

/// 全ケースを 1 度ずつ実行し、同じ変換の実装同士が同じ結果を返すか検証する。
List<EquivalenceFailure> checkEquivalence(List<BenchCase> cases) {
  final failures = <EquivalenceFailure>[];
  for (final group in groupCases(cases)) {
    final reference = group.cases.firstWhere((c) => c.impl == implConvertlib);
    final expected = reference.body();
    for (final c in group.cases) {
      if (identical(c, reference)) continue;
      final actual = c.body();
      if (!resultsEqual(expected, actual)) {
        failures.add(
          EquivalenceFailure(group.key, c.impl, expected, actual),
        );
      }
    }
  }
  return failures;
}
