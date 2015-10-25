/*Program to display simple text on Graphics LCD*/

#include<reg51.h>
#include<intrins.h>
#include<stdlib.h>
#define LCD_data P2

void GLCD_CmdWrite(char cmd);
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
bit start2nd=0;
int xVal=500,yVal=0,random=500,height_level=0,speed_level=8;
unsigned char data2;
unsigned char data1;
unsigned char count1=0,count2=0;

int cX,cY,e1X,e1Y=112,e2X,e2Y=112;
int csize=1,esize=4;

void ADXLInit(){
	SDA=1;
	SCL=1;
}
 
void ADXLStart(){
	SCL=1;
	SDA=1;
	SDA=0;
	SCL=0;
}
 
void ADXLStop(){
	SCL=0;
	SDA=0;
	SCL=1;
	SDA=1;
}
 
void ADXLAck(){
	SDA=0;
	SCL=1;
	SCL=0;
	SDA=1;
}
 
void ADXLNak(){
	SDA=1;
	SCL=1;
	SCL=0;
	SDA=1;
}
 
void ADXLSend(unsigned char data1){
	 int i;
	 for(i=0;i<8;i++){
		if((data1 & 0x80)==0)	SDA=0;
		else	SDA=1;
		SCL=1;
	 	SCL=0;
		data1<<=1;
	 }
	 SDA=1;
	 SCL=1;
	 SCL=0;
}
 
unsigned char ADXLRead(){
	int i;
	unsigned char data1=0;
	for(i=0;i<8;i++){
		SCL=1;
		if(SDA)	data1 |=1;
		if(i<7)	data1<<=1;
		SCL = 0;
	}
	return data1;
}
int u(int n){
	if(n>=0)return n;
	else return 0;
}
void ADXLinitialize(){
	ADXLInit();
	ADXLStart();
	ADXLSend(0xA6);
	ADXLSend(0x31);
	ADXLSend(0x01);
	ADXLStop();
	ADXLStart();
	ADXLSend(0xA6);
	ADXLSend(0x2D);
	ADXLSend(0x08);
	ADXLStop();
	ADXLInit();
}

void main(){
	//CODE IS WORKING FINE
	P0 |=0x01;
	P0 &=0xEF;
	
	P1=0xff;
	height_level= P1 & 0x0f;
	ADXLinitialize();
	clearAll();
	makeCar();
	makeEnemy();
	Timer_Init();
	while(1){
		//write code here
		if(count2>1+u(5-abs(xVal-500)/15)){
			count2=0;
			ADXLStart();
			ADXLSend(0xA6);
			ADXLSend(0x32);
			ADXLStart();
			ADXLSend(0xA7);
			data1 = ADXLRead();
			ADXLAck();
			data2 = ADXLRead();
			xVal = (data2 <<8) + (data1);
			ADXLAck();
			data1 = ADXLRead();
			ADXLAck();
			data2 = ADXLRead();
			ADXLNak();
			ADXLStop();
			yVal = (data2 <<8) + (data1);
			xVal = xVal+500;
			random=xVal+yVal+500;
			//random=6(atan(double(xVal%7-cX)) +3.14/2)/3.14;
			if(xVal>510 & cX<(8-csize)){
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
	for(i=cX;i<cX+csize;i++){
		for(j=0;j<8*csize;j++){
			writeAtXY(i,j,0xff);
		}
	}
}

void makeEnemy(){
	int i,j;
	e1X=random%(9-esize);
	e1Y=48-8*esize+5*(16-height_level);
	for(i=e1X;i<e1X+esize;i++){
		for(j=e1Y;j<e1Y+8*esize;j++){
			writeAtXY(i,j,0xff);
		}
	}
}

void moveForward(int eX,int eY){
	int i;
	for(i=eX;i<eX+esize;i++){
			if(8*esize+eY<128 && 8*esize+eY>=0)writeAtXY(i,8*esize+eY,0x00);
			if(eY<128 && eY>=0)writeAtXY(i,eY,0xff);
	}
	//e1Y--;
}

void moveLeft(){
	int j;
	cX--;
	for(j=0;j<8*csize;j++){
			writeAtXY(cX,j,0xff);
			writeAtXY(cX+csize,j,0x00);
	}
}

void moveRight(){
	int j;
	for(j=0;j<8*csize;j++){
			writeAtXY(cX,j,0x00);
			writeAtXY(cX+csize,j,0xff);
	}
	cX++;
}
void clearAll(){
	int i,j;
	GLCD_CmdWrite(0x3f);
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
	GLCD_CmdWrite(LCD_data);
}
void setY(unsigned int y) 
{	
	y=y%64;
	LCD_data= (0x40 | y );	 
	GLCD_CmdWrite(LCD_data);
}
//----------------------------------------------------------------------------------------------------------------------

void GLCD_CmdWrite(char cmd){
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
	while(delay>0){
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
	TH0 = 0xC0;						// 8 ms							
	TL0 = 0x00;
	P1=0xff;
	height_level= P1 & 0x0f;
	//starting 2nd enemy
	if(start2nd==0 && e1Y<24+5*(8-height_level/2)){
		start2nd=1;
		e2X=random%(9-esize);
		e2Y=47+5*(16-height_level);
	}
	//checking for crash
	if((e1Y<8*csize && e1Y+8*esize>=0 && cX<e1X+esize && cX+csize>e1X)||(e2Y<8*csize && e2Y+8*esize>=0 && cX<e2X+esize && cX+csize>e2X)){}
	else{
		if(count1>=u(8-yVal/10)){ //for enemy motion
			count1=0;
			if(8*esize+e1Y==0){		//for 1st enemy
				moveForward(e1X,e1Y);
				e1Y--;
				e1Y=47+5*(16-height_level);
				e1X=random%(9-esize);
			}
			else {moveForward(e1X,e1Y);e1Y--;}
			if(start2nd){			
				if(8*esize+e2Y==0){	// for 2nd enemy
					moveForward(e2X,e2Y);
					e2Y--;
					e2Y=47+5*(16-height_level);
					e2X=random%(9-esize);
				}
				else {moveForward(e2X,e2Y);e2Y--;}
			}
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