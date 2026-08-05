# convertlib benchmark results

| key | value |
| --- | --- |
| date | 2026-08-05T14:43:40.444551 |
| dart | 3.12.2 (AOT) |
| os | macos Version 26.5.2 (Build 25F84) |
| cpu | Apple M3 Pro (12 logical cores) |
| timing | 100 ms warmup + 500 ms measurement per case |

`rel` is µs/op divided by convertlib's µs/op for the same conversion and payload: below 1.00 means faster than convertlib.


## hex / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.042 | 23,860,076 | 381.8 | 1.00x |
| 16 B | package:convert | 0.044 | 22,589,388 | 361.4 | 1.06x |
| 16 B | handwritten | 0.041 | 24,221,180 | 387.5 | 0.99x |
| 256 B | convertlib | 0.529 | 1,888,774 | 483.5 | 1.00x |
| 256 B | package:convert | 0.495 | 2,019,761 | 517.1 | 0.94x |
| 256 B | handwritten | 0.545 | 1,834,785 | 469.7 | 1.03x |
| 4 KiB | convertlib | 9.010 | 110,985 | 454.6 | 1.00x |
| 4 KiB | package:convert | 8.218 | 121,686 | 498.4 | 0.91x |
| 4 KiB | handwritten | 8.644 | 115,688 | 473.9 | 0.96x |
| 64 KiB | convertlib | 254.951 | 3,922 | 257.1 | 1.00x |
| 64 KiB | package:convert | 151.656 | 6,594 | 432.1 | 0.59x |
| 64 KiB | handwritten | 138.511 | 7,220 | 473.1 | 0.54x |
| 1 MiB | convertlib | 5,835 | 171 | 179.7 | 1.00x |
| 1 MiB | package:convert | 5,990 | 167 | 175.1 | 1.03x |
| 1 MiB | handwritten | 2,455 | 407 | 427.1 | 0.42x |

## hex / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.093 | 10,708,677 | 171.3 | 1.00x |
| 16 B | package:convert | 0.068 | 14,709,262 | 235.3 | 0.73x |
| 16 B | handwritten | 0.063 | 15,852,036 | 253.6 | 0.68x |
| 256 B | convertlib | 1.413 | 707,800 | 181.2 | 1.00x |
| 256 B | package:convert | 0.982 | 1,018,561 | 260.8 | 0.69x |
| 256 B | handwritten | 0.999 | 1,000,539 | 256.1 | 0.71x |
| 4 KiB | convertlib | 28.887 | 34,617 | 141.8 | 1.00x |
| 4 KiB | package:convert | 16.249 | 61,543 | 252.1 | 0.56x |
| 4 KiB | handwritten | 16.921 | 59,098 | 242.1 | 0.59x |
| 64 KiB | convertlib | 667.476 | 1,498 | 98.2 | 1.00x |
| 64 KiB | package:convert | 490.683 | 2,038 | 133.6 | 0.74x |
| 64 KiB | handwritten | 460.512 | 2,171 | 142.3 | 0.69x |
| 1 MiB | convertlib | 11,679 | 86 | 89.8 | 1.00x |
| 1 MiB | package:convert | 9,096 | 110 | 115.3 | 0.78x |
| 1 MiB | handwritten | 8,475 | 118 | 123.7 | 0.73x |

## base64 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.031 | 32,008,628 | 512.1 | 1.00x |
| 16 B | dart:convert | 0.041 | 24,690,480 | 395.0 | 1.30x |
| 256 B | convertlib | 0.322 | 3,107,327 | 795.5 | 1.00x |
| 256 B | dart:convert | 0.407 | 2,455,693 | 628.7 | 1.27x |
| 4 KiB | convertlib | 5.003 | 199,898 | 818.8 | 1.00x |
| 4 KiB | dart:convert | 6.260 | 159,757 | 654.4 | 1.25x |
| 64 KiB | convertlib | 78.187 | 12,790 | 838.2 | 1.00x |
| 64 KiB | dart:convert | 97.938 | 10,211 | 669.2 | 1.25x |
| 1 MiB | convertlib | 1,440 | 694 | 728.2 | 1.00x |
| 1 MiB | dart:convert | 1,785 | 560 | 587.3 | 1.24x |

