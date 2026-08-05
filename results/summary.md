# JIT / AOT ベンチマークの総括

convertlib を `dart:convert` / `package:convert` / `package:base32` / 手書き実装と
比較したベンチマークについて、JIT 実行と AOT 実行の差を総括する。

計測環境: Apple M3 Pro (12 logical cores) / macOS 26.5.2 / Dart 3.12.2 /
ウォームアップ 100 ms + 計測 500 ms。

## 目次

| ファイル | 内容 |
| --- | --- |
| [results.md](results.md) | JIT の全計測結果(生データ) |
| [aot/results.md](aot/results.md) | AOT の全計測結果(生データ) |
| [aot/summary.md](aot/summary.md) | AOT 結果の要約(convertlib 対 競合) |
| [jit-vs-aot.md](jit-vs-aot.md) | convertlib 自身の JIT / AOT 比較 |
| [aot-gap-investigation.md](aot-gap-investigation.md) | AOT で遅くなる原因の調査記録 |
| `rerun/jit/`, `rerun/aot/` | 再現性確認のための再計測結果 |

---

## 1. 何を測り、何を測っていないか

このベンチマークは **100 ms ウォームアップ後の定常スループット**を測っている。
つまり JIT が最適化コードに到達し終えた後の状態だけを見ており、**起動時間・初回
呼び出しのレイテンシ・メモリ使用量は含まない**。AOT の本来の強みがちょうど計測
対象外になっている、という前提をまず押さえる必要がある。

## 2. 定常スループットでは「引き分け」が実態

178 ケースの AOT/JIT 比を実装ごとに集計すると次のようになる
(1.00 未満なら AOT が速い)。

| 実装 | ケース数 | 中央値 | 判定 |
| --- | ---: | ---: | --- |
| `dart:convert` | 32 | 1.02x | 引き分け |
| 手書き | 47 | 1.02x | 引き分け |
| `package:base32` | 10 | 1.04x | 引き分け |
| `package:convert` | 10 | **0.67x** | AOT の勝ち |
| **convertlib** | 79 | **1.39x** | JIT の勝ち |

「Dart は AOT の方が速い」も「JIT の方が速い」も、定常スループットに関しては
支持されない。**コード次第**である。convertlib の 1.39x が唯一の外れ値で、この差の
正体を追ったのが今回の調査だった。

## 3. AOT が明確に勝つ軸(実測)

| | JIT | AOT |
| --- | ---: | ---: |
| プロセス起動(`--help` まで) | 460〜500 ms | **20 ms**(23倍) |
| hex decode 64 KiB の 1 回目 | 2,087 µs | **1,057 µs**(2倍) |
| 2〜10 回目 | **556 µs** | 829 µs |
| 11〜100 回目 | **346 µs** | 538 µs |
| 1001〜10000 回目 | **312 µs** | 360 µs |

逆転は 10〜100 回目あたりで起きる。**短命なプロセスなら往復で AOT が勝ち**、長時間
走らせるなら定常値が効いてくる。なお AOT にもウォームアップはある(538 → 360 µs)
が、これはコンパイルではなくキャッシュや分岐予測が暖まる分である。

計測に使ったのは `benchmark/probe_warmup.dart`。

## 4. convertlib の方向別の傾向

| | AOT/JIT | 内容 |
| --- | ---: | --- |
| encode(hex 以外) | 0.85〜1.08 | 変化なし。convertlib の優位はそのまま残る |
| **decode(全形式)** | **1.5〜3.2x** | **全面的に劣化**。競合への優位が消え、多くで逆転される |
| hex encode | 1.24〜3.41 | encode で唯一劣化。サイズが大きいほど拡大 |
| utf8 encode | 0.79〜1.26 | ASCII・絵文字は AOT の方が速い |
| bigint | 1.23〜1.62 | 両方向とも劣化(手書きも同様なので `BigInt` ランタイム側の要因) |
| constant_time | 1.00〜1.03 | 完全に同じ |

## 5. 再現性

ベンチマーク全体を JIT・AOT ともに再実行した(`rerun/`)。convertlib の 79 ケース中
**77 ケースが ±3% 以内で一致**した。ずれた 2 件は初回が外れ値で、劣化の向きと桁は
変わらない。

| ケース | 初回 | 再計測 |
| --- | ---: | ---: |
| hex decode 64 KiB | 2.74x | 2.22x |
| binary decode 4 KiB | 3.75x | 3.16x |

競合実装側の結果も同様に再現した。**結論は 2 回の独立した計測で裏付けられている。**

