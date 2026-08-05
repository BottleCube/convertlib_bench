# なぜ JIT の方が速いケースが多いのか — 推測と検証

`results/jit-vs-aot.md` で、convertlib の decode 系が AOT で軒並み 1.2〜3.8 倍遅く
なることが分かった。その原因を推測し、実験で検証した記録。

**結論を先に書くと、当初立てた推測はすべて実験で否定された。** 最終的に、原因を
「コードの書き方」に帰することはできず、`package:convertlib` から来たコードだけが
AOT で遅くなるという再現可能な最小ケースに到達した。以下はその経緯と、次に何を
調べるべきかの記録である。

計測環境は本体ベンチマークと同じ(Apple M3 Pro / macOS 26.5.2 / Dart 3.12.2、
ウォームアップ 100 ms + 計測 500 ms)。数値は同じ条件でも実行ごとに ±6% 程度
ばらつくので、2 倍未満の差は誤差として扱っている。

---

## 1. 切り分け: 劣化しているのは convertlib だけ

まず「AOT が一般に遅い」のかを確認するため、全実装の AOT/JIT 比を出した
(1.00 未満なら AOT が速い)。

| ケース | convertlib | 競合 |
| --- | ---: | ---: |
| hex decode (4 KiB) | 2.75x ❌ | `package:convert` **0.55x** ✅ |
| base64 decode (4 KiB) | 2.26x ❌ | `dart:convert` 1.23x |
| base32 decode (4 KiB) | 2.41x ❌ | 手書き 1.31x |
| binary decode (4 KiB) | 3.16x ❌ | 手書き **0.57x** ✅ |
| octal decode (64 KiB) | 2.40x ❌ | 手書き 1.41x |
| utf8 encode (ja/64 KiB) | 1.18x | `dart:convert` **0.62x** ✅ |

AOT のコード生成が一般に劣っているなら、`package:convert` の hex decode が AOT で
1.8 倍速くなる説明がつかない。**劣化は convertlib 固有**である。

この傾向はベンチマーク全体を再実行しても変わらなかった(`results/rerun/`)。
実装ごとの AOT/JIT 比の中央値は convertlib が 1.39x、`dart:convert` 1.02x、
`package:convert` 0.67x、`package:base32` 1.04x、手書き 1.02x。詳細は
[jit-vs-aot.md](jit-vs-aot.md) の「再現性の確認」を参照。

## 2. 当初の推測

convertlib の decode 系は全フォーマットで同じ形をしている。

```dart
// lib/src/base16.dart:71（base32/base2/base8/base64 も同一パターン）
Uint8List fromHex(String input, {Base16Codec? codec}) =>
    codec.decoder.convert(input.codeUnits);
```

`String.codeUnits` は配列を作らず `_string.codeUnitAt(i)` を呼ぶだけの遅延ビュー
(`CodeUnits`)を返す。デコーダの内側ループはその要素を `List<int>` 越しに読む。

```dart
// lib/src/codecs/base16.dart:13-28
extension on List<int> {
  @pragma('vm:prefer-inline')
  int dec(int p) {
    int x = this[p] & 0xFF;       // ← List<int> の呼び出し
    ...
    if (x < 0 || x > 15) throw FormatException('Invalid character at $p');
    return x;
  }
}
```

ここから次の 3 つを推測した。

1. **`CodeUnits` 説** — 1 要素あたり `CodeUnits.[]` → `String.codeUnitAt` の 2 段
   ディスパッチになる。JIT はインラインキャッシュで受け手を `CodeUnits` /
   `_OneByteString` に確定させ両方インライン展開できるが、AOT は脱最適化機構が
   ないため投機できない
2. **encode 側の劣化(hex のみ)は `String.fromCharCodes` か変換ループか**
3. **リンク集合説** — AOT は全プログラム型フロー解析(TFA)頼み。ベンチマークが
   `dart:convert` / `package:convert` / `package:base32` を同時にリンクしている
   ため `List<int>` の実装クラスが増え、脱仮想化に失敗している

推測 1 を支持する状況証拠として、劣化幅が「出力 1 バイトあたりの要素アクセス
回数」に比例して見えた点があった(binary 8 回で 3.75x、base64 4/3 回で 2.26x)。

