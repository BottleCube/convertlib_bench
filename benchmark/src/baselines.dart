/// `dart:convert` に相当物がない変換の、素直な手書き実装。
///
/// 目指すのは *公平な* ベースライン。開発者が自分で書くとしたらこう書く、という
/// 水準のコード（ルックアップテーブル、事前確保した `Uint8List`、`StringBuffer`
/// の無駄な連結を避ける）にとどめ、それ以上のビット演算の作り込みはしない。
/// わざと遅く書いたコードと convertlib を比べても何も分からないため。
library;

import 'dart:typed_data';

const int _zeroChar = 0x30; // '0'
const int _padChar = 0x3D; // '='

// ---------------------------------------------------------------------------
// Base-16 (hex)
// ---------------------------------------------------------------------------

final Uint8List _hexChars = Uint8List.fromList('0123456789abcdef'.codeUnits);

String handwrittenHexEncode(List<int> input) {
  final out = Uint8List(input.length * 2);
  var j = 0;
  for (var i = 0; i < input.length; i++) {
    final b = input[i];
    out[j++] = _hexChars[(b >> 4) & 0xF];
    out[j++] = _hexChars[b & 0xF];
  }
  return String.fromCharCodes(out);
}

int _hexValue(int char) {
  if (char >= 0x30 && char <= 0x39) return char - 0x30; // 0-9
  if (char >= 0x61 && char <= 0x66) return char - 0x57; // a-f
  if (char >= 0x41 && char <= 0x46) return char - 0x37; // A-F
  throw FormatException('Invalid hex character: $char');
}

Uint8List handwrittenHexDecode(String input) {
  if (input.length.isOdd) {
    throw const FormatException('Odd length hex string');
  }
  final out = Uint8List(input.length >> 1);
  for (var i = 0; i < out.length; i++) {
    out[i] =
        (_hexValue(input.codeUnitAt(i * 2)) << 4) |
        _hexValue(input.codeUnitAt(i * 2 + 1));
  }
  return out;
}

// ---------------------------------------------------------------------------
// Base-32（RFC 4648・標準アルファベット・パディングあり）
// ---------------------------------------------------------------------------

const String _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
final Uint8List _base32Chars = Uint8List.fromList(_base32Alphabet.codeUnits);
final Uint8List _base32Values = _buildBase32Values();

Uint8List _buildBase32Values() {
  final table = Uint8List(128)..fillRange(0, 128, 0xFF);
  for (var i = 0; i < _base32Alphabet.length; i++) {
    table[_base32Alphabet.codeUnitAt(i)] = i;
    table[_base32Alphabet.toLowerCase().codeUnitAt(i)] = i;
  }
  return table;
}

String handwrittenBase32Encode(List<int> input) {
  final out = Uint8List(((input.length + 4) ~/ 5) * 8);
  var buffer = 0;
  var bits = 0;
  var j = 0;
  for (var i = 0; i < input.length; i++) {
    buffer = ((buffer << 8) | (input[i] & 0xFF)) & 0xFFFFF;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out[j++] = _base32Chars[(buffer >> bits) & 0x1F];
    }
  }
  if (bits > 0) {
    out[j++] = _base32Chars[(buffer << (5 - bits)) & 0x1F];
  }
  while (j < out.length) {
    out[j++] = _padChar;
  }
  return String.fromCharCodes(out);
}

