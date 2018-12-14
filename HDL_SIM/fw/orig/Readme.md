# RockWave SIM用テストFWビルド方法


## ビルド
32bit版のツールチェインではコンパイルが通らない部分があるので、64bit版を使います。
(64bit版でもARCHを指定すれば、32bit版のバイナリを生成する模様)

### clone

```bash
    $ git clone https://github.com/riscv/riscv-tests
    $ cd riscv-tests
    $ git git submodule update --init --recursive
```
### 修正
以下を修正します。
* startupルーチンの削除
* hexファイルの生成

### startupルーチンの削除
env/p/ディレクトリ内のriscv_test.hを修正します。  
(ある程度命令の実装ができたら必要ないかな)
```diff
--- a/p/riscv_test.h
+++ b/p/riscv_test.h
@@ -105,6 +105,14 @@
 
 #define INTERRUPT_HANDLER j other_exception /* No interrupts should occur */
 
+
+#define RVTEST_CODE_BEGIN                                               \
+        .section .text.init;                                            \
+        .align  6;                                                      \
+        .globl _start;                                                  \
+_start:                                                                 
+
+#if 0
 #define RVTEST_CODE_BEGIN                                               \
         .section .text.init;                                            \
         .align  6;                                                      \
@@ -171,6 +179,7 @@ reset_vector:                                                           \
         csrr a0, mhartid;                                               \
         mret;                                                           \
 1:
+#endif
 
 //-----------------------------------------------------------------------
```

### hexファイルの生成
isaディレクトリ内のMakefileを修正します。  
(BigEndianで良いかはあとで考える)

```diff
--- a/isa/Makefile
+++ b/isa/Makefile
@@ -36,6 +36,8 @@ RISCV_GCC ?= $(RISCV_PREFIX)gcc
 RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
 RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
 RISCV_SIM ?= spike
+RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary
+HEXDUMP ?= hexdump -v -e '1/4 "%08x" "\n"'
 
 vpath %.S $(src_dir)
 
@@ -45,6 +47,12 @@ vpath %.S $(src_dir)
 %.dump: %
 	$(RISCV_OBJDUMP) $< > $@
 
+%.bin: %
+	$(RISCV_OBJCOPY) $< $@
+
+%.hex: %.bin
+	$(HEXDUMP) $< > $@
+
 %.out: %
 	$(RISCV_SIM) --isa=rv64gc $< 2> $@
 
@@ -91,18 +99,19 @@ $(eval $(call compile_template,rv64mi,-march=rv64g -mabi=lp64))
 endif
 
 tests_dump = $(addsuffix .dump, $(tests))
+tests_bin = $(addsuffix .bin, $(tests))
 tests_hex = $(addsuffix .hex, $(tests))
 tests_out = $(addsuffix .out, $(spike_tests))
 tests32_out = $(addsuffix .out32, $(spike32_tests))
 
 run: $(tests_out) $(tests32_out)
 
-junk += $(tests) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)
+junk += $(tests) $(tests_dump) $(tests_bin) $(tests_hex) $(tests_out) $(tests32_out)
 
 #------------------------------------------------------------
 # Default
 
-all: $(tests_dump)
+all: $(tests_dump) $(tests_hex)
 
 #------------------------------------------------------------
 # Clean up
```
### make
```bash
% ./configure
% cd isa
% make -j4
```

isaフォルダ内に
* `rv32ui-p-xxx`  
* `rv32ui-p-xxx.dump`  
* `rv32ui-p-xxx.hex`  

ができているはず