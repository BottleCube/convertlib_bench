# convertlib benchmark results

| key | value |
| --- | --- |
| date | 2026-08-05T14:38:33.086005 |
| dart | 3.12.2 (JIT) |
| os | macos Version 26.5.2 (Build 25F84) |
| cpu | Apple M3 Pro (12 logical cores) |
| timing | 100 ms warmup + 500 ms measurement per case |

`rel` is µs/op divided by convertlib's µs/op for the same conversion and payload: below 1.00 means faster than convertlib.


## hex / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.034 | 29,231,481 | 467.7 | 1.00x |
| 16 B | package:convert | 0.040 | 24,922,938 | 398.8 | 1.17x |
| 16 B | handwritten | 0.042 | 23,564,314 | 377.0 | 1.24x |
| 256 B | convertlib | 0.358 | 2,797,105 | 716.1 | 1.00x |
| 256 B | package:convert | 0.424 | 2,359,289 | 604.0 | 1.19x |
| 256 B | handwritten | 0.488 | 2,048,968 | 524.5 | 1.37x |
| 4 KiB | convertlib | 5.609 | 178,300 | 730.3 | 1.00x |
| 4 KiB | package:convert | 7.443 | 134,346 | 550.3 | 1.33x |
| 4 KiB | handwritten | 7.679 | 130,233 | 533.4 | 1.37x |
| 64 KiB | convertlib | 87.450 | 11,435 | 749.4 | 1.00x |
| 64 KiB | package:convert | 136.636 | 7,319 | 479.6 | 1.56x |
| 64 KiB | handwritten | 129.389 | 7,729 | 506.5 | 1.48x |
| 1 MiB | convertlib | 1,741 | 574 | 602.3 | 1.00x |
| 1 MiB | package:convert | 6,180 | 162 | 169.7 | 3.55x |
| 1 MiB | handwritten | 2,519 | 397 | 416.3 | 1.45x |

## hex / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.044 | 22,599,002 | 361.6 | 1.00x |
| 16 B | package:convert | 0.103 | 9,724,486 | 155.6 | 2.32x |
| 16 B | handwritten | 0.068 | 14,699,622 | 235.2 | 1.54x |
| 256 B | convertlib | 0.610 | 1,638,807 | 419.5 | 1.00x |
| 256 B | package:convert | 1.447 | 691,028 | 176.9 | 2.37x |
| 256 B | handwritten | 1.003 | 997,070 | 255.2 | 1.64x |
| 4 KiB | convertlib | 10.495 | 95,284 | 390.3 | 1.00x |
| 4 KiB | package:convert | 29.482 | 33,919 | 138.9 | 2.81x |
| 4 KiB | handwritten | 15.991 | 62,534 | 256.1 | 1.52x |
| 64 KiB | convertlib | 243.935 | 4,099 | 268.7 | 1.00x |
| 64 KiB | package:convert | 785.607 | 1,273 | 83.4 | 3.22x |
| 64 KiB | handwritten | 523.543 | 1,910 | 125.2 | 2.15x |
| 1 MiB | convertlib | 6,672 | 150 | 157.2 | 1.00x |
| 1 MiB | package:convert | 13,447 | 74 | 78.0 | 2.02x |
| 1 MiB | handwritten | 8,602 | 116 | 121.9 | 1.29x |

## base64 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.033 | 29,879,048 | 478.1 | 1.00x |
| 16 B | dart:convert | 0.048 | 20,705,169 | 331.3 | 1.44x |
| 256 B | convertlib | 0.324 | 3,085,986 | 790.0 | 1.00x |
| 256 B | dart:convert | 0.413 | 2,421,187 | 619.8 | 1.27x |
| 4 KiB | convertlib | 4.914 | 203,489 | 833.5 | 1.00x |
| 4 KiB | dart:convert | 6.222 | 160,732 | 658.4 | 1.27x |
| 64 KiB | convertlib | 78.020 | 12,817 | 840.0 | 1.00x |
| 64 KiB | dart:convert | 97.307 | 10,277 | 673.5 | 1.25x |
| 1 MiB | convertlib | 1,461 | 685 | 717.9 | 1.00x |
| 1 MiB | dart:convert | 1,804 | 554 | 581.3 | 1.24x |

