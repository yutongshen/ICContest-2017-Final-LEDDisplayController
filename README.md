# IC Design Contest

## 2017 IC Design Contest Final Cell-Based IC Design Category for Graduate Level
- LED Display Controller

## Module
- `src/LEDDC.v` -- Main module.
- `src/DataReceiver.v` -- Receive data form host, and write data into SRAM.
- `src/PWMConvert.v` -- Read data from SRAM, and send PWM signal.
- `src/sram_256x16/sram_256x16.v` -- SRAM (256x16).
- `src/sram_512x16/sram_512x16.v` -- SRAM (512x16).

## Test Bench
- `sim/testfixture_30fps.v`
- `sim/testfixture_60fps.v`

## AUTHORS
[Yu-Tong Shen](https://github.com/yutongshen/)
