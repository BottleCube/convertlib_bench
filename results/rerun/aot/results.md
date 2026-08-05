# convertlib benchmark results

| key | value |
| --- | --- |
| date | 2026-08-05T20:37:44.923201 |
| dart | 3.12.2 (AOT) |
| os | macos Version 26.5.2 (Build 25F84) |
| cpu | Apple M3 Pro (12 logical cores) |
| timing | 100 ms warmup + 500 ms measurement per case |

`rel` is µs/op divided by convertlib's µs/op for the same conversion and payload: below 1.00 means faster than convertlib.


## hex / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.042 | 23,619,829 | 377.9 | 1.00x |
| 16 B | package:convert | 0.045 | 22,373,240 | 358.0 | 1.06x |
| 16 B | handwritten | 0.041 | 24,100,603 | 385.6 | 0.98x |
| 256 B | convertlib | 0.532 | 1,878,315 | 480.8 | 1.00x |
| 256 B | package:convert | 0.504 | 1,982,447 | 507.5 | 0.95x |
| 256 B | handwritten | 0.532 | 1,878,097 | 480.8 | 1.00x |
| 4 KiB | convertlib | 8.808 | 113,531 | 465.0 | 1.00x |
| 4 KiB | package:convert | 8.150 | 122,704 | 502.6 | 0.93x |
| 4 KiB | handwritten | 8.357 | 119,656 | 490.1 | 0.95x |
| 64 KiB | convertlib | 262.317 | 3,812 | 249.8 | 1.00x |
| 64 KiB | package:convert | 182.565 | 5,478 | 359.0 | 0.70x |
| 64 KiB | handwritten | 133.465 | 7,493 | 491.0 | 0.51x |
| 1 MiB | convertlib | 5,745 | 174 | 182.5 | 1.00x |
| 1 MiB | package:convert | 6,005 | 167 | 174.6 | 1.05x |
| 1 MiB | handwritten | 2,492 | 401 | 420.8 | 0.43x |

## hex / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.096 | 10,436,230 | 167.0 | 1.00x |
| 16 B | package:convert | 0.068 | 14,734,095 | 235.7 | 0.71x |
| 16 B | handwritten | 0.063 | 15,770,110 | 252.3 | 0.66x |
| 256 B | convertlib | 1.401 | 713,619 | 182.7 | 1.00x |
| 256 B | package:convert | 0.998 | 1,002,360 | 256.6 | 0.71x |
| 256 B | handwritten | 1.008 | 992,174 | 254.0 | 0.72x |
| 4 KiB | convertlib | 28.321 | 35,309 | 144.6 | 1.00x |
| 4 KiB | package:convert | 16.886 | 59,221 | 242.6 | 0.60x |
| 4 KiB | handwritten | 16.597 | 60,252 | 246.8 | 0.59x |
| 64 KiB | convertlib | 667.741 | 1,498 | 98.1 | 1.00x |
| 64 KiB | package:convert | 490.535 | 2,039 | 133.6 | 0.73x |
| 64 KiB | handwritten | 500.712 | 1,997 | 130.9 | 0.75x |
| 1 MiB | convertlib | 11,740 | 85 | 89.3 | 1.00x |
| 1 MiB | package:convert | 9,059 | 110 | 115.7 | 0.77x |
| 1 MiB | handwritten | 8,560 | 117 | 122.5 | 0.73x |

## base64 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.031 | 32,141,863 | 514.3 | 1.00x |
| 16 B | dart:convert | 0.040 | 24,702,031 | 395.2 | 1.30x |
| 256 B | convertlib | 0.326 | 3,067,828 | 785.4 | 1.00x |
| 256 B | dart:convert | 0.405 | 2,470,185 | 632.4 | 1.24x |
| 4 KiB | convertlib | 5.007 | 199,725 | 818.1 | 1.00x |
| 4 KiB | dart:convert | 6.269 | 159,512 | 653.4 | 1.25x |
| 64 KiB | convertlib | 78.256 | 12,779 | 837.5 | 1.00x |
| 64 KiB | dart:convert | 98.066 | 10,197 | 668.3 | 1.25x |
| 1 MiB | convertlib | 1,403 | 713 | 747.2 | 1.00x |
| 1 MiB | dart:convert | 1,724 | 580 | 608.3 | 1.23x |