## base64 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.066 | 15,217,453 | 243.5 | 1.00x |
| 16 B | dart:convert | 0.055 | 18,027,553 | 288.4 | 0.84x |
| 256 B | convertlib | 0.789 | 1,267,720 | 324.5 | 1.00x |
| 256 B | dart:convert | 0.588 | 1,701,505 | 435.6 | 0.75x |
| 4 KiB | convertlib | 12.388 | 80,723 | 330.6 | 1.00x |
| 4 KiB | dart:convert | 8.909 | 112,242 | 459.7 | 0.72x |
| 64 KiB | convertlib | 192.924 | 5,183 | 339.7 | 1.00x |
| 64 KiB | dart:convert | 144.905 | 6,901 | 452.3 | 0.75x |
| 1 MiB | convertlib | 3,145 | 318 | 333.4 | 1.00x |
| 1 MiB | dart:convert | 2,317 | 432 | 452.6 | 0.74x |

## base64url / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.031 | 32,426,241 | 518.8 | 1.00x |
| 16 B | dart:convert | 0.040 | 24,790,588 | 396.6 | 1.31x |
| 256 B | convertlib | 0.322 | 3,107,694 | 795.6 | 1.00x |
| 256 B | dart:convert | 0.403 | 2,479,553 | 634.8 | 1.25x |
| 4 KiB | convertlib | 4.996 | 200,176 | 819.9 | 1.00x |
| 4 KiB | dart:convert | 6.226 | 160,609 | 657.9 | 1.25x |
| 64 KiB | convertlib | 78.160 | 12,794 | 838.5 | 1.00x |
| 64 KiB | dart:convert | 98.115 | 10,192 | 667.9 | 1.26x |
| 1 MiB | convertlib | 1,434 | 697 | 731.3 | 1.00x |
| 1 MiB | dart:convert | 1,794 | 557 | 584.4 | 1.25x |

## base64url / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.065 | 15,349,593 | 245.6 | 1.00x |
| 16 B | dart:convert | 0.054 | 18,688,479 | 299.0 | 0.82x |
| 256 B | convertlib | 0.789 | 1,266,724 | 324.3 | 1.00x |
| 256 B | dart:convert | 0.584 | 1,711,066 | 438.0 | 0.74x |
| 4 KiB | convertlib | 12.122 | 82,497 | 337.9 | 1.00x |
| 4 KiB | dart:convert | 8.909 | 112,250 | 459.8 | 0.73x |
| 64 KiB | convertlib | 193.074 | 5,179 | 339.4 | 1.00x |
| 64 KiB | dart:convert | 142.615 | 7,012 | 459.5 | 0.74x |
| 1 MiB | convertlib | 3,140 | 319 | 334.0 | 1.00x |
| 1 MiB | dart:convert | 2,321 | 431 | 451.7 | 0.74x |

## base32 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.037 | 27,070,449 | 433.1 | 1.00x |
| 16 B | package:base32 | 0.959 | 1,042,841 | 16.7 | 25.96x |
| 16 B | handwritten | 0.068 | 14,611,733 | 233.8 | 1.85x |
| 256 B | convertlib | 0.361 | 2,770,118 | 709.2 | 1.00x |
| 256 B | package:base32 | 14.847 | 67,354 | 17.2 | 41.13x |
| 256 B | handwritten | 0.940 | 1,064,107 | 272.4 | 2.60x |
| 4 KiB | convertlib | 5.487 | 182,250 | 746.5 | 1.00x |
| 4 KiB | package:base32 | 322.589 | 3,100 | 12.7 | 58.79x |
| 4 KiB | handwritten | 14.993 | 66,696 | 273.2 | 2.73x |
| 64 KiB | convertlib | 87.961 | 11,369 | 745.1 | 1.00x |
| 64 KiB | package:base32 | 28,406 | 35 | 2.3 | 322.94x |
| 64 KiB | handwritten | 247.214 | 4,045 | 265.1 | 2.81x |
| 1 MiB | convertlib | 1,567 | 638 | 669.1 | 1.00x |
| 1 MiB | package:base32 | 14,466,263 | 0 | 0.1 | 9231.54x |
| 1 MiB | handwritten | 4,354 | 230 | 240.8 | 2.78x |