## base64 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.042 | 23,915,584 | 382.6 | 1.00x |
| 16 B | dart:convert | 0.051 | 19,434,257 | 310.9 | 1.23x |
| 256 B | convertlib | 0.362 | 2,761,066 | 706.8 | 1.00x |
| 256 B | dart:convert | 0.485 | 2,061,728 | 527.8 | 1.34x |
| 4 KiB | convertlib | 5.489 | 182,170 | 746.2 | 1.00x |
| 4 KiB | dart:convert | 7.263 | 137,678 | 563.9 | 1.32x |
| 64 KiB | convertlib | 85.817 | 11,653 | 763.7 | 1.00x |
| 64 KiB | dart:convert | 116.042 | 8,618 | 564.8 | 1.35x |
| 1 MiB | convertlib | 1,435 | 697 | 730.8 | 1.00x |
| 1 MiB | dart:convert | 1,942 | 515 | 539.8 | 1.35x |

## base64url / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.034 | 29,570,850 | 473.1 | 1.00x |
| 16 B | dart:convert | 0.049 | 20,554,346 | 328.9 | 1.44x |
| 256 B | convertlib | 0.322 | 3,101,886 | 794.1 | 1.00x |
| 256 B | dart:convert | 0.418 | 2,392,874 | 612.6 | 1.30x |
| 4 KiB | convertlib | 4.919 | 203,274 | 832.6 | 1.00x |
| 4 KiB | dart:convert | 6.208 | 161,071 | 659.7 | 1.26x |
| 64 KiB | convertlib | 76.421 | 13,085 | 857.6 | 1.00x |
| 64 KiB | dart:convert | 97.383 | 10,269 | 673.0 | 1.27x |
| 1 MiB | convertlib | 1,454 | 688 | 721.3 | 1.00x |
| 1 MiB | dart:convert | 1,792 | 558 | 585.1 | 1.23x |

## base64url / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.042 | 24,051,746 | 384.8 | 1.00x |
| 16 B | dart:convert | 0.052 | 19,401,835 | 310.4 | 1.24x |
| 256 B | convertlib | 0.362 | 2,762,023 | 707.1 | 1.00x |
| 256 B | dart:convert | 0.485 | 2,063,407 | 528.2 | 1.34x |
| 4 KiB | convertlib | 5.472 | 182,759 | 748.6 | 1.00x |
| 4 KiB | dart:convert | 7.302 | 136,942 | 560.9 | 1.33x |
| 64 KiB | convertlib | 85.986 | 11,630 | 762.2 | 1.00x |
| 64 KiB | dart:convert | 116.846 | 8,558 | 560.9 | 1.36x |
| 1 MiB | convertlib | 1,436 | 696 | 730.0 | 1.00x |
| 1 MiB | dart:convert | 1,943 | 515 | 539.6 | 1.35x |

## base32 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.038 | 26,550,536 | 424.8 | 1.00x |
| 16 B | package:base32 | 1.023 | 977,108 | 15.6 | 27.17x |
| 16 B | handwritten | 0.071 | 14,042,351 | 224.7 | 1.89x |
| 256 B | convertlib | 0.358 | 2,792,204 | 714.8 | 1.00x |
| 256 B | package:base32 | 15.589 | 64,147 | 16.4 | 43.53x |
| 256 B | handwritten | 0.923 | 1,083,084 | 277.3 | 2.58x |
| 4 KiB | convertlib | 5.534 | 180,704 | 740.2 | 1.00x |
| 4 KiB | package:base32 | 335.578 | 2,980 | 12.2 | 60.64x |
| 4 KiB | handwritten | 14.550 | 68,727 | 281.5 | 2.63x |
| 64 KiB | convertlib | 86.873 | 11,511 | 754.4 | 1.00x |
| 64 KiB | package:base32 | 27,199 | 37 | 2.4 | 313.09x |
| 64 KiB | handwritten | 242.957 | 4,116 | 269.7 | 2.80x |
| 1 MiB | convertlib | 1,651 | 606 | 635.2 | 1.00x |
| 1 MiB | package:base32 | 23,826,272 | 0 | 0.0 | 14433.54x |
| 1 MiB | handwritten | 4,729 | 211 | 221.7 | 2.86x |

