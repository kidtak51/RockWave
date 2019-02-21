/*
 * *****************************************************************
 * File: night.c
 * Category: FW
 * File Created: 2019/02/17 07:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Fri Feb 22 2019
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

void led_out(unsigned char led);

void main()
{
    int i;
    int wait;
    int led;
    int a,b;

    a=0;
    b=0;

    while(a==b){
        led = 1;
        for(i=0;i<7;i++){
            led = led << 1;
            led_out(led);
            for(wait=0;wait<3000000;wait++);
        }
        for(i=0;i<7;i++){
            led = led >> 1;
            led_out(led);
            for(wait=0;wait<3000000;wait++);
        }
    }

}


void led_out(unsigned char led)
{
    return;
}
