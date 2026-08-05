import 'dart:io';

import 'src/cases.dart';
import 'src/datasets.dart';
import 'src/reporter.dart';
import 'src/runner.dart';

const String _usage = '''
Usage: dart run benchmark/main.dart [options]

  --quick               Short warmup/measurement windows (rough numbers, ~1/4 the time).
  --warmup-ms=<int>     Warmup window per case (default: 100, quick: 50).
  --measure-ms=<int>    Measurement window per case (default: 500, quick: 150).
  --formats=<a,b,...>   Only these formats (hex, base64, base64url, base32,
                        binary, octal, utf8, bigint, constant_time).
  --sizes=<a,b,...>     Binary payload sizes in bytes (default: 16,256,4096,65536,1048576).
  --out=<dir>           Report output directory (default: results).
  --no-write            Print the table but do not write results.md / results.csv.
  -h, --help            Show this help.
''';

class _Options {
  int warmupMillis = 100;
  int measureMillis = 500;
  Set<String>? formats;
  List<int> sizes = kAllSizes;
  String outDir = 'results';
  bool write = true;
}

_Options _parseArgs(List<String> args) {
  final options = _Options();
  var quick = false;
  int? warmup;
  int? measure;

  for (final arg in args) {
    if (arg == '-h' || arg == '--help') {
      stdout.write(_usage);
      exit(0);
    } else if (arg == '--quick') {
      quick = true;
    } else if (arg == '--no-write') {
      options.write = false;
    } else if (arg.startsWith('--warmup-ms=')) {
      warmup = int.parse(arg.split('=')[1]);
    } else if (arg.startsWith('--measure-ms=')) {
      measure = int.parse(arg.split('=')[1]);
    } else if (arg.startsWith('--formats=')) {
      options.formats = arg.split('=')[1].split(',').map((s) => s.trim()).toSet();
    } else if (arg.startsWith('--sizes=')) {
      options.sizes = arg
          .split('=')[1]
          .split(',')
          .map((s) => int.parse(s.trim()))
          .toList();
    } else if (arg.startsWith('--out=')) {
      options.outDir = arg.split('=')[1];
    } else {
      stderr.writeln('Unknown option: $arg\n');
      stderr.write(_usage);
      exit(64);
    }
  }

  if (quick) {
    options
      ..warmupMillis = 50
      ..measureMillis = 150;
  }
  if (warmup != null) options.warmupMillis = warmup;
  if (measure != null) options.measureMillis = measure;
  return options;
}

void main(List<String> args) {
  final options = _parseArgs(args);

  stdout.writeln('Preparing datasets (seed $kSeed)...');
  final data = Datasets.build(sizes: options.sizes);

  var cases = buildCases(data);
  final formats = options.formats;
  if (formats != null) {
    cases = cases.where((c) => formats.contains(c.format)).toList();
    if (cases.isEmpty) {
      stderr.writeln('No cases match --formats=${formats.join(',')}');
      exit(64);
    }
  }

  // convertlib と出力が一致しない実装の数値は、そもそも出してはいけない。
  stdout.writeln('Verifying that all implementations agree...');
  final failures = checkEquivalence(cases);
  if (failures.isNotEmpty) {
    stderr.writeln('Equivalence check failed:');
    for (final failure in failures) {
      stderr.writeln('  $failure');
    }
    exit(1);
  }

  final env = BenchEnvironment.detect(
    warmupMillis: options.warmupMillis,
    measureMillis: options.measureMillis,
  );
  for (final line in env.lines) {
    stdout.writeln(line);
  }
  final estimate = Duration(
    milliseconds: cases.length * (options.warmupMillis + options.measureMillis),
  );
  stdout.writeln(
    'Running ${cases.length} cases (at least ${estimate.inSeconds}s)...',
  );

  // 進捗は同じ行を上書きして表示するので、ターミナルのときだけ出す。
  final showProgress = stdout.hasTerminal;
  final results = runAll(
    cases,
    warmupMillis: options.warmupMillis,
    measureMillis: options.measureMillis,
    onResult: (index, total, result) {
      if (showProgress) {
        stdout.write('\r  [$index/$total] ${result.benchCase.name}'.padRight(90));
      }
    },
  );
  if (showProgress) stdout.write('\r${' ' * 90}\r');
  stdout.writeln();

  stdout.writeln(renderConsoleTable(results));

  if (options.write) {
    final files = writeReports(results, env, options.outDir);
    for (final file in files) {
      stdout.writeln('wrote ${file.path}');
    }
  }
}