## base32 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.054 | 18,593,365 | 297.5 | 1.00x |
| 16 B | package:base32 | 0.824 | 1,213,603 | 19.4 | 15.32x |
| 16 B | handwritten | 0.058 | 17,111,368 | 273.8 | 1.09x |
| 256 B | convertlib | 0.425 | 2,350,328 | 601.7 | 1.00x |
| 256 B | package:base32 | 8.760 | 114,151 | 29.2 | 20.59x |
| 256 B | handwritten | 0.786 | 1,272,807 | 325.8 | 1.85x |
| 4 KiB | convertlib | 6.315 | 158,348 | 648.6 | 1.00x |
| 4 KiB | package:base32 | 136.253 | 7,339 | 30.1 | 21.58x |
| 4 KiB | handwritten | 12.543 | 79,727 | 326.6 | 1.99x |
| 64 KiB | convertlib | 101.164 | 9,885 | 647.8 | 1.00x |
| 64 KiB | package:base32 | 2,698 | 371 | 24.3 | 26.67x |
| 64 KiB | handwritten | 204.052 | 4,901 | 321.2 | 2.02x |
| 1 MiB | convertlib | 1,682 | 595 | 623.4 | 1.00x |
| 1 MiB | package:base32 | 44,325 | 23 | 23.7 | 26.35x |
| 1 MiB | handwritten | 3,635 | 275 | 288.5 | 2.16x |

## binary / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.070 | 14,323,576 | 229.2 | 1.00x |
| 16 B | handwritten | 0.227 | 4,413,043 | 70.6 | 3.25x |
| 256 B | convertlib | 0.937 | 1,067,506 | 273.3 | 1.00x |
| 256 B | handwritten | 3.322 | 300,984 | 77.1 | 3.55x |
| 4 KiB | convertlib | 14.281 | 70,024 | 286.8 | 1.00x |
| 4 KiB | handwritten | 53.786 | 18,592 | 76.2 | 3.77x |
| 64 KiB | convertlib | 362.786 | 2,756 | 180.6 | 1.00x |
| 64 KiB | handwritten | 1,030 | 971 | 63.6 | 2.84x |

## binary / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.128 | 7,822,080 | 125.2 | 1.00x |
| 16 B | handwritten | 0.144 | 6,960,938 | 111.4 | 1.12x |
| 256 B | convertlib | 2.030 | 492,564 | 126.1 | 1.00x |
| 256 B | handwritten | 2.564 | 390,018 | 99.8 | 1.26x |
| 4 KiB | convertlib | 35.636 | 28,061 | 114.9 | 1.00x |
| 4 KiB | handwritten | 96.175 | 10,398 | 42.6 | 2.70x |
| 64 KiB | convertlib | 1,792 | 558 | 36.6 | 1.00x |
| 64 KiB | handwritten | 2,100 | 476 | 31.2 | 1.17x |

## octal / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.036 | 27,496,707 | 439.9 | 1.00x |
| 16 B | handwritten | 0.055 | 18,292,503 | 292.7 | 1.50x |
| 256 B | convertlib | 0.406 | 2,462,630 | 630.4 | 1.00x |
| 256 B | handwritten | 0.690 | 1,449,933 | 371.2 | 1.70x |
| 4 KiB | convertlib | 6.349 | 157,502 | 645.1 | 1.00x |
| 4 KiB | handwritten | 11.488 | 87,046 | 356.5 | 1.81x |
| 64 KiB | convertlib | 95.728 | 10,446 | 684.6 | 1.00x |
| 64 KiB | handwritten | 173.800 | 5,754 | 377.1 | 1.82x |

## octal / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.041 | 24,626,297 | 394.0 | 1.00x |
| 16 B | handwritten | 0.047 | 21,125,076 | 338.0 | 1.17x |
| 256 B | convertlib | 0.523 | 1,911,370 | 489.3 | 1.00x |
| 256 B | handwritten | 0.653 | 1,531,982 | 392.2 | 1.25x |
| 4 KiB | convertlib | 7.997 | 125,053 | 512.2 | 1.00x |
| 4 KiB | handwritten | 10.317 | 96,929 | 397.0 | 1.29x |
| 64 KiB | convertlib | 126.470 | 7,907 | 518.2 | 1.00x |
| 64 KiB | handwritten | 172.459 | 5,798 | 380.0 | 1.36x |

