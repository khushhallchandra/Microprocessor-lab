#include<reg51.h>
#include<intrins.h>
//#include "at89c5131.h"
//#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void LCD_Init();
void Timer_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit SDA=P0^5;
sbit SCL=P0^6;
bit take_samples=0;
int adcVal=0;
unsigned char data2;
unsigned char data1;
unsigned char count=0;
char c;

void I2CInit()
{
	SDA = 1;
	SCL = 1;
}
 
void I2CStart()
{
	SDA = 0;
	SCL = 0;
}
 
void I2CRestart()
{
	SDA = 1;
	SCL = 1;
	SDA = 0;
	SCL = 0;
}
 
void I2CStop()
{
	SCL = 0;
	SDA = 0;
	SCL = 1;
	SDA = 1;
}
 
void I2CAck()
{
	SDA = 0;
	SCL = 1;
	SCL = 0;
	SDA = 1;
}
 
void I2CNak()
{
	SDA = 1;
	SCL = 1;
	SCL = 0;
	SDA = 1;
}
 
unsigned char I2CSend(unsigned char Data)
{
	 unsigned char i, ack_bit;
	 for (i = 0; i < 8; i++) {
		if ((Data & 0x80) == 0)
			SDA = 0;
		else
			SDA = 1;
		SCL = 1;
	 	SCL = 0;
		Data<<=1;
	 }
	 SDA = 1;
	 SCL = 1;
	 ack_bit = SDA;
	 SCL = 0;
	 return ack_bit;
}
 
unsigned char I2CRead()
{
	unsigned char i, Data=0;
	for (i = 0; i < 8; i++) {
		SCL = 1;
		if(SDA)
			Data |=1;
		if(i<7)
			Data<<=1;
		SCL = 0;
	}
	return Data;
}

 
void main(void)
{
//	P3 = 0XEF;											// Make Port 3 output 
//	P2 = 0x00;											// Make Port 2 output 
//	P1 = 0xEF;											// Make P1 Pin4-7 output
//	P0 &= 0xF0;											// Make Port 0 Pins 0,1,2 output
	//SPI_Init();
	LCD_Init();
	Timer_Init();
	
	
	/* Init i2c ports first */
	I2CInit();
	I2CStart();
	I2CSend(0xA6);
	I2CSend(0x31);
	I2CSend(0x01);
	I2CStop();
	I2CStart();
	I2CSend(0xA6);
	I2CSend(0x2D);
	I2CSend(0x08);
	/*
	 * ack == 1 => NAK
	 * ack == 0 => ACK
	 */

	I2CStop();
 I2CInit();
 
	while(1)												// endless 
	{	
		while(take_samples){
			take_samples=0;
			
			if(count==10){
				count=0;
				I2CStart();
				I2CSend(0xA6);
				I2CSend(0xB2);
				I2CRestart();
				I2CSend(0xA7);
				data1 = I2CRead();
				I2CAck();
				data2 = I2CRead();
				//data2 = ((data1 & 0xf0) >> 4) | ((data1 & 0x0f) << 4);
				I2CNak();
				I2CStop();
				adcVal = (data2 <<8) + (data1);
				adcVal = adcVal+250;
				//adcVal=12345;
				LCD_CmdWrite(0xC0);
				LCD_StringWrite("V: ",3);
				c = (adcVal/10000)+'0';
				LCD_DataWrite(c);
				c = (adcVal/1000)-(adcVal/10000)*10+'0';
				LCD_DataWrite(c);
				c = (adcVal/100)-(adcVal/1000)*10+'0';
				LCD_DataWrite(c);
				c = (adcVal/10)-(adcVal/100)*10+'0';
				LCD_DataWrite(c);
				c = adcVal-(adcVal/10)*10+'0';
				LCD_DataWrite(c);
//				for( i=3;i>=0;i--){
//					c[i]=adcVal%10;
//					adcVal=adcVal/10;
//				}
				LCD_StringWrite(" mV",3);
			}
		}
  }
}

void timer0_ISR (void) interrupt 1
{
	TH0 = 0x3C;											//For 25ms operation
	TL0 = 0xB0;
	take_samples=1;
	count++;
}


void Timer_Init()
{
	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
	// 65536 depending upon the calues of TH0 and TL0
	// The timer counts 65536 processor cycles. A processor cycle is 
	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
	// By setting TH0TL0 to 3CB0H, the timer overflows every 25 ms
	
	TH0 = 0x3C;											//For 25ms operation
	TL0 = 0xB0;
	TMOD = (TMOD & 0xF0) | 0x01;  	// Set T/C0 Mode 
	EA=1;                         	
	ET0 = 1;                      	// Enable Timer 0 Interrupts 
	TR0 = 1;                      	// Start Timer 0 Running 
	count =0;
}
	/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
	LCD_Ready();
	LCD_data=cmd;     			// Send the command to LCD
	LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  LCD_data=dat;	   				// Send the data to LCD
  LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
  LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}
/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_StringWrite( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}