## 3. 検証

`benchmark/probe_aot_gap.dart` で hex を対象に検証した。variant は実行時引数では
なく `-Dvariant=` の定数で切り替え、**variant ごとに別バイナリ・別プロセス**で
測っている。これは 2 種類の汚染を避けるため。

- JIT: 1 プロセスで複数 variant を測ると、同じ `_Base16Decoder.convert` に複数の
  `List` 実装が渡ってインラインキャッシュがポリモーフィックになる
  (実測で 4 KiB が 10.5µs → 14.2µs に劣化した)
- AOT: プロセスを分けても 1 バイナリに全 variant が残るため、TFA から見た
  `convert` の引数型は常に複数クラスのままで、脱仮想化の有無を比較できない

### 実験結果(hex / 4 KiB / µs/op)

| # | variant | 内容 | JIT | AOT | AOT/JIT |
| --: | --- | --- | ---: | ---: | ---: |
| 1 | `decode/fromHex-string` | 現状の API | 8.25 | 29.04 | 3.52x |
| 1 | `decode/codeunits-view` | `decoder.convert(s.codeUnits)` | 8.27 | 26.81 | 3.24x |
| 1 | `decode/uint8list` | 実体化した `Uint8List` を渡す | 9.11 | 24.02 | 2.64x |
| 1 | `decode/growable-list` | 実体化した `_GrowableList` を渡す | 8.51 | 24.55 | 2.89x |
| 9 | `decode/no-codeunits` | `CodeUnits` を一切生成しない | 8.95 | 23.19 | 2.59x |
| 2 | `encode/toHex` | ループ + `String.fromCharCodes` | 5.59 | 8.61 | 1.54x |
| 2 | `encode/toHexBytes` | ループのみ | 5.36 | 8.42 | 1.57x |
| 2 | `encode/fromCharCodes` | String 生成のみ | 0.22 | 0.23 | 1.04x |
| 4 | `local/listint` | ロジック複製・受け手 `List<int>` | 8.32 | 10.20 | 1.23x |
| 4 | `local/uint8list` | 同・受け手 `Uint8List` | 8.92 | 10.14 | 1.14x |
| 4 | `local/uint8list-nothrow` | 同・例外パスなし | 7.46 | 10.66 | 1.43x |
| 5 | `local/virtual` | 同・仮想呼び出し越し | 8.28 | 10.44 | 1.26x |
| — | `local/never-inline` | 同・インライン化禁止 | 8.32 | 10.17 | 1.22x |
| 6 | `local/converter` | 同・`Converter` + covariant 構造 | 9.09 | 10.18 | 1.12x |
| 7 | `local/fullchain` | 同・継承チェーンを丸ごと複製 | 9.22 | 10.13 | 1.10x |
| 7 | `local/fullchain-noengine` | 同・親の具象 `convert` を除去 | — | 10.14 | — |
| 8 | `local/extension` | 同・`extension` メソッド経由 | — | 10.09 | — |
| 10 | `vendor/decode` | **convertlib のソースを丸ごとコピー** | 8.48 | 10.40 | 1.23x |
| 12 | `deep/base16` | umbrella を経由せず base16 だけ import | — | 21.60 | — |

### 判定

| 推測 | 判定 | 根拠 |
| --- | --- | --- |
| 1. `CodeUnits` 説 | ❌ **否定** | 実体化した `Uint8List` を渡しても 24.0µs。`CodeUnits` を 1 つも生成しない入力でも 23.2µs。寄与は 29.0 → 23.2 の **約 20% にとどまる** |
| 2. encode は String 生成か | ✅ **回答** | `String.fromCharCodes` は AOT でも 0.23µs(全体の 2.7%)。**劣化しているのは変換ループ側** |
| 3. リンク集合説 | ❌ **否定** | `-Dfat=true` で他パッケージの変換を到達可能にしても 28.9µs で変化なし。逆に base16 だけを深く import しても 21.6µs で改善しない |

推測 1 の状況証拠だった「アクセス回数との比例」は、結果的に偶然の一致だった。

### 追加で否定されたもの

原因を絞るため、convertlib の decode ループを 1 文字ずつ写した複製を作り、疑わしい
要素を 1 つずつ足していったが、**どれも劣化を再現しなかった**(すべて AOT 10.1〜
10.7µs)。

