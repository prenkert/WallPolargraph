#include "WallBot.h"

int speed = 100; //Max Speed = 825, Min Speed = 300-400
int accel = 500; 
int target = 0;
int steps_l1;
int steps_l2;

WallBot wallbot(speed, accel);

void setup() {
  Serial.begin(9600);
  wallbot.begin();

}
void loop() {
  while (!Serial) {};

  wallbot.updatePositions();
  Serial.print("Current Position:");
  Serial.print(wallbot.current_positions[0]);
  Serial.print(",");
  Serial.println(wallbot.current_positions[1]);
  
  Serial.println("Enter L1: ");
  while (!Serial.available()) {};
  steps_l1 = Serial.parseInt();
  while (Serial.available()) {Serial.read();}
  
  Serial.println("Enter L2: ");
  while (!Serial.available()) {};
  steps_l2 = Serial.parseInt();
  while (Serial.available()) {Serial.read();}

  wallbot.setTargetAbs(steps_l1, steps_l2);
  wallbot.move();
  
  

  delay(1000);
}
