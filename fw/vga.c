/*
 * *****************************************************************
 * File: night.c
 * Category: FW
 * File Created: 2019/02/17 07:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Tue Mar 26 2019
 * Modified By: Masaru Aoki
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   RockWave テストプログラム
 *         VGA 表示
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/2/17	Masaru Aoki	First Version
 * *****************************************************************
 */

#define VGA_EN      (0x60000000)
#define VGA_BLANK   (0x60000004)
#define VRAM        (0x60100000)
#define GPIO_DFLT   (0x70000000)
#define GPIO_REFCLK (0x70000004)
#define GPIO_IN     (0x70000010)  
#define GPIO_OUT    (0x70000020)

void wait(unsigned int wait);

void main()
{
    int i;
    int led;

    *(volatile int *)(GPIO_DFLT) = 5;
    *(volatile int *)(GPIO_REFCLK) = 5;

    *(volatile int *)(VGA_EN) = 0x01; // vga_en

    // Wait CButton
    while ((*(volatile int *)(GPIO_IN) & 0x0200) == 0);
    *(volatile int *)GPIO_OUT = 0x000A;

    for(int y=0;y<480;y++)
        for(int x=0;x<640;x++){
            *(volatile int *)(VRAM + y * 640 + y) =
                0xFFF;
            //                    ((y>>4)&0x0f) + (((x>>4)&0x0f)<<4) + ((((x+y)>>4)&0x0f)<<8);
        }
    while (1)
        ;
}


void wait(unsigned int wait)
{
    for (int i = 0; i < wait;i++)
        ;

    return;
}
