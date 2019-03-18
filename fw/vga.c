/*
 * *****************************************************************
 * File: night.c
 * Category: FW
 * File Created: 2019/02/17 07:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Sat Mar 16 2019
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

#define VGA  (0x60000000)
  

void wait(unsigned int wait);

void main()
{
    int i;
    int led;

    for(int y=0;y<480;y++)
        for(int x=0;x<640;x++)
        *(volatile int *)(VGA+y*480+x) = 
                    ((y>>4)&0x0f) + (((x>>4)&0x0f)<<4) + ((((x+y)>>4)&0x0f)<<8);
    while(1);

}


void wait(unsigned int wait)
{
    for (int i = 0; i < wait;i++)
        ;

    return;
}
