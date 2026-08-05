import 'dart:io';

import 'cases.dart';
import 'runner.dart';

/// 数値と一緒に記録するマシン / SDK の情報。実行環境の分からないベンチマーク
/// 結果は再現できないため。
class BenchEnvironment {
  BenchEnvironment({
    required this.timestamp,
    required this.dartVersion,
    required this.os,
    required this.cpu,
    required this.processors,
    required this.mode,
    required this.warmupMillis,
    required this.measureMillis,
  });

  factory BenchEnvironment.detect({
    required int warmupMillis,
    required int measureMillis,
  }) {
    return BenchEnvironment(
      timestamp: DateTime.now(),
      dartVersion: Platform.version,
      os: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      cpu: _detectCpu(),
      processors: Platform.numberOfProcessors,
      mode: _detectMode(),
      warmupMillis: warmupMillis,
      measureMillis: measureMillis,
    );
  }

  final DateTime timestamp;
  final String dartVersion;
  final String os;
  final String cpu;
  final int processors;
  final String mode;
  final int warmupMillis;
  final int measureMillis;

  static String _detectCpu() {
    try {
      if (Platform.isMacOS) {
        final result = Process.runSync('sysctl', ['-n', 'machdep.cpu.brand_string']);
        if (result.exitCode == 0) return (result.stdout as String).trim();
      } else if (Platform.isLinux) {
        final line = File('/proc/cpuinfo').readAsLinesSync().firstWhere(
          (l) => l.startsWith('model name'),
          orElse: () => '',
        );
        if (line.isNotEmpty) return line.split(':').last.trim();
      }
    } on Object {
      // 取れなければ諦める（あくまで参考情報）。
    }
    return 'unknown';
  }

  /// AOT スナップショットのバージョン文字列には JIT VM のような "(...)" の
  /// ビルド情報が付かない。コンパイル済み実行ファイルかどうかは
  /// `bool.fromEnvironment('dart.vm.product')` で確実に判定できる。
  static String _detectMode() =>
      const bool.fromEnvironment('dart.vm.product') ? 'AOT' : 'JIT';

  List<String> get lines => [
    'date: ${timestamp.toIso8601String()}',
    'dart: ${dartVersion.split(' ').first} ($mode)',
    'os: $os',
    'cpu: $cpu ($processors logical cores)',
    'timing: $warmupMillis ms warmup + $measureMillis ms measurement per case',
  ];
}

/// レポート 1 行分。計測結果と、convertlib に対する比率を持つ。
class _Row {
  _Row(this.result, this.relative);

  final BenchResult result;

  /// `microsPerOp / convertlib の microsPerOp`。1.0 未満なら convertlib より速い。
  final double relative;
}

List<_Row> _rowsFor(List<BenchResult> results) {
  final byGroup = <String, List<BenchResult>>{};
  for (final r in results) {
    byGroup.putIfAbsent(r.benchCase.groupKey, () => []).add(r);
  }
  final rows = <_Row>[];
  for (final r in results) {
    final group = byGroup[r.benchCase.groupKey]!;
    BenchResult? reference;
    for (final g in group) {
      if (g.benchCase.impl == implConvertlib) {
        reference = g;
        break;
      }
    }
    final relative = reference == null
        ? double.nan
        : r.microsPerOp / reference.microsPerOp;
    rows.add(_Row(r, relative));
  }
  return rows;
}

String _num(double value, {int decimals = 3}) {
  if (value.isNaN || value.isInfinite) return '-';
  final text = value >= 1000
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(decimals);
  // 桁区切りを入れて、幅の広い列を読みやすくする。
  final parts = text.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return parts.length > 1 ? '${buffer.toString()}.${parts[1]}' : buffer.toString();
}

const List<String> _headers = [
  'format',
  'dir',
  'data',
  'impl',
  'µs/op',
  'ops/s',
  'MB/s',
  'rel',
];

List<String> _cells(_Row row) {
  final c = row.result.benchCase;
  return [
    c.format,
    c.direction,
    c.dataLabel,
    c.impl,
    _num(row.result.microsPerOp),
    _num(row.result.opsPerSecond, decimals: 0),
    _num(row.result.megabytesPerSecond, decimals: 1),
    row.relative.isNaN ? '-' : '${row.relative.toStringAsFixed(2)}x',
  ];
}