## base64 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.065 | 15,368,940 | 245.9 | 1.00x |
| 16 B | dart:convert | 0.054 | 18,618,049 | 297.9 | 0.83x |
| 256 B | convertlib | 0.794 | 1,259,679 | 322.5 | 1.00x |
| 256 B | dart:convert | 0.584 | 1,711,461 | 438.1 | 0.74x |
| 4 KiB | convertlib | 12.131 | 82,434 | 337.7 | 1.00x |
| 4 KiB | dart:convert | 8.934 | 111,930 | 458.5 | 0.74x |
| 64 KiB | convertlib | 193.852 | 5,159 | 338.1 | 1.00x |
| 64 KiB | dart:convert | 142.352 | 7,025 | 460.4 | 0.73x |
| 1 MiB | convertlib | 3,143 | 318 | 333.6 | 1.00x |
| 1 MiB | dart:convert | 2,334 | 428 | 449.3 | 0.74x |

## base64url / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.031 | 32,353,607 | 517.7 | 1.00x |
| 16 B | dart:convert | 0.041 | 24,504,796 | 392.1 | 1.32x |
| 256 B | convertlib | 0.324 | 3,087,263 | 790.3 | 1.00x |
| 256 B | dart:convert | 0.405 | 2,471,430 | 632.7 | 1.25x |
| 4 KiB | convertlib | 5.099 | 196,100 | 803.2 | 1.00x |
| 4 KiB | dart:convert | 6.354 | 157,378 | 644.6 | 1.25x |
| 64 KiB | convertlib | 78.452 | 12,747 | 835.4 | 1.00x |
| 64 KiB | dart:convert | 98.436 | 10,159 | 665.8 | 1.25x |
| 1 MiB | convertlib | 1,404 | 712 | 746.9 | 1.00x |
| 1 MiB | dart:convert | 1,754 | 570 | 597.9 | 1.25x |

## base64url / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.066 | 15,143,154 | 242.3 | 1.00x |
| 16 B | dart:convert | 0.054 | 18,462,070 | 295.4 | 0.82x |
| 256 B | convertlib | 0.794 | 1,260,046 | 322.6 | 1.00x |
| 256 B | dart:convert | 0.583 | 1,714,016 | 438.8 | 0.74x |
| 4 KiB | convertlib | 12.209 | 81,904 | 335.5 | 1.00x |
| 4 KiB | dart:convert | 9.031 | 110,726 | 453.5 | 0.74x |
| 64 KiB | convertlib | 193.644 | 5,164 | 338.4 | 1.00x |
| 64 KiB | dart:convert | 142.344 | 7,025 | 460.4 | 0.74x |
| 1 MiB | convertlib | 3,185 | 314 | 329.2 | 1.00x |
| 1 MiB | dart:convert | 2,359 | 424 | 444.6 | 0.74x |

## base32 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.039 | 25,779,253 | 412.5 | 1.00x |
| 16 B | package:base32 | 0.973 | 1,027,851 | 16.4 | 25.08x |
| 16 B | handwritten | 0.069 | 14,500,864 | 232.0 | 1.78x |
| 256 B | convertlib | 0.360 | 2,777,107 | 710.9 | 1.00x |
| 256 B | package:base32 | 14.937 | 66,946 | 17.1 | 41.48x |
| 256 B | handwritten | 0.920 | 1,087,383 | 278.4 | 2.55x |
| 4 KiB | convertlib | 5.549 | 180,219 | 738.2 | 1.00x |
| 4 KiB | package:base32 | 325.031 | 3,077 | 12.6 | 58.58x |
| 4 KiB | handwritten | 15.010 | 66,623 | 272.9 | 2.71x |
| 64 KiB | convertlib | 87.427 | 11,438 | 749.6 | 1.00x |
| 64 KiB | package:base32 | 26,562 | 38 | 2.5 | 303.82x |
| 64 KiB | handwritten | 236.807 | 4,223 | 276.7 | 2.71x |
| 1 MiB | convertlib | 1,583 | 632 | 662.5 | 1.00x |
| 1 MiB | package:base32 | 14,513,057 | 0 | 0.1 | 9170.10x |
| 1 MiB | handwritten | 4,266 | 234 | 245.8 | 2.70x |

