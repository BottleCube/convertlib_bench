import 'dart:convert' show utf8;
import 'dart:math';
import 'dart:typed_data';

/// シードを固定して、どのマシンで実行してもまったく同じバイト列を計測する。
const int kSeed = 42;

/// バイナリペイロードのサイズ（小さい順）。
const List<int> kAllSizes = [16, 256, 4096, 65536, 1048576];

/// 出力が 8 倍（binary）・約 2.7 倍（octal）に膨らむフォーマットの上限。
/// 1 回の変換で数十 MB を確保しないように制限する。
const int kMaxExpandingSize = 65536;

/// `BigInt.parse` や繰り返しシフトは超線形に遅くなるため、BigInt のケースは
/// 1 MiB よりかなり手前で打ち切る。
const int kMaxBigIntSize = 4096;

String formatSize(int bytes) {
  if (bytes >= 1048576) return '${bytes ~/ 1048576} MiB';
  if (bytes >= 1024) return '${bytes ~/ 1024} KiB';
  return '$bytes B';
}

/// 決定的に生成されるバイナリのペイロード。
class ByteSample {
  ByteSample(this.bytes) : label = formatSize(bytes.length);

  final String label;
  final Uint8List bytes;

  int get length => bytes.length;
}

/// 決定的に生成されるテキストのペイロードと、その UTF-8 エンコード結果
/// （デコード方向の入力として使う）。
class TextSample {
  TextSample(String kind, this.text)
    : utf8Bytes = utf8.encode(text),
      label = '$kind/${formatSize(utf8.encode(text).length)}';

  final String label;
  final String text;
  final Uint8List utf8Bytes;

  int get length => utf8Bytes.length;
}

/// 疑似乱数バイト列。[length] と [seed] が同じなら常に同じ内容になる。
Uint8List randomBytes(int length, {int seed = kSeed}) {
  final random = Random(seed);
  final out = Uint8List(length);
  for (var i = 0; i < length; i++) {
    out[i] = random.nextInt(256);
  }
  return out;
}

/// UTF-8 換算で [targetBytes] に達するまで [unit] を繰り返す。
///
/// 文字の途中で切らないので、サロゲートペアやマルチバイト列が壊れることはない
/// （その代わりサイズは少し超過する）。
String _repeatToUtf8Bytes(String unit, int targetBytes) {
  final unitBytes = utf8.encode(unit).length;
  final repeats = max(1, (targetBytes / unitBytes).ceil());
  return unit * repeats;
}

const String _asciiUnit =
    'The quick brown fox jumps over the lazy dog. 0123456789\n';
const String _japaneseUnit =
    '吾輩は猫である。名前はまだ無い。どこで生れたかとんと見当がつかぬ。\n';
const String _emojiUnit = 'Hello 🎉 世界 👨‍👩‍👧‍👦 café ünïcode 🚀 テスト\n';

/// ベンチマークが使うペイロード一式。プロセスごとに 1 度だけ構築する。
class Datasets {
  Datasets._(this.byteSamples, this.textSamples);

  factory Datasets.build({List<int> sizes = kAllSizes}) {
    final bytes = [for (final size in sizes) ByteSample(randomBytes(size))];
    final texts = <TextSample>[];
    for (final entry in const {
      'ascii': _asciiUnit,
      'ja': _japaneseUnit,
      'emoji': _emojiUnit,
    }.entries) {
      texts.add(TextSample(entry.key, _repeatToUtf8Bytes(entry.value, 256)));
      texts.add(TextSample(entry.key, _repeatToUtf8Bytes(entry.value, 65536)));
    }
    return Datasets._(bytes, texts);
  }

  final List<ByteSample> byteSamples;
  final List<TextSample> textSamples;

  /// [maxBytes] 以下のバイナリサンプルだけを返す。
  List<ByteSample> bytesUpTo(int maxBytes) =>
      byteSamples.where((s) => s.length <= maxBytes).toList();
}
