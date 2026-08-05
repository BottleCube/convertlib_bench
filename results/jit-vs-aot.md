## ベンチマークの要約(convertlib: JIT vs AOT)

Apple M3 Pro / macOS 26.5.2 / Dart 3.12.2、**convertlib 同士**で JIT 実行と AOT 実行を
比較した傾向を要約して記載します。JIT の実行時間を基準にした比を `相対値` と表記します。

```
相対値 = AOTの実行速度(µs/op) / JITの実行速度(µs/op)
```

1.00 未満なら AOT が速く、1.00 超なら JIT が速いことを意味します。

### 結果

**hex**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | **1.24〜3.35** | ❌ JIT が速い(サイズが大きいほど差が拡大・※1) |
| decode | **1.75〜2.68** | ❌ JIT が 1.8〜2.7 倍速い(※2) |

**base64**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | 0.94〜1.02 | ➖ 差なし |
| decode | **1.57〜2.26** | ❌ JIT が 1.6〜2.3 倍速い |

**base64Url**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | 0.91〜1.02 | ➖ 差なし |
| decode | **1.55〜2.25** | ❌ JIT が 1.6〜2.3 倍速い |

**base32**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | 0.95〜1.01 | ➖ 差なし |
| decode | **1.52〜2.41** | ❌ JIT が 1.5〜2.4 倍速い |

**binary**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | 0.85〜1.06 | ➖ 差なし |
| decode | **1.60〜3.16** | ❌ JIT が 1.6〜3.2 倍速い(※2) |

**octal**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | 0.92〜1.07 | ➖ 差なし |
| decode | **2.27〜2.40** | ❌ JIT が 2.3〜2.4 倍速い |

**utf8**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode(ASCII) | 0.83〜0.98 | ✅ AOT(64 KiB で 1.2 倍) |
| encode(日本語) | 1.16〜1.18 | ❌ JIT が僅かに速い |
| encode(絵文字) | 0.79〜0.86 | ✅ AOT(1.2〜1.3 倍) |
| decode(ASCII) | **1.62〜1.63** | ❌ JIT が 1.6 倍速い |
| decode(日本語) | **1.36〜1.44** | ❌ JIT が 1.4 倍速い |
| decode(絵文字) | 1.23 | ❌ JIT が僅かに速い |

**bigint**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| encode | **1.23〜1.43** | ❌ JIT が速い |
| decode | **1.36〜1.62** | ❌ JIT が速い |

**constant_time**
| 方向 | 相対値 | 判定 |
| --- | ---: | --- |
| compare | 0.95〜1.03 | ➖ 差なし |

補足:

- ※2 この 2 つは初回計測の値(hex decode 64 KiB で 2.74、binary decode 4 KiB で
  3.75)が外れ値で、再計測では 2.22 / 3.16 だった。表は再計測後の値。詳細は
  「再現性の確認」を参照
- ※1 hex の encode は 16 B で 1.24 倍差だが、64 KiB で 2.92 倍、1 MiB で 3.35 倍まで
  開く(JIT 1,741 µs → AOT 5,835 µs、602 MB/s → 180 MB/s)。他フォーマットの encode が
  AOT でも等速なのに hex だけ落ちるため、hex encode 固有の実装が JIT の最適化に
  依存していると考えられる

### 全体の傾向

- **decode は全フォーマットで AOT が遅い**(1.2〜3.2 倍)。AOT 版の要約で decode が
  ほぼ全面的に競合へ逆転された直接の原因はこれである。**ただし理由は特定できて
  いない**(下記)
- **encode は hex を除きほぼ等速**(相対値 0.85〜1.08)。base64 / base64Url / base32 /
  binary / octal は JIT でも AOT でも変わらず、convertlib の優位がそのまま残る
- **utf8 encode は ASCII と絵文字で AOT が有利**。64 KiB で ASCII 0.83、絵文字 0.79 と
  AOT が 1.2〜1.3 倍速い。一方で日本語は 1.16〜1.18 と逆になる