- 受け手の静的型(`List<int>` か `Uint8List` か)
- `throw FormatException(...)` の存在(例外パスのレジスタ圧迫)
- 仮想呼び出しを挟むこと
- `@pragma('vm:never-inline')` によるインライン化の抑止
- `dart:convert` の `Converter` を継承し covariant で引数を絞る構造
- 親クラス `BitDecoder` が持つ具象の汎用 `convert`(Iterable を回すビット再パック実装)
- 要素取り出しを無名 `extension` のメソッドにすること

## 4. 残った最小再現

最後に、convertlib の `base16.dart` / `codecs/base16.dart` / `core/{bit,byte,codec}.dart`
を **import パス以外 1 バイトも変えずに** `benchmark/vendor/` へコピーし、同じ計測を
行った。さらに、同一バイナリ・同一プロセス内で、出力の一致を検証した上で A/B した
のが実験 11 である。

| | JIT | AOT |
| --- | ---: | ---: |
| `package:convertlib` の `_Base16Decoder.convert` | 8.57 | **23.45** |
| `benchmark/vendor/` に置いた同一ソース | 8.90 | **10.09** |
| ロジック複製版 | 9.11 | 10.49 |

- ソースは import 文以外 diff ゼロ(検証済み)
- 出力が 1 バイトずつ一致することを実行時に確認済み
- 同じバイナリ、同じプロセス、同じ入力(どちらも `_Uint8List`)
- JIT では 3 者に差がない

つまり **同一ソースが、`package:convertlib` から来た場合だけ AOT で 2.3 倍遅い**。
以下も試したが差は消えなかった。

- 言語バージョン: convertlib は 2.19(`package_config.json`)、本体は 3.9。ベンダー版に
  `// @dart=2.19` を付けても 10.3µs で変化なし
- umbrella export(`convertlib.dart` は全 codec を export する)を経由せず
  `package:convertlib/src/base16.dart` を直接 import しても 21.6µs
- pub-cache に事前コンパイル済みカーネル(`.dill`)等は存在しない

## 5. 現時点の結論

- **AOT が一般に遅いわけではない**。`package:convert` の hex decode や
  `dart:convert` の utf8 encode は AOT の方が速い
- **convertlib の decode が AOT で遅いのは事実**だが、その原因は当初推測した
  `CodeUnits` でもリンク集合でも、コードの書き方でもない
- 原因は「そのコードが依存パッケージ側にあること」に相関しており、これは
  ソースを読むだけでは説明できない。VM/AOT コンパイラ側の挙動と考えられる
- encode 側については明確に答えが出た。hex encode の劣化は `String.fromCharCodes`
  ではなく**変換ループそのもの**である

## 6. 次に調べるなら

1. **IL を見る**。`--print-flow-graph-optimized` は `dart compile` 同梱の product 版
   `gen_snapshot` では出力されない(フラグ自体は受理されるが何も出ない)。
   debug/release ビルドの SDK を用意して `_Base16Decoder.convert` の IL を
   package 版とベンダー版で比較すれば、`[]` が `LoadIndexed` に落ちているか
   ディスパッチのまま残っているかが直接分かる
2. **SDK issue として報告する**。実験 11 がそのまま最小再現になっている
   (同一ソース・同一バイナリ・出力一致で 2.3 倍)
3. **他フォーマットでも同じか確認する**。今回は hex のみ。base32/binary/octal でも
   ベンダー版が速いなら、convertlib 全体に効く一般的な現象ということになる

## 7. 再現方法

```sh
# 1 つの variant を JIT と AOT で測る
fvm dart run -Dvariant=ab/both benchmark/probe_aot_gap.dart
fvm dart compile exe -Dvariant=ab/both benchmark/probe_aot_gap.dart -o build/p_ab
./build/p_ab

# variant の一覧
fvm dart run benchmark/probe_aot_gap.dart
```

**variant ごとに必ず別バイナリを作ること**(3 節の理由による)。
`benchmark/vendor/` は convertlib 3.6.1 のソースのコピーで、実験 10〜11 専用。
`// @dart=2.19` の行は言語バージョンを検証したときの名残で、付けても外しても
結果は変わらない。