Uint8List handwrittenBase32Decode(String input) {
  var end = input.length;
  while (end > 0 && input.codeUnitAt(end - 1) == _padChar) {
    end--;
  }
  final out = Uint8List((end * 5) ~/ 8);
  var buffer = 0;
  var bits = 0;
  var j = 0;
  for (var i = 0; i < end; i++) {
    final char = input.codeUnitAt(i);
    final value = char < 128 ? _base32Values[char] : 0xFF;
    if (value == 0xFF) {
      throw FormatException('Invalid base32 character at $i');
    }
    buffer = ((buffer << 5) | value) & 0xFFFFF;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      out[j++] = (buffer >> bits) & 0xFF;
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Base-2（binary）—— 1 バイトを MSB 側から 8 文字で表す。
// ---------------------------------------------------------------------------

final Uint8List _binaryChars = _buildBinaryChars();

Uint8List _buildBinaryChars() {
  final table = Uint8List(256 * 8);
  for (var b = 0; b < 256; b++) {
    final digits = b.toRadixString(2).padLeft(8, '0');
    for (var k = 0; k < 8; k++) {
      table[b * 8 + k] = digits.codeUnitAt(k);
    }
  }
  return table;
}

String handwrittenBinaryEncode(List<int> input) {
  final out = Uint8List(input.length * 8);
  var j = 0;
  for (var i = 0; i < input.length; i++) {
    final base = (input[i] & 0xFF) * 8;
    for (var k = 0; k < 8; k++) {
      out[j++] = _binaryChars[base + k];
    }
  }
  return String.fromCharCodes(out);
}

Uint8List handwrittenBinaryDecode(String input) {
  final out = Uint8List(input.length >> 3);
  for (var i = 0; i < out.length; i++) {
    var value = 0;
    for (var k = 0; k < 8; k++) {
      final digit = input.codeUnitAt(i * 8 + k) - _zeroChar;
      if (digit != 0 && digit != 1) {
        throw FormatException('Invalid binary character at ${i * 8 + k}');
      }
      value = (value << 1) | digit;
    }
    out[i] = value;
  }
  return out;
}

// ---------------------------------------------------------------------------
// Base-8（octal）
// ---------------------------------------------------------------------------
//
// convertlib は `ceil(ビット数 / 3)` 文字を出力し、ビット列を右詰めにする。
// つまり端数のグループが *先頭* に来る（2 バイトなら "044145"）。
// 同じ文字列になるよう、この実装も同じ並びにしている。

String handwrittenOctalEncode(List<int> input) {
  final totalBits = input.length * 8;
  final chars = (totalBits + 2) ~/ 3;
  final out = Uint8List(chars);
  var buffer = 0;
  // 3 の倍数に届くまでのゼロビットが先頭にあるものとして扱い、端数のグループを
  // 先頭に寄せる。
  var bits = chars * 3 - totalBits;
  var j = 0;
  for (var i = 0; i < input.length; i++) {
    buffer = ((buffer << 8) | (input[i] & 0xFF)) & 0xFFFF;
    bits += 8;
    while (bits >= 3) {
      bits -= 3;
      out[j++] = _zeroChar + ((buffer >> bits) & 0x7);
    }
  }
  return String.fromCharCodes(out);
}

Uint8List handwrittenOctalDecode(String input) {
  final outLength = (input.length * 3) ~/ 8;
  final out = Uint8List(outLength);
  var buffer = 0;
  // エンコード時に先頭へ付いたパディングビットを読み飛ばす。
  var bits = -(input.length * 3 - outLength * 8);
  var j = 0;
  for (var i = 0; i < input.length; i++) {
    final digit = input.codeUnitAt(i) - _zeroChar;
    if (digit < 0 || digit > 7) {
      throw FormatException('Invalid octal character at $i');
    }
    buffer = ((buffer << 3) | digit) & 0xFFFF;
    bits += 3;
    if (bits >= 8) {
      bits -= 8;
      out[j++] = (buffer >> bits) & 0xFF;
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// BigInt（リトルエンディアン。convertlib の既定 `msbFirst: false` に合わせる）
// ---------------------------------------------------------------------------

/// バイト列 → BigInt。Dart でよく使われる 16 進文字列経由のやり方。
BigInt handwrittenBytesToBigInt(List<int> input) {
  final chars = Uint8List(input.length * 2);
  var j = 0;
  for (var i = input.length - 1; i >= 0; i--) {
    final b = input[i] & 0xFF;
    chars[j++] = _hexChars[(b >> 4) & 0xF];
    chars[j++] = _hexChars[b & 0xF];
  }
  return BigInt.parse(String.fromCharCodes(chars), radix: 16);
}

/// BigInt → リトルエンディアンのバイト列（先頭のゼロバイトを持たない最小長）。
Uint8List handwrittenBigIntToBytes(BigInt input) {
  if (input == BigInt.zero) return Uint8List(1);
  var hex = input.toRadixString(16);
  if (hex.length.isOdd) hex = '0$hex';
  final out = Uint8List(hex.length >> 1);
  for (var i = 0; i < out.length; i++) {
    out[out.length - 1 - i] =
        (_hexValue(hex.codeUnitAt(i * 2)) << 4) |
        _hexValue(hex.codeUnitAt(i * 2 + 1));
  }
  return out;
}

// ---------------------------------------------------------------------------
// 定数時間比較
// ---------------------------------------------------------------------------

bool handwrittenConstantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
