// ウォームアップ前後で JIT と AOT の関係がどう変わるかを見るプローブ。
//
// 本体ベンチマークは 100 ms のウォームアップ後の定常状態を測っているため、
// JIT が最適化コードに到達済みの状態しか見ていない。ここでは 1 回目から
// 順に累積時間を記録し、JIT が AOT を追い抜く地点を探す。
//
// 実行:
//   fvm dart run benchmark/probe_warmup.dart
//   fvm dart compile exe benchmark/probe_warmup.dart -o build/p_warmup && ./build/p_warmup

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart' as cl;

Object? blackhole;

Uint8List randomBytes(int length, {int seed = 42}) {
  var state = seed;
  final out = Uint8List(length);
  for (var i = 0; i < length; i++) {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF;
    out[i] = (state >>> 16) & 0xFF;
  }
  return out;
}

void main() {
  final bytes = randomBytes(65536);
  final text = cl.toHex(bytes);

  // 1 回目、10 回目、100 回目…と累積時間を記録する。
  const marks = [1, 10, 100, 1000, 10000];
  final sw = Stopwatch()..start();
  var done = 0;
  final results = <int, int>{};
  for (final mark in marks) {
    while (done < mark) {
      blackhole = cl.fromHex(text);
      done++;
    }
    results[mark] = sw.elapsedMicroseconds;
  }
  sw.stop();

  if (blackhole == null) throw StateError('no result');

  final mode = const bool.fromEnvironment('dart.vm.product') ? 'AOT' : 'JIT';
  var prevCount = 0;
  var prevMicros = 0;
  for (final mark in marks) {
    final micros = results[mark]!;
    final perOp = (micros - prevMicros) / (mark - prevCount);
    print('$mode\t${prevCount + 1}〜$mark 回目\t'
        '${perOp.toStringAsFixed(1)} µs/op\t'
        '累積 ${(micros / 1000).toStringAsFixed(1)} ms');
    prevCount = mark;
    prevMicros = micros;
  }
}
