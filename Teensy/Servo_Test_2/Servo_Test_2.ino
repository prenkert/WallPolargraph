#include <Servo.h>

const int penServo_PIN = 23;
byte servo_pos;

byte servo_positions[3] = {80, 115, 175};
Servo penServo;

int pos;
void setup() {
  penServo.attach(penServo_PIN);
  Serial.begin(9600);
  while (Serial.available()) {
    Serial.read();
  }

}

void loop() {
  while (!Serial.available()) {};
  servo_pos = servo_positions[Serial.parseInt()];
  while (Serial.available()) {
    Serial.read();
  }
  Serial.print("Setting servo to: ");
  Serial.print(servo_pos);
  Serial.println();

  penServo.write(servo_pos);
}

/*
  Rough Servo Starting Positions:
  Min Servo Pos = 80
  Max Servo Pos = 175
  Home Servo Pos = 115
*/