## 6. 原因究明の結果 — ほぼ全部が否定された

当初「AOT には脱最適化がなく投機的最適化ができないため、`String.codeUnits` 経由の
多態なアクセスが最適化できない」と推測したが、**実験で否定された**。

否定された仮説:

- `CodeUnits` 遅延ビュー経由であること(実体化しても改善は約 20% どまり、完全に
  排除しても劣化する)
- リンクするクラスが増えたことによる脱仮想化の失敗(他パッケージを到達可能に
  しても、逆に base16 だけを深く import しても変化なし)
- 受け手の静的型、例外パス、仮想呼び出し、インライン化の抑止、
  `Converter` + covariant の継承構造、親クラスの具象 `convert`、`extension` メソッド、
  言語バージョン(2.19)

convertlib の decode ループを 1 文字ずつ写した複製に、疑わしい要素を 1 つずつ足して
いったが、**どれも劣化を再現しなかった**(すべて AOT 10.1〜10.7 µs、本体は 23 µs)。

回答が出たのは 1 つだけである。**hex encode の劣化は `String.fromCharCodes` では
なく変換ループそのもの**(String 生成は全体の 2.7%)。

詳細は [aot-gap-investigation.md](aot-gap-investigation.md) を参照。

## 7. 残った未解明の中核

到達した最小再現は 2 つ。

**(a) 同一ソースでも、依存パッケージ側にあると遅い**

convertlib のソースを import パス以外 1 バイトも変えずにコピーし、同一バイナリ・
同一プロセスで、出力がバイト単位で一致することを確認した上で A/B した結果:

| | JIT | AOT |
| --- | ---: | ---: |
| `package:convertlib` 側 | 8.57 µs | **23.45 µs** |
| コピーをエントリ側に置いたもの | 8.90 µs | **10.09 µs** |

**(b) プログラム全体の規模で 2 倍変わる**

同じ hex decode 64 KiB が、convertlib しか import しない小さなプログラムでは
AOT 345 µs、ベンチマーク本体では 667 µs。JIT 側は 224 / 244 µs でほぼ不変。

どちらも「投機的最適化の有無」では説明できない。AOT コンパイラの全プログラム処理に
起因する挙動と考えられるが、**原因は特定できていない**。次の一手は IL の確認だが、
`--print-flow-graph-optimized` は `dart compile` 同梱の product 版 `gen_snapshot` では
出力されず、debug/release ビルドの SDK が必要になる。

## 8. 言えること / 言えないこと

**言えること**

- convertlib の decode は AOT で 1.5〜3.2 倍遅く、競合への優位を失う(再現性あり)
- encode は AOT でも優位が残る
- AOT のコード生成が一般に劣っているわけではない(`package:convert` は AOT の方が速い)
- 起動と初回呼び出しは AOT が圧倒的に速い

**言えないこと**

- この劣化の原因。特に「JIT の投機的最適化が効いているから」という説明は
  **実験で否定済み**であり、根拠として使えない
- 劣化幅の絶対値。プログラム規模に依存するため、[aot/summary.md](aot/summary.md) の
  数値はベンチマーク本体という比較的大きなプログラムでの値である

## 9. 実務的な含意

1. **AOT で出荷するなら JIT の数字で判断しない**。Flutter の release ビルド、
   コンパイル済み CLI・サーバはすべて AOT である
2. **AOT のマイクロベンチマークも当てにしない**。実アプリの規模で測り直す価値が
   ある(今回 2 倍振れた)
3. **AOT + decode 中心のワークロードなら選択を見直す余地がある**。AOT では
   hex decode は `package:convert` が 1.3〜1.8 倍、base64 decode は `dart:convert` が
   1.2〜1.4 倍、binary/octal decode は素朴な手書きの方が速い。一方 base32 は AOT でも
   convertlib が `package:base32` に 11〜13 倍差で圧勝する
4. **utf8 の ASCII decode は AOT で `dart:convert` が 11 倍速い**。ASCII 専用の
   高速パスがあるためで、JIT のとき(7 倍)より差が開く

## 10. 検証に使ったコード

| ファイル | 用途 |
| --- | --- |
| `benchmark/main.dart` | 本体ベンチマーク |
| `benchmark/probe_aot_gap.dart` | AOT 劣化の原因切り分け(12 実験) |
| `benchmark/vendor/` | convertlib 3.6.1 のソースコピー(7 節の A/B 用) |
| `benchmark/probe_warmup.dart` | ウォームアップ曲線の計測(3 節) |
| `benchmark/probe_direct.dart` | 直書きループとクロージャ越しの比較 |