/// 行を `format / direction` のセクションにまとめ直す。セクション内の順序は
/// 元のまま（ペイロードの小さい順）。ケースはペイロード単位で生成しているので、
/// これをしないと 1 つのフォーマットがサイズごとのセクションに分断される。
Map<String, List<_Row>> _sections(List<BenchResult> results) {
  final sections = <String, List<_Row>>{};
  for (final row in _rowsFor(results)) {
    final c = row.result.benchCase;
    sections.putIfAbsent('${c.format} / ${c.direction}', () => []).add(row);
  }
  return sections;
}

/// ターミナル向けの固定幅テーブル。
String renderConsoleTable(List<BenchResult> results) {
  final sections = _sections(results);
  final rows = [
    for (final section in sections.values) ...section.map(_cells),
  ];
  final widths = List<int>.generate(
    _headers.length,
    (i) => [
      _headers[i].length,
      ...rows.map((r) => r[i].length),
    ].reduce((a, b) => a > b ? a : b),
  );
  // 数値の列は右寄せの方が読みやすい。
  const rightAligned = {4, 5, 6, 7};

  String line(List<String> cells) => [
    for (var i = 0; i < cells.length; i++)
      rightAligned.contains(i)
          ? cells[i].padLeft(widths[i])
          : cells[i].padRight(widths[i]),
  ].join('  ');

  final buffer = StringBuffer()
    ..writeln(line(_headers))
    ..writeln(widths.map((w) => '-' * w).join('  '));
  var previousGroup = rows.isEmpty ? '' : '${rows.first[0]}/${rows.first[1]}';
  for (final row in rows) {
    final group = '${row[0]}/${row[1]}';
    if (group != previousGroup) {
      buffer.writeln();
      previousGroup = group;
    }
    buffer.writeln(line(row));
  }
  return buffer.toString();
}

String renderMarkdown(List<BenchResult> results, BenchEnvironment env) {
  final buffer = StringBuffer()
    ..writeln('# convertlib benchmark results')
    ..writeln()
    ..writeln('| key | value |')
    ..writeln('| --- | --- |');
  for (final line in env.lines) {
    final split = line.indexOf(': ');
    buffer.writeln('| ${line.substring(0, split)} | ${line.substring(split + 2)} |');
  }
  buffer
    ..writeln()
    ..writeln('`rel` is µs/op divided by convertlib\'s µs/op for the same '
        'conversion and payload: below 1.00 means faster than convertlib.')
    ..writeln();

  for (final section in _sections(results).entries) {
    buffer
      ..writeln()
      ..writeln('## ${section.key}')
      ..writeln()
      ..writeln('| data | impl | µs/op | ops/s | MB/s | rel |')
      ..writeln('| --- | --- | ---: | ---: | ---: | ---: |');
    for (final row in section.value) {
      final cells = _cells(row);
      buffer.writeln(
        '| ${cells[2]} | ${cells[3]} | ${cells[4]} | ${cells[5]} | '
        '${cells[6]} | ${cells[7]} |',
      );
    }
  }
  return buffer.toString();
}

String renderCsv(List<BenchResult> results, BenchEnvironment env) {
  final buffer = StringBuffer()
    ..writeln(
      'format,direction,data,payload_bytes,impl,us_per_op,ops_per_sec,'
      'mb_per_sec,rel_to_convertlib,mode,dart,cpu',
    );
  for (final row in _sections(results).values.expand((rows) => rows)) {
    final c = row.result.benchCase;
    buffer.writeln(
      [
        c.format,
        c.direction,
        c.dataLabel,
        c.payloadBytes,
        c.impl,
        row.result.microsPerOp.toStringAsFixed(6),
        row.result.opsPerSecond.toStringAsFixed(2),
        row.result.megabytesPerSecond.toStringAsFixed(2),
        row.relative.isNaN ? '' : row.relative.toStringAsFixed(4),
        env.mode,
        env.dartVersion.split(' ').first,
        '"${env.cpu}"',
      ].join(','),
    );
  }
  return buffer.toString();
}

/// [directory] に `results.md` と `results.csv` を書き出す（無ければ作成）。
/// 書き出したファイルを返す。
List<File> writeReports(
  List<BenchResult> results,
  BenchEnvironment env,
  String directory,
) {
  final dir = Directory(directory);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final markdown = File('${dir.path}/results.md')
    ..writeAsStringSync(renderMarkdown(results, env));
  final csv = File('${dir.path}/results.csv')
    ..writeAsStringSync(renderCsv(results, env));
  return [markdown, csv];
}