## utf8 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.322 | 3,102,319 | 868.6 | 1.00x |
| ascii/280 B | dart:convert | 0.517 | 1,934,505 | 541.7 | 1.60x |
| ascii/64 KiB | convertlib | 92.786 | 10,777 | 706.7 | 1.00x |
| ascii/64 KiB | dart:convert | 114.188 | 8,757 | 574.3 | 1.23x |
| ja/300 B | convertlib | 0.230 | 4,342,558 | 1,303 | 1.00x |
| ja/300 B | dart:convert | 0.511 | 1,955,524 | 586.7 | 2.22x |
| ja/64 KiB | convertlib | 45.468 | 21,994 | 1,443 | 1.00x |
| ja/64 KiB | dart:convert | 105.628 | 9,467 | 621.0 | 2.32x |
| emoji/300 B | convertlib | 0.390 | 2,562,854 | 768.9 | 1.00x |
| emoji/300 B | dart:convert | 0.524 | 1,908,397 | 572.5 | 1.34x |
| emoji/64 KiB | convertlib | 85.267 | 11,728 | 768.8 | 1.00x |
| emoji/64 KiB | dart:convert | 110.344 | 9,063 | 594.1 | 1.29x |

## utf8 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.734 | 1,363,115 | 381.7 | 1.00x |
| ascii/280 B | dart:convert | 0.110 | 9,092,924 | 2,546 | 0.15x |
| ascii/64 KiB | convertlib | 163.462 | 6,118 | 401.2 | 1.00x |
| ascii/64 KiB | dart:convert | 22.350 | 44,742 | 2,934 | 0.14x |
| ja/300 B | convertlib | 0.375 | 2,667,848 | 800.4 | 1.00x |
| ja/300 B | dart:convert | 0.456 | 2,191,930 | 657.6 | 1.22x |
| ja/64 KiB | convertlib | 70.109 | 14,263 | 935.7 | 1.00x |
| ja/64 KiB | dart:convert | 100.431 | 9,957 | 653.2 | 1.43x |
| emoji/300 B | convertlib | 0.546 | 1,831,384 | 549.4 | 1.00x |
| emoji/300 B | dart:convert | 0.458 | 2,182,213 | 654.7 | 0.84x |
| emoji/64 KiB | convertlib | 109.401 | 9,141 | 599.2 | 1.00x |
| emoji/64 KiB | dart:convert | 101.170 | 9,884 | 647.9 | 0.92x |

## bigint / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 1.297 | 771,235 | 12.3 | 1.00x |
| 16 B | handwritten | 0.843 | 1,186,710 | 19.0 | 0.65x |
| 256 B | convertlib | 14.799 | 67,571 | 17.3 | 1.00x |
| 256 B | handwritten | 8.378 | 119,355 | 30.6 | 0.57x |
| 4 KiB | convertlib | 216.056 | 4,628 | 19.0 | 1.00x |
| 4 KiB | handwritten | 132.646 | 7,539 | 30.9 | 0.61x |

## bigint / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.479 | 2,087,726 | 33.4 | 1.00x |
| 16 B | handwritten | 0.543 | 1,841,014 | 29.5 | 1.13x |
| 256 B | convertlib | 5.456 | 183,268 | 46.9 | 1.00x |
| 256 B | handwritten | 6.426 | 155,628 | 39.8 | 1.18x |
| 4 KiB | convertlib | 80.505 | 12,422 | 50.9 | 1.00x |
| 4 KiB | handwritten | 95.878 | 10,430 | 42.7 | 1.19x |

## constant_time / compare

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.013 | 77,946,727 | 1,247 | 1.00x |
| 16 B | handwritten | 0.013 | 77,806,631 | 1,245 | 1.00x |
| 256 B | convertlib | 0.149 | 6,697,147 | 1,714 | 1.00x |
| 256 B | handwritten | 0.150 | 6,669,989 | 1,708 | 1.00x |
| 4 KiB | convertlib | 2.259 | 442,772 | 1,814 | 1.00x |
| 4 KiB | handwritten | 2.254 | 443,633 | 1,817 | 1.00x |
| 64 KiB | convertlib | 38.824 | 25,758 | 1,688 | 1.00x |
| 64 KiB | handwritten | 38.472 | 25,993 | 1,703 | 0.99x |
| 1 MiB | convertlib | 612.086 | 1,634 | 1,713 | 1.00x |
| 1 MiB | handwritten | 615.983 | 1,623 | 1,702 | 1.01x |
