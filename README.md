# Device tree for Xiaomi Mi MIX 2S (codenamed _"polaris"_)

==================================
## Device specifications

| Device                  | Xiaomi Mi MIX 2S                                |
| ----------------------: | :---------------------------------------------- |
| SoC                     | Qualcomm SDM845 Snapdragon 845                  |
| CPU                     | 8x Qualcomm® Kryo™ 385 up to 2.8GHz             |
| GPU                     | Adreno 630                                      |
| Memory                  | 6GB / 8GB RAM (LPDDR4X)                         |
| Shipped Android version | 8.0                                             |
| Storage                 | 64GB / 128GB / 256GB UFS 2.1 flash storage      |
| Battery                 | Non-removable Li-Po 3400 mAh                    |
| Dimensions              | 150.86 x 74.9 x 8.1 mm                          |
| Display                 | 2160 x 1080 (18:9), 5.99 inch                   |
| Rear camera 1           | 12MP, f/1.8 Dual LED flash                      |
| Rear camera 2           | 12MP, f/2.4                                     |
| Front camera            | 5MP, 1-micron pixels, f/2.2 1080p 30 fps video  |

## Device picture

![Xiaomi Mi MIX 2S](https://i1.mifile.cn/f/i/2018/mix2s/specs/black.png?1 "Xiaomi Mi MIX 2S")

## Building
Generally, see https://wiki.orangefox.tech/en/dev/building

### Variants
1. For standard mode, build without any additional flags.
2. To build for ROMs using retrofitted dynamic partitions, run "export FOX_USE_DYNAMIC_PARTITIONS=1" before building.
3. To build for ROMs using borrowed keymaster 4.0, run "export FOX_USE_KEYMASTER_4=1" before building.

### Kernel source
Clone this: "https://github.com/LineageOS/android_kernel_xiaomi_sdm845.git -b lineage-21"

### Copyright
 ```
  /*
  *  Copyright (C) 2013-2020 The TWRP
  *
  *  Copyright (C) 2019-2024 The OrangeFox Recovery Project
  *
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  */
  ```
