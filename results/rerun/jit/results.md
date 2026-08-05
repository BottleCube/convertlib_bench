# convertlib benchmark results

| key | value |
| --- | --- |
| date | 2026-08-05T20:32:42.367963 |
| dart | 3.12.2 (JIT) |
| os | macos Version 26.5.2 (Build 25F84) |
| cpu | Apple M3 Pro (12 logical cores) |
| timing | 100 ms warmup + 500 ms measurement per case |

`rel` is µs/op divided by convertlib's µs/op for the same conversion and payload: below 1.00 means faster than convertlib.


## hex / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.034 | 29,256,580 | 468.1 | 1.00x |
| 16 B | package:convert | 0.040 | 24,868,990 | 397.9 | 1.18x |
| 16 B | handwritten | 0.042 | 23,920,617 | 382.7 | 1.22x |
| 256 B | convertlib | 0.357 | 2,801,262 | 717.1 | 1.00x |
| 256 B | package:convert | 0.424 | 2,355,801 | 603.1 | 1.19x |
| 256 B | handwritten | 0.489 | 2,046,134 | 523.8 | 1.37x |
| 4 KiB | convertlib | 5.616 | 178,048 | 729.3 | 1.00x |
| 4 KiB | package:convert | 7.447 | 134,280 | 550.0 | 1.33x |
| 4 KiB | handwritten | 7.770 | 128,694 | 527.1 | 1.38x |
| 64 KiB | convertlib | 88.262 | 11,330 | 742.5 | 1.00x |
| 64 KiB | package:convert | 276.096 | 3,622 | 237.4 | 3.13x |
| 64 KiB | handwritten | 131.434 | 7,608 | 498.6 | 1.49x |
| 1 MiB | convertlib | 1,685 | 594 | 622.5 | 1.00x |
| 1 MiB | package:convert | 6,197 | 161 | 169.2 | 3.68x |
| 1 MiB | handwritten | 2,446 | 409 | 428.7 | 1.45x |

## hex / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.045 | 22,304,598 | 356.9 | 1.00x |
| 16 B | package:convert | 0.101 | 9,890,964 | 158.3 | 2.26x |
| 16 B | handwritten | 0.067 | 14,849,088 | 237.6 | 1.50x |
| 256 B | convertlib | 0.631 | 1,583,704 | 405.4 | 1.00x |
| 256 B | package:convert | 1.509 | 662,773 | 169.7 | 2.39x |
| 256 B | handwritten | 0.998 | 1,002,289 | 256.6 | 1.58x |
| 4 KiB | convertlib | 10.563 | 94,668 | 387.8 | 1.00x |
| 4 KiB | package:convert | 28.526 | 35,056 | 143.6 | 2.70x |
| 4 KiB | handwritten | 16.003 | 62,487 | 255.9 | 1.51x |
| 64 KiB | convertlib | 301.124 | 3,321 | 217.6 | 1.00x |
| 64 KiB | package:convert | 787.071 | 1,271 | 83.3 | 2.61x |
| 64 KiB | handwritten | 468.694 | 2,134 | 139.8 | 1.56x |
| 1 MiB | convertlib | 6,693 | 149 | 156.7 | 1.00x |
| 1 MiB | package:convert | 13,498 | 74 | 77.7 | 2.02x |
| 1 MiB | handwritten | 8,701 | 115 | 120.5 | 1.30x |

## base64 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.033 | 29,861,976 | 477.8 | 1.00x |
| 16 B | dart:convert | 0.048 | 20,837,671 | 333.4 | 1.43x |
| 256 B | convertlib | 0.324 | 3,089,089 | 790.8 | 1.00x |
| 256 B | dart:convert | 0.412 | 2,426,183 | 621.1 | 1.27x |
| 4 KiB | convertlib | 4.958 | 201,710 | 826.2 | 1.00x |
| 4 KiB | dart:convert | 6.207 | 161,118 | 659.9 | 1.25x |
| 64 KiB | convertlib | 76.643 | 13,048 | 855.1 | 1.00x |
| 64 KiB | dart:convert | 97.421 | 10,265 | 672.7 | 1.27x |
| 1 MiB | convertlib | 1,504 | 665 | 697.1 | 1.00x |
| 1 MiB | dart:convert | 1,850 | 541 | 566.9 | 1.23x |

