# ソフトウェア開発環境
RISC-Vをコンパイルするためのクロスコンパイラを準備します 
lakehipでは、構築済みなので、`/opt/riscv32i/bin`にパスを通して使用する。


ここでは、Ubuntu18.04上に構築しました。

### ビルド用ソフトウェアのインストール
    $ sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev
    $ sudo apt install git

### リポジトリのクローン
すべてのサブモジュールも含めてクローンします

    $ git clone https://github.com/riscv/riscv-tools.git
    $ cd riscv-tools
    $ git submodule update --init --recursive

### インスール先
インストール先は、/opt/riscv32iにします

    $ export RISCV=/opt/riscv32i
    $ sudo mkdir /opt/riscv32i
    $ sudo chown aokim:aokim /opt/riscv32i

### 設定変更
デフォルトでは、64bit版が生成されます。  
今回のプロジェクトでは、RV32Iコアなので、ビルドスクリプトを修正します。

    $ sed -e 's/rv32ima/rv32i/g' build-rv32ima.sh > build-rv32i.sh
    $ chmod +x build.rv32i.sh

ホストPCに複数のコアがあるなら、並列ビルドを行うためにbuild.commonファイルを修正します。

    $ sed -i -e 's/$MAKE/$MAKE -j4/g' build.common

### configure & compile & install

    $ sudo ./build-rv32i.sh

---
## 動作確認
ビルドしたツールの動作確認をしてみる

    $ echo -e '#include <stdio.h>\n int main(void) { printf("Hello world!\\n"); return 0; }' > hello.c
    $ riscv32-unknown-elf-gcc -o hello hello.c
    $ spike pk hello

lakehipには、乗算器なしのrv32iアーキテクチャと乗算器/アトミック演算ありのrv32imaアーキテクチャ用のgccを準備したので、それぞれの動作確認をした。
それぞれ、/opt/riscv32i/binまたは/opt/riscv32ima/binのどちらかにパスを通して使用する。

### 対象のプログラム
div.c

    #include <stdio.h>
    int main(void)
    {
        int a=2;
        for(int i=0;i<10;i++){
            a=a*a;
            printf("%d\n",a);
        }
        return 0;
    }

### コンパイル
	
    $ riscv32-unknown-elf-gcc -O0 -c div.c
	$ riscv32-unknown-elf-gcc -o div div.o
リンク前後のオプジェクトで比較するために "-c"オプションで一度オブジェクトに変換している。

### 逆アセンブル結果
* 乗算器あり/リンク前 (rv32ima)

        $ riscv32-unknown-elf-objdump -d div.o  

       div.o:     ファイル形式 elf32-littleriscv

        セクション .text の逆アセンブル:

        00000000 <main>:
           0:	fe010113          	addi	sp,sp,-32
           4:	00112e23          	sw	ra,28(sp)
           8:	00812c23          	sw	s0,24(sp)
           c:	02010413          	addi	s0,sp,32
          10:	00300793          	li	a5,3
          14:	fef42623          	sw	a5,-20(s0)
          18:	fe042423          	sw	zero,-24(s0)
          1c:	0340006f          	j	50 <.L2>

        00000020 <.L3>:
          20:	fec42703          	lw	a4,-20(s0)
          24:	fec42783          	lw	a5,-20(s0)
          28:	02f707b3          	mul	a5,a4,a5
          2c:	fef42623          	sw	a5,-20(s0)
          30:	fec42583          	lw	a1,-20(s0)
          34:	000007b7          	lui	a5,0x0
          38:	00078513          	mv	a0,a5
          3c:	00000097          	auipc	ra,0x0
          40:	000080e7          	jalr	ra
          44:	fe842783          	lw	a5,-24(s0)
          48:	00178793          	addi	a5,a5,1 # 1     <main   +0x1>
          4c:	fef42423          	sw	a5,-24(s0)

        00000050 <.L2>:
          50:	fe842703          	lw	a4,-24(s0)
          54:	00900793          	li	a5,9
          58:	fce7d4e3          	ble	a4,a5,20 <.L3>
          5c:	00000793          	li	a5,0
          60:	00078513          	mv	a0,a5
          64:	01c12083          	lw	ra,28(sp)
          68:	01812403          	lw	s0,24(sp)
          6c:	02010113          	addi	sp,sp,32
          70:	00008067          	ret
