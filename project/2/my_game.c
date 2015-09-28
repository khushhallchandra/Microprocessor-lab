/*Program to display simple text on Graphics LCD*/

#include<reg51.h>
#include<intrins.h>
#include<stdlib.h>
#define LCD_data P2

void LCD_CmdWrite(char cmd);
void Timer_Init();
void ctrloff();	
void setY(unsigned int y);
void setX(unsigned char x);
void writeAtXY(unsigned char x,unsigned char y, char val);
void sdelay(int delay);
void GLCD_WriteData( char dat,int cs);
void clearAll();
void makeCar();
void makeEnemy();
void moveForward();
void moveRight();
void moveLeft();
	
sbit SDA=P0^5;
sbit SCL=P0^6;
sbit rs=P0^0;
sbit rw=P0^1;
sbit en=P0^2;
sbit cs1=P3^0;
sbit cs2=P3^1;
int xVal=500,yVal=0,random=500,height_level=0,speed_level=8;
unsigned char data2;
unsigned char data1;
unsigned char count1=0,count2=0;

int cX,cY,eX,eY;

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
int u(int n){
	if(n>=0)return n;
	else return 0;
}
void I2Cinitialize(){
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
}

void main(){
	//CODE IS WORKING FINE
	P0 |=0x01;
	P0 &=0xEF;
	
	P1=0xff;
	height_level= P1 & 0x0f;
	I2Cinitialize();
	clearAll();
	makeCar();
	makeEnemy();
	Timer_Init();
	while(1){
		//write code here
		if(count2>1+u(5-abs(xVal-500)/15)){
			count2=0;
			I2CStart();
			I2CSend(0xA6);
			I2CSend(0xB2);
			I2CRestart();
			I2CSend(0xA7);
			data1 = I2CRead();
			I2CAck();
			data2 = I2CRead();
			xVal = (data2 <<8) + (data1);
			I2CAck();
			data1 = I2CRead();
			I2CAck();
			data2 = I2CRead();
			I2CNak();
			I2CStop();
			yVal = (data2 <<8) + (data1);
			xVal = xVal+500;
			random=xVal*cX;
			//random=6(atan(double(xVal%7-cX)) +3.14/2)/3.14;
			if(xVal>510 & cX<6){
				moveRight();
			}
			else if(xVal<490 & cX>0){
				moveLeft();
			}
		}
	}	
}

void makeCar(){
	int i,j;
	cX=0,cY=0;
	for(i=cX;i<cX+2;i++){
		for(j=0;j<16;j++){
			writeAtXY(i,j,0xff);
		}
	}
}

void makeEnemy(){
	int i,j;
	eX=random%7;
	eY=32+5*(16-height_level);
	for(i=eX;i<eX+2;i++){
		for(j=eY;j<eY+16;j++){
			writeAtXY(i,j,0xff);
		}
	}
}

void moveForward(){
	int i;
	for(i=eX;i<eX+2;i++){
			if(16+eY<128 & 16+eY>=0)writeAtXY(i,16+eY,0x00);
			if(eY<128 & eY>=0)writeAtXY(i,eY,0xff);
	}
	eY--;
}

void moveLeft(){
	int j;
	cX--;
	for(j=0;j<16;j++){
			writeAtXY(cX,j,0xff);
			writeAtXY(cX+2,j,0x00);
	}
}

void moveRight(){
	int j;
	for(j=0;j<16;j++){
			writeAtXY(cX,j,0x00);
			writeAtXY(cX+2,j,0xff);
	}
	cX++;
}
void clearAll(){
	int i,j;
	LCD_CmdWrite(0x3f);
	for ( i = 0 ; i < 8; i++ ){
		for(j = 0 ; j < 128; j++ ){
			writeAtXY(i,j,0x00);
		}
	}
}
/**
writeAtXY()
This function takes 3input
1. X value [0,7]
2. Y value [0,127]
3. val which can be 0xff/0x00
4. Effectively this function goes to (x,y) and turn it on/off.
*/
void writeAtXY(unsigned char x,unsigned char y, char val){
	int p=y%128;
	setX(x);
	setY(y);
	GLCD_WriteData(val,p);
}

//------------------------------------------------------------------------------
//This module set X-axis
// Note: X takes value from 0 to 7
// then set Y-axis accordingly
// Note: Y takes value from 0 to 127
//After this call GLCD_WriteData( char dat,int cs)

void setX(unsigned char x)  
{
	LCD_data= 0xb8|x;	
	LCD_CmdWrite(LCD_data);
}
void setY(unsigned int y) 
{	
	y=y%64;
	LCD_data= (0x40 | y );	 
	LCD_CmdWrite(LCD_data);
}
//----------------------------------------------------------------------------------------------------------------------

void LCD_CmdWrite(char cmd){
	ctrloff();
	LCD_data=cmd;     			
	rs=0;rw=0;          			
	cs1=cs2=1;
	en=1;          			
  sdelay(1);
  en=0;
	sdelay(1);
}

void GLCD_WriteData( char dat,int cs){
	ctrloff();
  LCD_data=dat;	   			
  rs=1;rw=0;    	     			
  en=1;	   						
	if(cs<64){	cs1=1;cs2=0;	}
	else{	cs1=0;cs2=1;	}
  sdelay(1);
  en=0;
	sdelay(1);
}

void sdelay(int delay){
	//int d=0;
	while(delay>0){
		//for(d=0;d<1;d++);
		delay--;
	}
}

void ctrloff(){
	rs=0;
	rw=0;
	en=0;
	cs1=0;
	cs2=0;
}
void timer0_ISR (void) interrupt 1
{
	TH0 = 0xC0;											//For 25ms operation
	TL0 = 0x00;
	P1=0xff;
	height_level= P1 & 0x0f;
	if(eY<16 & eY+16>=0 & cX < eX+2 & cX > eX-2){}
	else{
		if(count1>=u(8-yVal/10)){
			count1=0;
			if(16+eY==0){
				moveForward();
				eY=47+5*(16-height_level);
				eX=random%7;
			}
			else moveForward();
		}
		count1++;
		count2++;
	}
}


void Timer_Init()
{
	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
	// 65536 depending upon the calues of TH0 and TL0
	// The timer counts 65536 processor cycles. A processor cycle is 
	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
	// By setting TH0TL0 to 3CB0H, the timer overflows every 25 ms
	
	TH0 = 0xC0;											//For 25ms operation
	TL0 = 0x00;
	TMOD = (TMOD & 0xF0) | 0x01;  	// Set T/C0 Mode 
	EA=1;                         	
	ET0 = 1;                      	// Enable Timer 0 Interrupts 
	TR0 = 1;                      	// Start Timer 0 Running 
}