## base64 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.043 | 23,509,429 | 376.2 | 1.00x |
| 16 B | dart:convert | 0.052 | 19,085,803 | 305.4 | 1.23x |
| 256 B | convertlib | 0.362 | 2,760,723 | 706.7 | 1.00x |
| 256 B | dart:convert | 0.484 | 2,066,861 | 529.1 | 1.34x |
| 4 KiB | convertlib | 5.505 | 181,638 | 744.0 | 1.00x |
| 4 KiB | dart:convert | 7.279 | 137,381 | 562.7 | 1.32x |
| 64 KiB | convertlib | 86.080 | 11,617 | 761.3 | 1.00x |
| 64 KiB | dart:convert | 116.342 | 8,595 | 563.3 | 1.35x |
| 1 MiB | convertlib | 1,467 | 682 | 714.9 | 1.00x |
| 1 MiB | dart:convert | 1,979 | 505 | 529.8 | 1.35x |

## base64url / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.034 | 29,539,987 | 472.6 | 1.00x |
| 16 B | dart:convert | 0.049 | 20,286,876 | 324.6 | 1.46x |
| 256 B | convertlib | 0.323 | 3,093,710 | 792.0 | 1.00x |
| 256 B | dart:convert | 0.412 | 2,426,740 | 621.2 | 1.27x |
| 4 KiB | convertlib | 4.913 | 203,546 | 833.7 | 1.00x |
| 4 KiB | dart:convert | 6.194 | 161,438 | 661.3 | 1.26x |
| 64 KiB | convertlib | 76.728 | 13,033 | 854.1 | 1.00x |
| 64 KiB | dart:convert | 97.448 | 10,262 | 672.5 | 1.27x |
| 1 MiB | convertlib | 1,481 | 675 | 708.1 | 1.00x |
| 1 MiB | dart:convert | 1,826 | 548 | 574.3 | 1.23x |

## base64url / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.043 | 23,214,214 | 371.4 | 1.00x |
| 16 B | dart:convert | 0.052 | 19,285,448 | 308.6 | 1.20x |
| 256 B | convertlib | 0.367 | 2,727,166 | 698.2 | 1.00x |
| 256 B | dart:convert | 0.492 | 2,032,606 | 520.3 | 1.34x |
| 4 KiB | convertlib | 5.493 | 182,050 | 745.7 | 1.00x |
| 4 KiB | dart:convert | 7.293 | 137,127 | 561.7 | 1.33x |
| 64 KiB | convertlib | 86.954 | 11,500 | 753.7 | 1.00x |
| 64 KiB | dart:convert | 117.865 | 8,484 | 556.0 | 1.36x |
| 1 MiB | convertlib | 1,449 | 690 | 723.7 | 1.00x |
| 1 MiB | dart:convert | 1,946 | 514 | 538.8 | 1.34x |

## base32 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.038 | 26,526,238 | 424.4 | 1.00x |
| 16 B | package:base32 | 1.029 | 971,970 | 15.6 | 27.29x |
| 16 B | handwritten | 0.071 | 14,018,593 | 224.3 | 1.89x |
| 256 B | convertlib | 0.359 | 2,783,716 | 712.6 | 1.00x |
| 256 B | package:base32 | 15.716 | 63,628 | 16.3 | 43.75x |
| 256 B | handwritten | 0.931 | 1,073,715 | 274.9 | 2.59x |
| 4 KiB | convertlib | 5.420 | 184,515 | 755.8 | 1.00x |
| 4 KiB | package:base32 | 338.951 | 2,950 | 12.1 | 62.54x |
| 4 KiB | handwritten | 14.766 | 67,724 | 277.4 | 2.72x |
| 64 KiB | convertlib | 87.318 | 11,452 | 750.5 | 1.00x |
| 64 KiB | package:base32 | 27,411 | 36 | 2.4 | 313.92x |
| 64 KiB | handwritten | 246.664 | 4,054 | 265.7 | 2.82x |
| 1 MiB | convertlib | 1,656 | 604 | 633.1 | 1.00x |
| 1 MiB | package:base32 | 23,088,247 | 0 | 0.0 | 13940.69x |
| 1 MiB | handwritten | 4,859 | 206 | 215.8 | 2.93x |

