## ベンチマークの要約(AOT)

Apple M3 Pro / macOS 26.5.2 / Dart 3.12.2、**AOT** 実行での傾向を要約して記載します。
各フォーマットをconvertlibに対する時間比として表し、`相対値`として表記しています。

```
相対値 = 比較相手の実行速度(µs/op) / convertlibの実行速度(µs/op)
```

### 結果

**hex**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | `package:convert` | 0.59〜1.06 | ➖ サイズ依存(※1) |
| encode | 手書き | 0.42〜1.03 | ➖ サイズ依存(※1) |
| decode | `package:convert` | **0.56〜0.78** | ❌ `package:convert` が 1.3〜1.8 倍速い |
| decode | 手書き | **0.59〜0.73** | ❌ 手書きが 1.4〜1.7 倍速い |

**base64**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | `dart:convert` | 1.24〜1.30 | ✅ convertlib |
| decode | `dart:convert` | **0.72〜0.84** | ❌ `dart:convert` が 1.2〜1.4 倍速い |

**base64Url**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | `dart:convert` | 1.25〜1.31 | ✅ convertlib |
| decode | `dart:convert` | **0.74〜0.82** | ❌ `dart:convert` が 1.2〜1.4 倍速い |

**base32**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | `package:base32` | 26.0〜9,232 | ✅ convertlib(※2) |
| encode | 手書き | 1.85〜2.81 | ✅ convertlib |
| decode | `package:base32` | 10.9〜13.4 | ✅ convertlib |
| decode | 手書き | 0.96〜1.13 | ➖ ほぼ互角 |

**binary**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | 手書き | 2.94〜3.44 | ✅ convertlib |
| decode | 手書き | **0.41〜0.58** | ❌ 手書きが 1.7〜2.4 倍速い |

**octal**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | 手書き | 2.23〜2.51 | ✅ convertlib |
| decode | 手書き | **0.60〜0.80** | ❌ 手書きが 1.3〜1.7 倍速い |

**utf8**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | `dart:convert`(ASCII) | 1.43〜1.57 | ✅ convertlib |
| encode | `dart:convert`(日本語) | 1.22〜1.23 | ✅ convertlib |
| encode | `dart:convert`(絵文字) | 1.17〜1.21 | ✅ convertlib |
| decode | `dart:convert`(ASCII) | **0.09** | ❌ `dart:convert` が 11 倍速い(※3) |
| decode | `dart:convert`(日本語) | 1.03〜1.15 | ✅ convertlib(僅差) |
| decode | `dart:convert`(絵文字) | 0.85〜0.95 | ➖ ほぼ互角 |

**bigint**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| encode | 手書き | **0.42〜0.50** | ❌ 手書きが 2.0〜2.4 倍速い(※4) |
| decode | 手書き | 1.06〜1.15 | ✅ convertlib(僅差) |

**constant_time**
| 方向 | 比較相手 | 相対値 | 判定 |
| --- | --- | ---: | --- |
| compare | 手書き | 1.00〜1.02 | ➖ 差なし |

補足:

- ※1 hex の encode は小サイズ(16 B〜4 KiB)では ±10% の差だが、64 KiB 以上で
  convertlib が失速する。1 MiB では手書きの 427 MB/s に対し convertlib は
  179 MB/s(相対値 0.42)。convertlib 自身のスループットが 256 B の 483 MB/s
  から 1 MiB で 179 MB/s まで落ちており、大きな入力でのメモリ挙動が原因と思われる
- ※2 `package:base32` の `encode` は文字列の `+=` 連結でオーダーが O(n²) になって
  いる。1 MiB では 1 op あたり 14.5 秒(0.1 MB/s)で、9,000 倍以上遅い
- ※3 `dart:convert` は ASCII 専用の高速パスを持つため。AOT では 2,600〜2,800 MB/s
  出ており、JIT の 7 倍差から 11 倍差に開いている。マルチバイトが混ざるとこの優位は
  消える
- ※4 バイト列 → `BigInt` は手書きの「16 進文字列 + `BigInt.parse`」の方が速い。
  JIT の 1.6 倍差から AOT では 2.4 倍まで差が開く

### JIT 版との差分

JIT では **すべての encode/decode がほぼ convertlib 優位**(例外は utf8 ASCII decode と
bigint encode のみ)でしたが、AOT では **decode 系がほぼ全面的に逆転** します。

| 項目 | JIT | AOT |
| --- | ---: | ---: |
| hex decode(vs `package:convert`) | 2.02〜3.22 ✅ | 0.56〜0.78 ❌ |
| hex encode(vs 手書き) | 1.45〜1.48 ✅ | 0.42〜1.03 ➖ |
| base64 decode | 1.35 ✅ | 0.72〜0.84 ❌ |
| base32 decode(vs 手書き) | 2.02〜2.16 ✅ | 0.96〜1.13 ➖ |
| binary decode(vs 手書き) | 1.17〜2.70 ✅ | 0.41〜0.58 ❌ |
| octal decode(vs 手書き) | 1.29〜1.36 ✅ | 0.60〜0.80 ❌ |

convertlib が AOT でも安定して勝つのは **encode 側(base64 / base64Url / base32 /
binary / octal / utf8)** と **`package:base32` 比の base32 全般** に限られます。
JIT の結果だけで性能を判断すると AOT 本番環境では実態と乖離するため、両方の掲載が
必要です。
