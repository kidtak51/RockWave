# RockWave SIM用テストFW

## はじめに  

RockWaveをシミュレーションするためのバイナリです。  
`InstMemory`に`$readmemh`で読み込むことを想定しています。  
[github:riscv-tools/riscv-tests](https://github.com/riscv/riscv-tests)から生成しています。

---

## 使い方

テストベンチに以下の記述する。

```v
    initial begin
        $readmemh("fw/rv32ui-p-add",mem,12'h0000,12'hffff);
    end
```
