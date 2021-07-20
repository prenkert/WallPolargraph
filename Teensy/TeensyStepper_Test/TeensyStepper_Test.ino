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


Stepper motor_1(M1_STEP, M1_DIR);
StepControl controller_1;

Stepper motor_2(M2_STEP, M2_DIR);
StepControl controller_2;


int speed = 800; //Max Speed = 825, Min Speed = 300-400
int target = 0;
void setup() {
  Serial.begin(9600);
  
  motor_1
    .setAcceleration(2500)
    .setMaxSpeed(speed);
  
  pinMode(M1_MS1, OUTPUT);
  pinMode(M1_MS2, OUTPUT);
  pinMode(M1_EN, OUTPUT);
  resetEDPins();
  setMicrostepRes(1);
}
void loop() {
  while(!Serial){};
  Serial.println("Set Max Speed");
  while(!Serial.available()){};
  speed = Serial.parseInt();
  motor_1.setMaxSpeed(speed);
  while(Serial.available()){Serial.read();}
  Serial.println("Set Rel Target");
  while(!Serial.available()){};
  target = Serial.parseInt();
  motor_1.setTargetRel(target);
  while(Serial.available()){Serial.read();}
  
  digitalWrite(M1_EN, LOW);
  controller.move(motor_1);
  digitalWrite(M1_EN, HIGH);
  delay(1000);
}

void resetEDPins()
{
  digitalWrite(M1_MS1, LOW);
  digitalWrite(M1_MS2, LOW);
  digitalWrite(M1_EN, HIGH);
}

void setMicrostepRes(int res)
{
  switch (res)
  {
    case 1: 
      digitalWrite(M1_MS1, LOW);
      digitalWrite(M1_MS2, LOW);
      break;
    case 2:
      digitalWrite(M1_MS1, HIGH);
      digitalWrite(M1_MS2, LOW);
      break;
    case 4:
      digitalWrite(M1_MS1, LOW);
      digitalWrite(M1_MS2, HIGH);
      break;
    case 8:
      digitalWrite(M1_MS1, HIGH);
      digitalWrite(M1_MS2, HIGH);
      break;
  }
}