アドレス28で、mul命令を発行している  
* 乗算器なし/リンク前(rv32i)

       $ riscv32-unknown-elf-objdump -d div_rve32i.o  

        div_rv32i.o:     ファイル形式 elf32-littleriscv


        セクション .text の逆アセンブル:

        00000000 <main>:
           0:	fe010113          	addi	sp,sp,-32
           4:	00112e23          	sw	ra,28(sp)
           8:	00812c23          	sw	s0,24(sp)
           c:	02010413          	addi	s0,sp,32
          10:	00200793          	li	a5,2
          14:	fef42623          	sw	a5,-20(s0)
          18:	fe042423          	sw	zero,-24(s0)
          1c:	03c0006f          	j	58 <.L2>

        00000020 <.L3>:
          20:	fec42583          	lw	a1,-20(s0)
          24:	fec42503          	lw	a0,-20(s0)
          28:	00000097          	auipc	ra,0x0
          2c:	000080e7          	jalr	ra
          30:	00050793          	mv	a5,a0
          34:	fef42623          	sw	a5,-20(s0)
          38:	fec42583          	lw	a1,-20(s0)
          3c:	000007b7          	lui	a5,0x0
          40:	00078513          	mv	a0,a5
          44:	00000097          	auipc	ra,0x0
          48:	000080e7          	jalr	ra
          4c:	fe842783          	lw	a5,-24(s0)
          50:	00178793          	addi	a5,a5,1 # 1 <main       +0x1>
          54:	fef42423          	sw	a5,-24(s0)

        00000058 <.L2>:
          58:	fe842703          	lw	a4,-24(s0)
          5c:	00900793          	li	a5,9
          60:	fce7d0e3          	ble	a4,a5,20 <.L3>
          64:	00000793          	li	a5,0
          68:	00078513          	mv	a0,a5
          6c:	01c12083          	lw	ra,28(sp)
          70:	01812403          	lw	s0,24(sp)
          74:	02010113          	addi	sp,sp,32
          78:	00008067          	ret
レジスタa0とレジスタa1に値をいれて、アドレス2cでジャンプ(jalr)している。ライブラリを呼んでいるようなので、実行ファイルで確認する。

       $ riscv32-unknown-elf-objdump -d div_rve32i  
スタートアップルーチンとprintfのコードが含まれてしまったので、一部だけ抜粋

        000101ac <main>:
           101ac:       fe010113                addi    sp,sp,-32
           101b0:       00112e23                sw      ra,28(sp)
           101b4:       00812c23                sw      s0,24(sp)
           101b8:       02010413                addi    s0,sp,32
           101bc:       00200793                li      a5,2
           101c0:       fef42623                sw      a5,-20      (s0)
           101c4:       fe042423                sw      zero,-24        (s0)
           101c8:       0340006f                j       101fc       <main+0x50>
           101cc:       fec42583                lw      a1,-20      (s0)
           101d0:       fec42503                lw      a0,-20      (s0)
           101d4:       04c000ef                jal     ra,10220        <__mulsi3>
           101d8:       00050793                mv      a5,a0
           101dc:       fef42623                sw      a5,-20      (s0)
           101e0:       fec42583                lw      a1,-20      (s0)
           101e4:       000217b7                lui     a5,0x21
           101e8:       33078513                addi    a0,a5,      816 # 21330 <__clzsi2+0x5\
        0>
アドレス101ccとアドレス101d0でレジスタa0とレジスタa1に引数をセットして、アドレス101d4でジャンプしている。  
飛び先の逆アセンブル結果は、以下の通り。

        00010220 <__mulsi3>:
           10220:       00050613                mv      a2,a0
           10224:       00000513                li      a0,0
           10228:       0015f693                andi    a3,a1,1
           1022c:       00068463                beqz    a3,10234 <__mulsi3      +0x14>
           10230:       00c50533                add     a0,a0,a2
           10234:       0015d593                srli    a1,a1,0x1
           10238:       00161613                slli    a2,a2,0x1
           1023c:       fe0596e3                bnez    a1,10228 <__mulsi3      +0x8>
           10240:       00008067                ret

被乗数を左シフトしながら、乗数の最下位ビットが１のときだけ加算している。  
乗算を加算命令のみで実行しているため、rv32i(乗算器なし)のコードが生成できている。問題ない。
