// 同じ変換を (a) main 内の直書きループ (b) クロージャ越し で回して比べる。
import 'dart:typed_data';
import 'package:convertlib/convertlib.dart' as cl;

Object? blackhole;

Uint8List randomBytes(int n, {int seed = 42}) {
  var s = seed;
  final o = Uint8List(n);
  for (var i = 0; i < n; i++) { s = (s * 1103515245 + 12345) & 0x7FFFFFFF; o[i] = (s >>> 16) & 0xFF; }
  return o;
}

double viaClosure(Object? Function() body, int iters) {
  for (var i = 0; i < iters; i++) { blackhole = body(); }   // ウォームアップ
  final sw = Stopwatch()..start();
  for (var i = 0; i < iters; i++) { blackhole = body(); }
  return sw.elapsedMicroseconds / iters;
}

void main() {
  final bytes = randomBytes(65536);
  final text = cl.toHex(bytes);
  const iters = 2000;

  for (var i = 0; i < iters; i++) { blackhole = cl.fromHex(text); }  // ウォームアップ
  final sw = Stopwatch()..start();
  for (var i = 0; i < iters; i++) { blackhole = cl.fromHex(text); }
  final direct = sw.elapsedMicroseconds / iters;

  final closure = viaClosure(() => cl.fromHex(text), iters);

  final mode = const bool.fromEnvironment('dart.vm.product') ? 'AOT' : 'JIT';
  print('$mode\t直書きループ\t${direct.toStringAsFixed(1)} µs/op');
  print('$mode\tクロージャ越し\t${closure.toStringAsFixed(1)} µs/op');
}