## base32 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.054 | 18,540,264 | 296.6 | 1.00x |
| 16 B | package:base32 | 0.838 | 1,192,926 | 19.1 | 15.54x |
| 16 B | handwritten | 0.059 | 17,086,813 | 273.4 | 1.09x |
| 256 B | convertlib | 0.427 | 2,339,975 | 599.0 | 1.00x |
| 256 B | package:base32 | 8.754 | 114,234 | 29.2 | 20.48x |
| 256 B | handwritten | 0.797 | 1,254,121 | 321.1 | 1.87x |
| 4 KiB | convertlib | 6.332 | 157,933 | 646.9 | 1.00x |
| 4 KiB | package:base32 | 136.086 | 7,348 | 30.1 | 21.49x |
| 4 KiB | handwritten | 12.577 | 79,508 | 325.7 | 1.99x |
| 64 KiB | convertlib | 101.641 | 9,839 | 644.8 | 1.00x |
| 64 KiB | package:base32 | 2,706 | 370 | 24.2 | 26.62x |
| 64 KiB | handwritten | 206.934 | 4,832 | 316.7 | 2.04x |
| 1 MiB | convertlib | 1,703 | 587 | 615.7 | 1.00x |
| 1 MiB | package:base32 | 44,543 | 22 | 23.5 | 26.15x |
| 1 MiB | handwritten | 3,578 | 279 | 293.0 | 2.10x |

## binary / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.070 | 14,360,012 | 229.8 | 1.00x |
| 16 B | handwritten | 0.229 | 4,367,283 | 69.9 | 3.29x |
| 256 B | convertlib | 0.928 | 1,077,953 | 276.0 | 1.00x |
| 256 B | handwritten | 3.352 | 298,320 | 76.4 | 3.61x |
| 4 KiB | convertlib | 14.191 | 70,465 | 288.6 | 1.00x |
| 4 KiB | handwritten | 53.798 | 18,588 | 76.1 | 3.79x |
| 64 KiB | convertlib | 350.996 | 2,849 | 186.7 | 1.00x |
| 64 KiB | handwritten | 1,033 | 968 | 63.5 | 2.94x |

## binary / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.132 | 7,569,140 | 121.1 | 1.00x |
| 16 B | handwritten | 0.147 | 6,804,205 | 108.9 | 1.11x |
| 256 B | convertlib | 2.124 | 470,783 | 120.5 | 1.00x |
| 256 B | handwritten | 2.481 | 402,996 | 103.2 | 1.17x |
| 4 KiB | convertlib | 37.085 | 26,965 | 110.4 | 1.00x |
| 4 KiB | handwritten | 88.330 | 11,321 | 46.4 | 2.38x |
| 64 KiB | convertlib | 1,884 | 531 | 34.8 | 1.00x |
| 64 KiB | handwritten | 2,155 | 464 | 30.4 | 1.14x |

## octal / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.037 | 27,133,148 | 434.1 | 1.00x |
| 16 B | handwritten | 0.055 | 18,122,776 | 290.0 | 1.50x |
| 256 B | convertlib | 0.406 | 2,464,256 | 630.8 | 1.00x |
| 256 B | handwritten | 0.689 | 1,450,535 | 371.3 | 1.70x |
| 4 KiB | convertlib | 6.275 | 159,355 | 652.7 | 1.00x |
| 4 KiB | handwritten | 11.445 | 87,377 | 357.9 | 1.82x |
| 64 KiB | convertlib | 95.510 | 10,470 | 686.2 | 1.00x |
| 64 KiB | handwritten | 173.822 | 5,753 | 377.0 | 1.82x |

## octal / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.041 | 24,479,806 | 391.7 | 1.00x |
| 16 B | handwritten | 0.046 | 21,559,190 | 344.9 | 1.14x |
| 256 B | convertlib | 0.508 | 1,966,959 | 503.5 | 1.00x |
| 256 B | handwritten | 0.653 | 1,531,194 | 392.0 | 1.28x |
| 4 KiB | convertlib | 8.025 | 124,614 | 510.4 | 1.00x |
| 4 KiB | handwritten | 10.326 | 96,841 | 396.7 | 1.29x |
| 64 KiB | convertlib | 126.535 | 7,903 | 517.9 | 1.00x |
| 64 KiB | handwritten | 164.820 | 6,067 | 397.6 | 1.30x |