## base32 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.082 | 12,258,123 | 196.1 | 1.00x |
| 16 B | package:base32 | 0.951 | 1,051,662 | 16.8 | 11.66x |
| 16 B | handwritten | 0.078 | 12,806,087 | 204.9 | 0.96x |
| 256 B | convertlib | 0.988 | 1,011,773 | 259.0 | 1.00x |
| 256 B | package:base32 | 10.814 | 92,471 | 23.7 | 10.94x |
| 256 B | handwritten | 1.031 | 969,778 | 248.3 | 1.04x |
| 4 KiB | convertlib | 15.220 | 65,703 | 269.1 | 1.00x |
| 4 KiB | package:base32 | 175.858 | 5,686 | 23.3 | 11.55x |
| 4 KiB | handwritten | 16.452 | 60,784 | 249.0 | 1.08x |
| 64 KiB | convertlib | 242.562 | 4,123 | 270.2 | 1.00x |
| 64 KiB | package:base32 | 3,154 | 317 | 20.8 | 13.00x |
| 64 KiB | handwritten | 263.740 | 3,792 | 248.5 | 1.09x |
| 1 MiB | convertlib | 3,927 | 255 | 267.0 | 1.00x |
| 1 MiB | package:base32 | 52,506 | 19 | 20.0 | 13.37x |
| 1 MiB | handwritten | 4,428 | 226 | 236.8 | 1.13x |

## binary / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.069 | 14,547,232 | 232.8 | 1.00x |
| 16 B | handwritten | 0.223 | 4,492,430 | 71.9 | 3.24x |
| 256 B | convertlib | 0.962 | 1,039,111 | 266.0 | 1.00x |
| 256 B | handwritten | 3.269 | 305,906 | 78.3 | 3.40x |
| 4 KiB | convertlib | 15.166 | 65,937 | 270.1 | 1.00x |
| 4 KiB | handwritten | 52.171 | 19,168 | 78.5 | 3.44x |
| 64 KiB | convertlib | 309.493 | 3,231 | 211.8 | 1.00x |
| 64 KiB | handwritten | 908.711 | 1,100 | 72.1 | 2.94x |

## binary / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.297 | 3,366,862 | 53.9 | 1.00x |
| 16 B | handwritten | 0.167 | 5,970,565 | 95.5 | 0.56x |
| 256 B | convertlib | 4.738 | 211,059 | 54.0 | 1.00x |
| 256 B | handwritten | 2.706 | 369,607 | 94.6 | 0.57x |
| 4 KiB | convertlib | 133.555 | 7,488 | 30.7 | 1.00x |
| 4 KiB | handwritten | 54.758 | 18,262 | 74.8 | 0.41x |
| 64 KiB | convertlib | 3,035 | 329 | 21.6 | 1.00x |
| 64 KiB | handwritten | 1,755 | 570 | 37.3 | 0.58x |

## octal / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.033 | 30,290,229 | 484.6 | 1.00x |
| 16 B | handwritten | 0.074 | 13,605,104 | 217.7 | 2.23x |
| 256 B | convertlib | 0.414 | 2,415,932 | 618.5 | 1.00x |
| 256 B | handwritten | 1.028 | 972,430 | 248.9 | 2.48x |
| 4 KiB | convertlib | 6.635 | 150,710 | 617.3 | 1.00x |
| 4 KiB | handwritten | 16.271 | 61,461 | 251.7 | 2.45x |
| 64 KiB | convertlib | 102.679 | 9,739 | 638.3 | 1.00x |
| 64 KiB | handwritten | 257.616 | 3,882 | 254.4 | 2.51x |

## octal / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.093 | 10,782,239 | 172.5 | 1.00x |
| 16 B | handwritten | 0.056 | 17,830,444 | 285.3 | 0.60x |
| 256 B | convertlib | 1.229 | 813,680 | 208.3 | 1.00x |
| 256 B | handwritten | 0.930 | 1,075,166 | 275.2 | 0.76x |
| 4 KiB | convertlib | 19.017 | 52,584 | 215.4 | 1.00x |
| 4 KiB | handwritten | 14.893 | 67,148 | 275.0 | 0.78x |
| 64 KiB | convertlib | 303.538 | 3,294 | 215.9 | 1.00x |
| 64 KiB | handwritten | 243.730 | 4,103 | 268.9 | 0.80x |

