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


class easyStepper {
  private:
    int _STEP;
    int _DIR;
    int _MS1;
    int _MS2;
    int _EN;

  public:
    easyStepper(int STEP, int DIR, int MS1, int MS2, int EN) {
      _STEP = STEP;
      _DIR = DIR;
      _MS1 = MS1;
      _MS2 = MS2;
      _EN = EN;
    }
    void begin() {
      pinMode(_MS1, OUTPUT);
      pinMode(_MS2, OUTPUT);
      pinMode(_EN, OUTPUT);
      resetEDPins();
      setMicrostepRes(1);
      enable();
    }
    void enable(){
      digitalWrite(_EN, LOW);
    }
    void disable(){
      digitalWrite(_EN, HIGH);
    }
    void setMicrostepRes(int res) {
      switch (res) {
        case 1:
          digitalWrite(_MS1, LOW);
          digitalWrite(_MS2, LOW);
          break;
        case 2:
          digitalWrite(_MS1, HIGH);
          digitalWrite(_MS2, LOW);
          break;
        case 4:
          digitalWrite(_MS1, LOW);
          digitalWrite(_MS2, HIGH);
          break;
        case 8:
          digitalWrite(_MS1, HIGH);
          digitalWrite(_MS2, HIGH);
          break;
      }
    }
    void resetEDPins()
    {
      digitalWrite(_MS1, LOW);
      digitalWrite(_MS2, LOW);
      digitalWrite(_EN, HIGH);
    }
};

StepControl controller;

Stepper motor_r(M1_STEP, M1_DIR);
easyStepper driver_l(M1_STEP, M1_DIR, M1_MS1, M1_MS2, M1_EN);

Stepper motor_l(M2_STEP, M2_DIR);
easyStepper driver_r(M2_STEP, M2_DIR, M2_MS1, M2_MS2, M2_EN);

int speed = 100; //Max Speed = 825, Min Speed = 300-400
int accel = 500; 
int target = 0;
int steps_l1;
int steps_l2;
int current_pos_l;
int current_pos_r;
void setup() {
  Serial.begin(9600);

  motor_l
  .setInverseRotation(false)
  .setAcceleration(accel)
  .setMaxSpeed(speed);

  motor_r
  .setInverseRotation(true)
  .setAcceleration(500)
  .setMaxSpeed(accel);

  /*
   * Best speed ~100 Steps/s full stepping
   * Microstepping works well - even down to 8
   */

  driver_l.begin();
  driver_r.begin();
}
void loop() {
  while (!Serial) {};
  current_pos_l = motor_l.getPosition();
  current_pos_r = motor_r.getPosition();
  Serial.print("Current Position:");
  Serial.print(current_pos_l);
  Serial.print(",");
  Serial.println(current_pos_r);
  
  Serial.println("Enter L1: ");
  while (!Serial.available()) {};
  steps_l1 = Serial.parseInt();
  while (Serial.available()) {Serial.read();}
  
  Serial.println("Enter L2: ");
  while (!Serial.available()) {};
  steps_l2 = Serial.parseInt();
  while (Serial.available()) {Serial.read();}

  motor_l.setTargetAbs(steps_l1);
  motor_r.setTargetAbs(steps_l2);
  
  controller.move(motor_l, motor_r);

  delay(1000);
}
