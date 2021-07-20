#include <TeensyStep.h>
const int M1_STEP = 2;
const int M1_DIR = 3;
const int M1_MS1 = 4;
const int M1_MS2 = 5;
const int M1_EN = 6;

const int M2_STEP = 14;
const int M2_DIR = 15;
const int M2_MS1 = 16;
const int M2_MS2 = 17;
const int M2_EN = 18;


Stepper motor(M1_STEP, M1_DIR);
StepControl controller;

int STEP;
int DIR;
int MS1;
int MS2;
int EN;


int speed = 800; //Max Speed = 825, Min Speed = 300-400
int target = 0;
void setup() {
  Serial.begin(9600);
  
  defineMotor(1);
  
  motor
    .setAcceleration(2500)
    .setMaxSpeed(speed);
  
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(EN, OUTPUT);
  resetEDPins();
  setMicrostepRes(1);
}
void loop() {
  while(!Serial){};
  Serial.println("Set Max Speed");
  while(!Serial.available()){};
  speed = Serial.parseInt();
  motor.setMaxSpeed(speed);
  while(Serial.available()){Serial.read();}
  Serial.println("Set Rel Target");
  while(!Serial.available()){};
  target = Serial.parseInt();
  motor.setTargetRel(target);
  while(Serial.available()){Serial.read();}
  
  digitalWrite(EN, LOW);
  controller.move(motor);
  digitalWrite(EN, HIGH);
  delay(1000);
}

void resetEDPins()
{
  digitalWrite(MS1, LOW);
  digitalWrite(MS2, LOW);
  digitalWrite(EN, HIGH);
}

void setMicrostepRes(int res)
{
  switch (res)
  {
    case 1: 
      digitalWrite(MS1, LOW);
      digitalWrite(MS2, LOW);
      break;
    case 2:
      digitalWrite(MS1, HIGH);
      digitalWrite(MS2, LOW);
      break;
    case 4:
      digitalWrite(MS1, LOW);
      digitalWrite(MS2, HIGH);
      break;
    case 8:
      digitalWrite(MS1, HIGH);
      digitalWrite(MS2, HIGH);
      break;
  }
}
void defineMotor(int mot){
  switch(mot){
    case 1:
      STEP = M1_STEP;
      DIR = M1_DIR;
      MS1 = M1_MS1;  
      MS2 = M1_MS2;
      EN = M1_EN;
      break;
    case 2:
      STEP = M2_STEP;
      DIR = M2_DIR;
      MS1 = M2_MS1;  
      MS2 = M2_MS2;
      EN = M2_EN;
      break ;     
  }
}