## utf8 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.315 | 3,172,066 | 888.2 | 1.00x |
| ascii/280 B | dart:convert | 0.494 | 2,024,316 | 566.8 | 1.57x |
| ascii/64 KiB | convertlib | 77.187 | 12,956 | 849.6 | 1.00x |
| ascii/64 KiB | dart:convert | 110.542 | 9,046 | 593.2 | 1.43x |
| ja/300 B | convertlib | 0.266 | 3,764,989 | 1,129 | 1.00x |
| ja/300 B | dart:convert | 0.326 | 3,071,833 | 921.5 | 1.23x |
| ja/64 KiB | convertlib | 53.645 | 18,641 | 1,223 | 1.00x |
| ja/64 KiB | dart:convert | 65.468 | 15,275 | 1,002 | 1.22x |
| emoji/300 B | convertlib | 0.336 | 2,977,081 | 893.1 | 1.00x |
| emoji/300 B | dart:convert | 0.393 | 2,547,096 | 764.1 | 1.17x |
| emoji/64 KiB | convertlib | 67.331 | 14,852 | 973.6 | 1.00x |
| emoji/64 KiB | dart:convert | 81.323 | 12,297 | 806.0 | 1.21x |

## utf8 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 1.186 | 842,914 | 236.0 | 1.00x |
| ascii/280 B | dart:convert | 0.107 | 9,312,999 | 2,608 | 0.09x |
| ascii/64 KiB | convertlib | 266.808 | 3,748 | 245.8 | 1.00x |
| ascii/64 KiB | dart:convert | 23.142 | 43,211 | 2,834 | 0.09x |
| ja/300 B | convertlib | 0.511 | 1,956,258 | 586.9 | 1.00x |
| ja/300 B | dart:convert | 0.525 | 1,905,942 | 571.8 | 1.03x |
| ja/64 KiB | convertlib | 100.620 | 9,938 | 652.0 | 1.00x |
| ja/64 KiB | dart:convert | 115.733 | 8,641 | 566.8 | 1.15x |
| emoji/300 B | convertlib | 0.673 | 1,486,112 | 445.8 | 1.00x |
| emoji/300 B | dart:convert | 0.569 | 1,757,920 | 527.4 | 0.85x |
| emoji/64 KiB | convertlib | 134.767 | 7,420 | 486.4 | 1.00x |
| emoji/64 KiB | dart:convert | 128.289 | 7,795 | 511.0 | 0.95x |

## bigint / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 1.595 | 626,870 | 10.0 | 1.00x |
| 16 B | handwritten | 0.795 | 1,257,079 | 20.1 | 0.50x |
| 256 B | convertlib | 18.651 | 53,615 | 13.7 | 1.00x |
| 256 B | handwritten | 8.302 | 120,448 | 30.8 | 0.45x |
| 4 KiB | convertlib | 309.695 | 3,229 | 13.2 | 1.00x |
| 4 KiB | handwritten | 130.917 | 7,638 | 31.3 | 0.42x |

## bigint / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.652 | 1,532,999 | 24.5 | 1.00x |
| 16 B | handwritten | 0.689 | 1,451,318 | 23.2 | 1.06x |
| 256 B | convertlib | 8.501 | 117,632 | 30.1 | 1.00x |
| 256 B | handwritten | 9.765 | 102,403 | 26.2 | 1.15x |
| 4 KiB | convertlib | 130.316 | 7,674 | 31.4 | 1.00x |
| 4 KiB | handwritten | 140.779 | 7,103 | 29.1 | 1.08x |

## constant_time / compare

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.013 | 78,304,703 | 1,253 | 1.00x |
| 16 B | handwritten | 0.013 | 76,683,672 | 1,227 | 1.02x |
| 256 B | convertlib | 0.152 | 6,574,582 | 1,683 | 1.00x |
| 256 B | handwritten | 0.156 | 6,425,030 | 1,645 | 1.02x |
| 4 KiB | convertlib | 2.318 | 431,337 | 1,767 | 1.00x |
| 4 KiB | handwritten | 2.315 | 432,029 | 1,770 | 1.00x |
| 64 KiB | convertlib | 36.717 | 27,235 | 1,785 | 1.00x |
| 64 KiB | handwritten | 37.224 | 26,864 | 1,761 | 1.01x |
| 1 MiB | convertlib | 589.111 | 1,697 | 1,780 | 1.00x |
| 1 MiB | handwritten | 588.278 | 1,700 | 1,782 | 1.00x |
