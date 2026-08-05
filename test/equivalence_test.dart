import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:convertlib/convertlib.dart' as cl;
import 'package:test/test.dart';

import '../benchmark/src/baselines.dart';
import '../benchmark/src/cases.dart';
import '../benchmark/src/datasets.dart';

void main() {
  group('benchmark matrix', () {
    // 本番の計測より小さいサイズだけを使う。ここで見るのは正しさだけで、
    // 1 MiB のペイロードは実行時間が延びるだけで何も増やさない。
    final data = Datasets.build(sizes: const [16, 256, 4096]);
    final cases = buildCases(data);

    test('every implementation agrees with convertlib', () {
      expect(checkEquivalence(cases), isEmpty);
    });

    test('covers all formats in both directions', () {
      final keys = cases.map((c) => '${c.format}/${c.direction}').toSet();
      expect(keys, containsAll(<String>[
        'hex/encode', 'hex/decode',
        'base64/encode', 'base64/decode',
        'base64url/encode', 'base64url/decode',
        'base32/encode', 'base32/decode',
        'binary/encode', 'binary/decode',
        'octal/encode', 'octal/decode',
        'utf8/encode', 'utf8/decode',
        'bigint/encode', 'bigint/decode',
        'constant_time/compare',
      ]));
    });

    test('every group has convertlib plus at least one other implementation', () {
      for (final group in groupCases(cases)) {
        final impls = group.cases.map((c) => c.impl).toList();
        expect(impls, contains(implConvertlib), reason: group.key);
        expect(impls.length, greaterThanOrEqualTo(2), reason: group.key);
      }
    });
  });

  group('edge cases', () {
    // 1〜8 バイトで base32（5 バイト単位）、base64（3 バイト単位）、
    // octal（3 ビット単位）のパディング境界をすべて通る。
    final samples = [
      for (var n = 1; n <= 8; n++) randomBytes(n, seed: 7 + n),
      Uint8List.fromList([0, 0, 0]),
      Uint8List.fromList([255, 255, 255, 255, 255]),
    ];

    for (final bytes in samples) {
      final label = '${bytes.length} bytes (${cl.toHex(bytes)})';

      test('hex round trip and equivalence — $label', () {
        final encoded = cl.toHex(bytes);
        expect(handwrittenHexEncode(bytes), encoded);
        expect(cl.fromHex(encoded), bytes);
        expect(handwrittenHexDecode(encoded), bytes);
      });

      test('base64 matches dart:convert — $label', () {
        expect(cl.toBase64(bytes), dc.base64.encode(bytes));
        expect(cl.toBase64(bytes, url: true), dc.base64Url.encode(bytes));
        expect(cl.fromBase64(cl.toBase64(bytes)), bytes);
      });

      test('base32 round trip and equivalence — $label', () {
        final encoded = cl.toBase32(bytes);
        expect(handwrittenBase32Encode(bytes), encoded);
        expect(cl.fromBase32(encoded), bytes);
        expect(handwrittenBase32Decode(encoded), bytes);
      });

      test('binary round trip and equivalence — $label', () {
        final encoded = cl.toBinary(bytes);
        expect(handwrittenBinaryEncode(bytes), encoded);
        expect(cl.fromBinary(encoded), bytes);
        expect(handwrittenBinaryDecode(encoded), bytes);
      });

      test('octal round trip and equivalence — $label', () {
        final encoded = cl.toOctal(bytes);
        expect(handwrittenOctalEncode(bytes), encoded);
        expect(cl.fromOctal(encoded), bytes);
        expect(handwrittenOctalDecode(encoded), bytes);
      });

      test('bigint round trip and equivalence — $label', () {
        final number = cl.toBigInt(bytes);
        expect(handwrittenBytesToBigInt(bytes), number);
        expect(handwrittenBigIntToBytes(number), cl.fromBigInt(number));
      });

      test('constant time comparison — $label', () {
        final copy = Uint8List.fromList(bytes);
        expect(cl.constantTimeEquals(bytes, copy), isTrue);
        expect(handwrittenConstantTimeEquals(bytes, copy), isTrue);
        final different = Uint8List.fromList(bytes)
          ..[bytes.length - 1] ^= 0xFF;
        expect(cl.constantTimeEquals(bytes, different), isFalse);
        expect(handwrittenConstantTimeEquals(bytes, different), isFalse);
      });
    }
  });

  group('utf8', () {
    const texts = [
      '',
      'ascii only',
      '日本語のテキスト',
      'mixed 🎉 emoji 👨‍👩‍👧‍👦 and ünïcode',
    ];

    for (final text in texts) {
      test('matches dart:convert — "${text.length} code units"', () {
        final expected = dc.utf8.encode(text);
        expect(cl.toUtf8(text), expected);
        expect(cl.fromUtf8(expected), text);
        expect(dc.utf8.decode(expected), text);
      });
    }
  });

  group('datasets', () {
    test('are deterministic for a fixed seed', () {
      expect(randomBytes(64), randomBytes(64));
      expect(Datasets.build().byteSamples.first.bytes, randomBytes(16));
    });

    test('text samples reach their target size without truncation', () {
      for (final sample in Datasets.build().textSamples) {
        expect(dc.utf8.decode(sample.utf8Bytes), sample.text);
      }
    });
  });
}
