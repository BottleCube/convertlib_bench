import 'package:benchmark_harness/benchmark_harness.dart';

import 'cases.dart';

/// 計測対象の呼び出しは結果をここへ代入する。こうしておかないと JIT・AOT
/// どちらのコンパイラにも「使われない変換」としてまるごと削除されうる。
Object? blackhole;

class BenchResult {
  BenchResult(this.benchCase, this.microsPerOp);

  final BenchCase benchCase;

  /// 1 変換あたりの実時間（マイクロ秒）。
  final double microsPerOp;

  double get opsPerSecond => 1e6 / microsPerOp;

  /// ペイロードのスループット。bytes/µs は MB/s（10^6 基準）と同じ値になる。
  double get megabytesPerSecond => benchCase.payloadBytes / microsPerOp;
}

/// [BenchCase] を標準のハーネスで包む。ただし 2 点だけ変えている。
/// `exercise()` はケースをちょうど 1 回実行する（スコアが 10 回分の平均ではなく
/// 1 回あたりのマイクロ秒になる）。また、ウォームアップと計測の窓を指定できる。
class _CaseBenchmark extends BenchmarkBase {
  _CaseBenchmark(
    this.benchCase, {
    required this.warmupMillis,
    required this.measureMillis,
  }) : super(benchCase.name);

  final BenchCase benchCase;
  final int warmupMillis;
  final int measureMillis;

  @override
  void run() {
    blackhole = benchCase.body();
  }

  @override
  void exercise() => run();

  @override
  double measure() {
    setup();
    BenchmarkBase.measureFor(warmup, warmupMillis);
    final score = BenchmarkBase.measureFor(exercise, measureMillis);
    teardown();
    return score;
  }
}

/// 全ケースを順に計測する。進捗は [onResult] で通知する。
List<BenchResult> runAll(
  List<BenchCase> cases, {
  required int warmupMillis,
  required int measureMillis,
  void Function(int index, int total, BenchResult result)? onResult,
}) {
  final results = <BenchResult>[];
  for (var i = 0; i < cases.length; i++) {
    final benchmark = _CaseBenchmark(
      cases[i],
      warmupMillis: warmupMillis,
      measureMillis: measureMillis,
    );
    final result = BenchResult(cases[i], benchmark.measure());
    results.add(result);
    onResult?.call(i + 1, cases.length, result);
  }
  if (blackhole == null) {
    throw StateError('Benchmark bodies produced no result — measurement is bogus');
  }
  return results;
}