## base32 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.082 | 12,261,455 | 196.2 | 1.00x |
| 16 B | package:base32 | 0.939 | 1,065,347 | 17.0 | 11.51x |
| 16 B | handwritten | 0.076 | 13,141,088 | 210.3 | 0.93x |
| 256 B | convertlib | 0.996 | 1,004,210 | 257.1 | 1.00x |
| 256 B | package:base32 | 10.869 | 92,002 | 23.6 | 10.92x |
| 256 B | handwritten | 1.040 | 961,773 | 246.2 | 1.04x |
| 4 KiB | convertlib | 15.308 | 65,324 | 267.6 | 1.00x |
| 4 KiB | package:base32 | 176.798 | 5,656 | 23.2 | 11.55x |
| 4 KiB | handwritten | 16.452 | 60,783 | 249.0 | 1.07x |
| 64 KiB | convertlib | 242.337 | 4,126 | 270.4 | 1.00x |
| 64 KiB | package:base32 | 3,201 | 312 | 20.5 | 13.21x |
| 64 KiB | handwritten | 264.368 | 3,783 | 247.9 | 1.09x |
| 1 MiB | convertlib | 3,977 | 251 | 263.7 | 1.00x |
| 1 MiB | package:base32 | 52,372 | 19 | 20.0 | 13.17x |
| 1 MiB | handwritten | 4,327 | 231 | 242.3 | 1.09x |

## binary / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.069 | 14,498,387 | 232.0 | 1.00x |
| 16 B | handwritten | 0.228 | 4,377,920 | 70.0 | 3.31x |
| 256 B | convertlib | 0.967 | 1,034,582 | 264.9 | 1.00x |
| 256 B | handwritten | 3.299 | 303,086 | 77.6 | 3.41x |
| 4 KiB | convertlib | 15.101 | 66,219 | 271.2 | 1.00x |
| 4 KiB | handwritten | 52.462 | 19,061 | 78.1 | 3.47x |
| 64 KiB | convertlib | 303.292 | 3,297 | 216.1 | 1.00x |
| 64 KiB | handwritten | 905.500 | 1,104 | 72.4 | 2.99x |

## binary / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.304 | 3,284,639 | 52.6 | 1.00x |
| 16 B | handwritten | 0.168 | 5,955,090 | 95.3 | 0.55x |
| 256 B | convertlib | 4.803 | 208,223 | 53.3 | 1.00x |
| 256 B | handwritten | 2.693 | 371,323 | 95.1 | 0.56x |
| 4 KiB | convertlib | 117.121 | 8,538 | 35.0 | 1.00x |
| 4 KiB | handwritten | 48.188 | 20,752 | 85.0 | 0.41x |
| 64 KiB | convertlib | 3,017 | 332 | 21.7 | 1.00x |
| 64 KiB | handwritten | 1,720 | 581 | 38.1 | 0.57x |

## octal / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.033 | 30,033,749 | 480.5 | 1.00x |
| 16 B | handwritten | 0.074 | 13,470,328 | 215.5 | 2.23x |
| 256 B | convertlib | 0.408 | 2,448,877 | 626.9 | 1.00x |
| 256 B | handwritten | 1.042 | 960,085 | 245.8 | 2.55x |
| 4 KiB | convertlib | 6.778 | 147,529 | 604.3 | 1.00x |
| 4 KiB | handwritten | 16.359 | 61,128 | 250.4 | 2.41x |
| 64 KiB | convertlib | 102.513 | 9,755 | 639.3 | 1.00x |
| 64 KiB | handwritten | 255.893 | 3,908 | 256.1 | 2.50x |

## octal / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.094 | 10,688,367 | 171.0 | 1.00x |
| 16 B | handwritten | 0.056 | 17,747,897 | 284.0 | 0.60x |
| 256 B | convertlib | 1.243 | 804,688 | 206.0 | 1.00x |
| 256 B | handwritten | 0.934 | 1,070,486 | 274.0 | 0.75x |
| 4 KiB | convertlib | 19.125 | 52,288 | 214.2 | 1.00x |
| 4 KiB | handwritten | 14.913 | 67,055 | 274.7 | 0.78x |
| 64 KiB | convertlib | 304.084 | 3,289 | 215.5 | 1.00x |
| 64 KiB | handwritten | 240.513 | 4,158 | 272.5 | 0.79x |