- **constant_time は差なし**(0.95〜1.03)。`Uint8List` を舐めるだけのループで、
  JIT・AOT どちらでも同じコードに落ちていると見られる
- **bigint は convertlib が両方向とも AOT で 1.2〜1.6 倍遅い**。ただし方向で事情が
  違う。decode(`BigInt` → バイト列)は手書きも 1.3〜1.5 倍劣化するので `BigInt`
  ランタイム側の要因と考えられるが、encode(バイト列 → `BigInt`)は手書きが
  0.94〜0.99 と劣化しないため convertlib 側の要因である

### decode が AOT で遅い理由について

当初この文書には「convertlib の decode 系は JIT のプロファイル最適化に強く依存して
おり、AOT では素直なコードに負ける」と書いていたが、**この説明は実験で否定された**。
受け手の型を実体化した `Uint8List` に固定しても、リンク集合を変えても、仮想呼び出しを
外しても劣化は再現せず、投機的最適化の有無では説明できない挙動
(同一ソースでも依存パッケージ側にあると 2.3 倍遅い、プログラム規模で 2 倍振れる)に
行き着いている。

現時点で**原因は未特定**である。経緯と最小再現は
[aot-gap-investigation.md](aot-gap-investigation.md) を参照。

### 再現性の確認

ベンチマーク全体を JIT・AOT ともにもう一度実行し、傾向が再現するか確認した
(出力は `results/rerun/jit/` と `results/rerun/aot/`)。

- convertlib の 79 ケース中、AOT/JIT 比が初回と 5% 以上ずれたのは **2 ケースのみ**
  (hex decode 64 KiB: 2.74 → 2.22、binary decode 4 KiB: 3.75 → 3.16)。いずれも
  初回が外れ値で、劣化の向きと桁は変わらない
- 残り 77 ケースは ±3% 以内で一致した

実装ごとに AOT/JIT 比の中央値を取ると、convertlib だけが突出していることが
はっきりする。

| 実装 | ケース数 | 中央値 | 最大 | 最小 |
| --- | ---: | ---: | ---: | ---: |
| **convertlib** | 79 | **1.39x** | 3.41x | 0.81x |
| `dart:convert` | 32 | 1.02x | 1.24x | 0.65x |
| `package:convert` | 10 | **0.67x** | 1.19x | 0.59x |
| `package:base32` | 10 | 1.04x | 1.30x | 0.63x |
| 手書き | 47 | 1.02x | 1.51x | 0.55x |

convertlib 以外はどれも「AOT でも JIT と同等か、むしろ速い」に収まっている。
AOT のコード生成が一般に劣っているのではなく、convertlib 固有の現象であることが
2 回の独立した計測で裏付けられた。原因の調査は
[aot-gap-investigation.md](aot-gap-investigation.md) を参照。

### convertlib 自身のスループット(MB/s)比較(抜粋・1 MiB / 64 KiB)

| 変換 | 方向 | JIT | AOT |
| --- | --- | ---: | ---: |
| hex | encode(1 MiB) | 602.3 | 179.7 |
| hex | decode(1 MiB) | 157.2 | 89.8 |
| base64 | encode(1 MiB) | 717.9 | 728.2 |
| base64 | decode(1 MiB) | 730.8 | 333.4 |
| base32 | encode(1 MiB) | 635.2 | 669.1 |
| base32 | decode(1 MiB) | 623.4 | 267.0 |
| binary | encode(64 KiB) | 180.6 | 211.8 |
| binary | decode(64 KiB) | 36.6 | 21.6 |
| octal | encode(64 KiB) | 684.6 | 638.3 |
| octal | decode(64 KiB) | 518.2 | 215.9 |
| utf8 | encode(ascii/64 KiB) | 706.7 | 849.6 |
| utf8 | decode(ascii/64 KiB) | 401.2 | 245.8 |
| constant_time | compare(1 MiB) | 1,713 | 1,780 |