## utf8 / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.321 | 3,117,683 | 873.0 | 1.00x |
| ascii/280 B | dart:convert | 0.499 | 2,004,386 | 561.2 | 1.56x |
| ascii/64 KiB | convertlib | 93.649 | 10,678 | 700.2 | 1.00x |
| ascii/64 KiB | dart:convert | 130.947 | 7,637 | 500.8 | 1.40x |
| ja/300 B | convertlib | 0.222 | 4,513,518 | 1,354 | 1.00x |
| ja/300 B | dart:convert | 0.507 | 1,974,326 | 592.3 | 2.29x |
| ja/64 KiB | convertlib | 43.442 | 23,019 | 1,510 | 1.00x |
| ja/64 KiB | dart:convert | 100.353 | 9,965 | 653.7 | 2.31x |
| emoji/300 B | convertlib | 0.393 | 2,547,469 | 764.2 | 1.00x |
| emoji/300 B | dart:convert | 0.520 | 1,921,754 | 576.5 | 1.33x |
| emoji/64 KiB | convertlib | 83.988 | 11,907 | 780.5 | 1.00x |
| emoji/64 KiB | dart:convert | 111.671 | 8,955 | 587.0 | 1.33x |

## utf8 / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| ascii/280 B | convertlib | 0.732 | 1,366,643 | 382.7 | 1.00x |
| ascii/280 B | dart:convert | 0.110 | 9,055,474 | 2,536 | 0.15x |
| ascii/64 KiB | convertlib | 163.993 | 6,098 | 399.9 | 1.00x |
| ascii/64 KiB | dart:convert | 22.309 | 44,825 | 2,939 | 0.14x |
| ja/300 B | convertlib | 0.372 | 2,687,305 | 806.2 | 1.00x |
| ja/300 B | dart:convert | 0.454 | 2,204,306 | 661.3 | 1.22x |
| ja/64 KiB | convertlib | 70.394 | 14,206 | 931.9 | 1.00x |
| ja/64 KiB | dart:convert | 100.038 | 9,996 | 655.8 | 1.42x |
| emoji/300 B | convertlib | 0.547 | 1,828,227 | 548.5 | 1.00x |
| emoji/300 B | dart:convert | 0.483 | 2,069,609 | 620.9 | 0.88x |
| emoji/64 KiB | convertlib | 110.396 | 9,058 | 593.8 | 1.00x |
| emoji/64 KiB | dart:convert | 100.557 | 9,945 | 651.9 | 0.91x |

## bigint / encode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 1.315 | 760,724 | 12.2 | 1.00x |
| 16 B | handwritten | 0.847 | 1,181,334 | 18.9 | 0.64x |
| 256 B | convertlib | 14.321 | 69,825 | 17.9 | 1.00x |
| 256 B | handwritten | 8.340 | 119,909 | 30.7 | 0.58x |
| 4 KiB | convertlib | 216.771 | 4,613 | 18.9 | 1.00x |
| 4 KiB | handwritten | 130.201 | 7,680 | 31.5 | 0.60x |

## bigint / decode

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.483 | 2,068,545 | 33.1 | 1.00x |
| 16 B | handwritten | 0.570 | 1,755,455 | 28.1 | 1.18x |
| 256 B | convertlib | 5.420 | 184,515 | 47.2 | 1.00x |
| 256 B | handwritten | 6.390 | 156,503 | 40.1 | 1.18x |
| 4 KiB | convertlib | 80.538 | 12,416 | 50.9 | 1.00x |
| 4 KiB | handwritten | 95.434 | 10,478 | 42.9 | 1.18x |

## constant_time / compare

| data | impl | µs/op | ops/s | MB/s | rel |
| --- | --- | ---: | ---: | ---: | ---: |
| 16 B | convertlib | 0.013 | 77,913,325 | 1,247 | 1.00x |
| 16 B | handwritten | 0.013 | 78,110,049 | 1,250 | 1.00x |
| 256 B | convertlib | 0.149 | 6,689,394 | 1,712 | 1.00x |
| 256 B | handwritten | 0.150 | 6,685,300 | 1,711 | 1.00x |
| 4 KiB | convertlib | 2.260 | 442,567 | 1,813 | 1.00x |
| 4 KiB | handwritten | 2.263 | 441,801 | 1,810 | 1.00x |
| 64 KiB | convertlib | 38.660 | 25,866 | 1,695 | 1.00x |
| 64 KiB | handwritten | 38.612 | 25,899 | 1,697 | 1.00x |
| 1 MiB | convertlib | 620.553 | 1,611 | 1,690 | 1.00x |
| 1 MiB | handwritten | 615.656 | 1,624 | 1,703 | 0.99x |