## utf8 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.320 | 3,122,575 | 874.3 | 1.00x |
| ascii/280 B | dart:convert | 0.528 | 1,894,461 | 530.4 | 1.65x |
| ascii/64 KiB | convertlib | 75.680 | 13,214 | 866.5 | 1.00x |
| ascii/64 KiB | dart:convert | 113.355 | 8,822 | 578.5 | 1.50x |
| ja/300 B | convertlib | 0.266 | 3,761,810 | 1,129 | 1.00x |
| ja/300 B | dart:convert | 0.328 | 3,044,492 | 913.3 | 1.24x |
| ja/64 KiB | convertlib | 54.600 | 18,315 | 1,201 | 1.00x |
| ja/64 KiB | dart:convert | 66.458 | 15,047 | 987.1 | 1.22x |
| emoji/300 B | convertlib | 0.327 | 3,054,368 | 916.3 | 1.00x |
| emoji/300 B | dart:convert | 0.393 | 2,547,466 | 764.2 | 1.20x |
| emoji/64 KiB | convertlib | 67.801 | 14,749 | 966.8 | 1.00x |
| emoji/64 KiB | dart:convert | 79.548 | 12,571 | 824.0 | 1.17x |

## utf8 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 1.208 | 827,828 | 231.8 | 1.00x |
| ascii/280 B | dart:convert | 0.107 | 9,332,439 | 2,613 | 0.09x |
| ascii/64 KiB | convertlib | 268.526 | 3,724 | 244.2 | 1.00x |
| ascii/64 KiB | dart:convert | 22.324 | 44,794 | 2,937 | 0.08x |
| ja/300 B | convertlib | 0.518 | 1,931,136 | 579.3 | 1.00x |
| ja/300 B | dart:convert | 0.529 | 1,889,074 | 566.7 | 1.02x |
| ja/64 KiB | convertlib | 102.646 | 9,742 | 639.1 | 1.00x |
| ja/64 KiB | dart:convert | 116.669 | 8,571 | 562.3 | 1.14x |
| emoji/300 B | convertlib | 0.670 | 1,491,811 | 447.5 | 1.00x |
| emoji/300 B | dart:convert | 0.565 | 1,768,910 | 530.7 | 0.84x |
| emoji/64 KiB | convertlib | 136.197 | 7,342 | 481.3 | 1.00x |
| emoji/64 KiB | dart:convert | 123.833 | 8,075 | 529.3 | 0.91x |

## bigint / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 1.622 | 616,466 | 9.9 | 1.00x |
| 16 B | handwritten | 0.798 | 1,253,815 | 20.1 | 0.49x |
| 256 B | convertlib | 18.704 | 53,465 | 13.7 | 1.00x |
| 256 B | handwritten | 8.382 | 119,309 | 30.5 | 0.45x |
| 4 KiB | convertlib | 306.319 | 3,265 | 13.4 | 1.00x |
| 4 KiB | handwritten | 130.080 | 7,688 | 31.5 | 0.42x |

## bigint / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.696 | 1,435,890 | 23.0 | 1.00x |
| 16 B | handwritten | 0.716 | 1,397,302 | 22.4 | 1.03x |
| 256 B | convertlib | 8.541 | 117,085 | 30.0 | 1.00x |
| 256 B | handwritten | 9.061 | 110,361 | 28.3 | 1.06x |
| 4 KiB | convertlib | 130.447 | 7,666 | 31.4 | 1.00x |
| 4 KiB | handwritten | 139.187 | 7,185 | 29.4 | 1.07x |

## constant_time / compare

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.013 | 76,154,677 | 1,218 | 1.00x |
| 16 B | handwritten | 0.013 | 76,452,285 | 1,223 | 1.00x |
| 256 B | convertlib | 0.152 | 6,560,379 | 1,679 | 1.00x |
| 256 B | handwritten | 0.153 | 6,550,173 | 1,677 | 1.00x |
| 4 KiB | convertlib | 2.337 | 427,813 | 1,752 | 1.00x |
| 4 KiB | handwritten | 2.357 | 424,293 | 1,738 | 1.01x |
| 64 KiB | convertlib | 37.620 | 26,581 | 1,742 | 1.00x |
| 64 KiB | handwritten | 37.643 | 26,565 | 1,741 | 1.00x |
| 1 MiB | convertlib | 599.781 | 1,667 | 1,748 | 1.00x |
| 1 MiB | handwritten | 594.320 | 1,683 | 1,764 | 0.99x |
