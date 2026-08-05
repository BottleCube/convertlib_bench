# conv_bench

[convertlib](https://pub.dev/packages/convertlib) の変換処理を、Dart 標準
(`dart:convert`)・Dart 公式パッケージ (`package:convert`)・pub の代表的パッケージ
(`package:base32`)・素直な手書き実装と比較するベンチマーク。

## 実行方法

```sh
fvm dart pub get
fvm dart test                              # 実装の等価性を検証
fvm dart run benchmark/main.dart --quick   # 短時間の試し計測（結果は results/ に出力）
fvm dart run benchmark/main.dart           # フル計測（数分）
```

主なオプション（`--help` で全て表示）:

| オプション | 意味 |
| --- | --- |
| `--quick` | ウォームアップ 50ms・計測 150ms に短縮（精度は落ちる） |
| `--warmup-ms=` / `--measure-ms=` | 計測窓を直接指定（既定: 100ms / 500ms） |
| `--formats=hex,base64` | 対象フォーマットを限定 |
| `--sizes=256,4096` | バイナリのペイロードサイズ（バイト）を限定（UTF-8 のテキストは対象外） |
| `--out=results/aot` | レポート出力先 |
| `--no-write` | ファイルを書かず標準出力のみ |

### AOT で計測する

JIT と AOT では特に小さいペイロードの結果が変わるため、両方取ると分かりやすい。

```sh
mkdir -p build
fvm dart compile exe benchmark/main.dart -o build/conv_bench
./build/conv_bench --out=results/aot
```

レポートの `dart:` 行に `JIT` / `AOT` が記録される。

## 計測対象

| フォーマット | convertlib | 比較対象 |
| --- | --- | --- |
| hex (Base-16) | `toHex` / `fromHex` | `package:convert` の `hex`、手書き |
| base64 | `toBase64` / `fromBase64` | `dart:convert` の `base64` |
| base64url | `toBase64(url: true)` / `fromBase64` | `dart:convert` の `base64Url` |
| base32 (RFC 4648) | `toBase32` / `fromBase32` | `package:base32`、手書き |
| binary (Base-2) | `toBinary` / `fromBinary` | 手書き |
| octal (Base-8) | `toOctal` / `fromOctal` | 手書き |
| utf8 | `toUtf8` / `fromUtf8` | `dart:convert` の `utf8` |
| bigint | `toBigInt` / `fromBigInt` | 手書き（16 進文字列 + `BigInt.parse`） |
| constant_time | `constantTimeEquals` | 手書きの XOR 累積ループ |

`toCrypt` / `fromCrypt`（PHC / Modular Crypt Format）は同等の比較対象が存在しない
ため、計測対象から外している。

## データの準備

`benchmark/src/datasets.dart` が実行時に固定シード (`Random(42)`) で生成する。
リポジトリにバイナリを置かずに、どのマシンでも同じ入力になる。

- バイナリ: 16 B / 256 B / 4 KiB / 64 KiB / 1 MiB
  - binary・octal は出力が 8 倍・約 2.7 倍に膨らむため 64 KiB まで
  - bigint は `BigInt` 演算が超線形なため 4 KiB まで
- テキスト (UTF-8): ASCII / 日本語 / 絵文字混在（サロゲートペア・ZWJ 含む）の
  3 種 × 約 300 B・約 64 KiB
- decode 系の入力は事前に 1 度だけエンコードして保持し、decode の計測に encode の
  時間が混ざらないようにしている

## 計測方法

- `package:benchmark_harness` の `BenchmarkBase` を使用。ただし `exercise()` を
  `run()` 1 回に上書きしているので、スコアは **1 変換あたりのマイクロ秒**
  （既定の「10 回分の平均」ではない）。
- ケースごとに 100ms のウォームアップ後、500ms 以上になるまで繰り返して計測。
- 変換結果は `blackhole` 変数に代入して保持し、デッドコード削除で計測が
  無効化されないようにしている。
- ベンチマーク開始前に全実装の出力が convertlib と一致することを検証し、
  1 つでも食い違えば数値を出さずに異常終了する（`checkEquivalence`）。

### 手書きベースラインの方針

「開発者が自分で書くとしたらこう書く」水準の素直な実装にしている。具体的には
ルックアップテーブル・事前確保した `Uint8List`・`String.fromCharCodes` は使うが、
それ以上のビット演算の作り込みはしない。極端に遅いコードと比較しても意味がない
ため。実装は `benchmark/src/baselines.dart`。

## 結果の読み方

`results/results.md`（表）と `results/results.csv`（生データ）に出力される。

| 列 | 意味 |
| --- | --- |
| `µs/op` | 1 変換あたりのマイクロ秒（小さいほど速い） |
| `ops/s` | 1 秒あたりの変換回数 |
| `MB/s` | ペイロードのスループット（10^6 バイト基準）。decode 側もデコード後のバイト数で計算しているので encode と直接比較できる |
| `rel` | 同じ変換・同じペイロードでの convertlib に対する `µs/op` の比。**1.00 未満なら convertlib より速い** |

注意点:

- 計測は同一プロセス内で連続実行するため、GC の影響を完全には除去できない。
  傾向を見る用途であり、数 % の差を断定する精度はない。
- 実行環境（Dart のバージョン・OS・CPU）はレポート冒頭に記録される。別マシンの
  結果と数値を直接比べないこと。
- 小さいペイロード（16 B）では呼び出しオーバーヘッドが支配的になるため、
  MB/s は大きいペイロードほど実力に近い。

## 現時点の結果（要約）

Apple M3 Pro / macOS 26.5.2 / Dart 3.12.2、JIT・64 KiB〜1 MiB のペイロードでの傾向。
数値は `results/results.md`（JIT）と `results/aot/results.md`（AOT）を参照。

- **hex**: convertlib が最速。`package:convert` は encode で 1.6〜3.6 倍、decode で
  2.0〜3.2 倍遅い。手書きは 1.3〜2.1 倍遅い程度で健闘する。
- **base64 / base64url**: convertlib が `dart:convert` より一貫して速い
  （encode 1.23 倍、decode 1.35 倍）。URL セーフ版でも差は変わらない。
- **base32**: convertlib が圧倒的。`package:base32` の `encode` は文字列の `+=`
  連結でオーダーが O(n²) になっており、1 MiB では 1 万倍以上遅い（0.04 MB/s）。
  decode でも 26 倍遅い。手書きは約 2〜2.9 倍遅い。
- **binary / octal**: 標準に相当物がない領域。convertlib は手書きより
  binary encode で 2.8〜3.8 倍、octal encode で 1.8 倍速い。
- **utf8**: encode は convertlib が 1.2〜2.3 倍速い（日本語で差が大きい）。
  一方 **decode の ASCII は `dart:convert` が 7 倍以上速い** —— `dart:convert` は
  ASCII 専用の高速パスを持つため。日本語は convertlib が 1.4 倍速く、絵文字混在は
  ほぼ互角（`dart:convert` がわずかに速い）。
- **bigint**: バイト列 → `BigInt` は手書きの「16 進文字列 + `BigInt.parse`」の方が
  1.6 倍速い（AOT では 2.4 倍）。逆方向は convertlib が 1.1〜1.2 倍速い。
- **constant_time**: 手書きの XOR ループと差がない（誤差 ±2%）。

## 構成

```
benchmark/main.dart          エントリポイント（引数処理・検証・実行・出力）
benchmark/src/datasets.dart  固定シードのデータ生成
benchmark/src/baselines.dart 手書き実装
benchmark/src/cases.dart     計測ケースの組み立てと等価性検証
benchmark/src/runner.dart    benchmark_harness のラッパ
benchmark/src/reporter.dart  コンソール表 / Markdown / CSV 出力
test/equivalence_test.dart   等価性・ラウンドトリップのテスト
results/                     計測結果
```
