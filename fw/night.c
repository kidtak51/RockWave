/*
 * *****************************************************************
 * File: night.c
 * Category: FW
 * File Created: 2019/02/17 07:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Wed Mar 06 2019
 * Modified By: Masaru Aoki
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   RockWave テストプログラム
 *         Night Rider LED
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/2/17	Masaru Aoki	First Version
 * *****************************************************************
 */

#define GPIO_IN  (0x70000000+0x0010)
#define GPIO_OUT (0x70000000+0x0020)
  

void wait(unsigned int wait);

void main()
{
    int i;
    int led;

    while(1){
        led = 1;
        for(i=0;i<7;i++){
            led = led << 1;
//            led_out(led);
            *(volatile int *)(GPIO_OUT) = led;
            wait(2000000);
        }
        for(i=0;i<7;i++){
            led = led >> 1;
//            led_out(led);
            *(volatile int *)(GPIO_OUT) = led;
            wait(2000000);
        }
    }

}


void wait(unsigned int wait)
{
    for (int i = 0; i < wait;i++)
        ;

    return;
}
