#ifndef WallBot_h
#define WallBot_h

#include <TeensyStep.h>
#include <easyStepper.h>
#include <Servo.h>
#include <EEPROM.h>

class WallBot {
  private:
    //M2 (Right) Pins
    const byte M2_STEP = 2;
    const byte M2_DIR = 3;
    const byte M2_MS1 = 4;
    const byte M2_MS2 = 5;
    const byte M2_EN = 6;

    //M1 (Left) Pins
    const byte M1_STEP = 14;
    const byte M1_DIR = 15;
    const byte M1_MS1 = 16;
    const byte M1_MS2 = 17;
    const byte M1_EN = 18;

    const byte PEN_SERVO_PIN = 23;

    //Nested Classes
    StepControl controller;

    Stepper motor_1;
    easyStepper driver_1;

    Stepper motor_2;
    easyStepper driver_2;

    Servo pen_servo; //May need to use another servo library to control speed and accel

    //Private Variables


  public:
    //Public Variables
    int speed;
    int accel;
    int microstep_res;
    int current_positions[2];
    int current_abs_targets[2];
    int current_PI;
    int current_PO;
    int min_PIPO; 
    int max_PIPO;
    int current_servo_position;
    int servo_positions[3] = {80, 120, 175};
    int stepper_trim_values[2] = {0, 0};
    /*
      Rough Servo Starting Positions:
      Min Servo Pos = 80 = max_servo_positions[0]
      Home Servo Pos = 115 = max_servo_positions[1]
      Max Servo Pos = 175 = max_servo_positions[2]
    */

    //Public Methods
    WallBot(int set_speed, int set_accel, int set_PIPO, int set_microstep_res) :
      motor_1(M1_STEP, M1_DIR),
      motor_2(M2_STEP, M2_DIR),
      driver_1(M1_STEP, M1_DIR, M1_MS1, M1_MS2, M1_EN),
      driver_2(M2_STEP, M2_DIR, M2_MS1, M2_MS2, M2_EN)

    {
      speed = set_speed; //100 good default
      accel = set_accel; //500 good default
      min_PIPO = set_PIPO;
      current_PI = min_PIPO;
      current_PO = min_PIPO;
      max_PIPO = speed/4;
      microstep_res = set_microstep_res;

    }

    void begin() {
      pen_servo.attach(PEN_SERVO_PIN);

      motor_1
      .setInverseRotation(false)
      .setAcceleration(accel)
      .setMaxSpeed(speed)
      .setPullInOutSpeed(current_PI, current_PO);

      motor_2
      .setInverseRotation(true)
      .setAcceleration(accel)
      .setMaxSpeed(speed)
      .setPullInOutSpeed(current_PI, current_PO);

      driver_1.begin();
      driver_1.setMicrostepRes(microstep_res);
      
      driver_2.begin();
      driver_2.setMicrostepRes(microstep_res);

      readTrimsFromEEPROM();
      setPositions(-stepper_trim_values[0], -stepper_trim_values[1]); //Assume wallbot begins in resting state

      pinMode(13, OUTPUT);
      digitalWrite(13, HIGH);
      delay(1000);
      digitalWrite(13, LOW);
    }

    void disable() {
      driver_1.disable();
      driver_2.disable();
      setPositions(-stepper_trim_values[0], -stepper_trim_values[1]); //Assume wallbot goes back to resting state when steppers are disabled
    }

    void enable() {
      driver_1.enable();
      driver_2.enable();
    }
    void setSpeed(int cmd_speed) {
      if (cmd_speed >= 0) {
        speed = cmd_speed;
        max_PIPO = speed;
        motor_1.setMaxSpeed(cmd_speed);
        motor_2.setMaxSpeed(cmd_speed);
      }

      Serial.print("Set speed to: ");
      Serial.println(speed);
    }

    void setAccel(int cmd_accel) {
      if (cmd_accel >= 0) {
        accel = cmd_accel;
        motor_1.setAcceleration(cmd_accel);
        motor_2.setAcceleration(cmd_accel);
      }

      Serial.print("Set acceleration to: ");
      Serial.println(accel);
    }

    void setPIPORelative(int rel_dir_change) {
      rel_dir_change = (rel_dir_change>0) ? rel_dir_change : 0;
      int new_PIPO = map(rel_dir_change, 0, 100, min_PIPO, max_PIPO);
      new_PIPO = min(new_PIPO, 10000);
      Serial.print("Setting PIPO Speed To: ");
      Serial.println(new_PIPO);
      current_PI = current_PO;
      current_PO = new_PIPO;
      motor_1.setPullInSpeed(min(current_PI, current_PO));
      motor_2.setPullInSpeed(min(current_PI, current_PO));
      
    }

    void setTargetAbs(int steps_l1, int steps_l2) {
      current_abs_targets[0] = steps_l1;
      current_abs_targets[1] = steps_l2;

      motor_1.setTargetAbs(steps_l1);
      motor_2.setTargetAbs(steps_l2);
    }

    void move() {
      enable();
      controller.move(motor_1, motor_2);
      updatePositions();
    }

    void lineDirect(int l1, int l2, int z) {
      Serial.print("lineDirect To: ");
      Serial.print(l1);
      Serial.print(", ");
      Serial.print(l2);
      Serial.print(", ");
      Serial.println(z);

      if (z >= 0 && z <= 2) {
        moveServo(z);
        Serial.print("Moved Servo to: ");
        Serial.println(z);
      }
      setTargetAbs((l1 >= 0) ? l1 : current_abs_targets[0], (l2 >= 0) ? l2 : current_abs_targets[1]);
      move();

      Serial.print("Move Complete, Current Position: ");
      Serial.print(current_positions[0]);
      Serial.print(",");
      Serial.println(current_positions[1]);
    }

    void lineInterpolated() {

    }

    void updatePositions() {
      current_positions[0] = motor_1.getPosition();
      current_positions[1] = motor_2.getPosition();
    }

    void zeroPositions() {
      motor_1.setPosition(0);
      motor_2.setPosition(0);
      updatePositions();
    }

    void setPositions(int l_pos, int r_pos) {
      motor_1.setPosition(l_pos);
      motor_2.setPosition(r_pos);
      updatePositions();
    }

    void setTrims(int l_trim, int r_trim) {
      l_trim = (l_trim > 0) ? l_trim : 0;
      r_trim = (r_trim > 0) ? r_trim : 0;

      Serial.print("Setting Trim Values to: ");
      Serial.print(l_trim);
      Serial.print(" , ");
      Serial.println(r_trim);

      motor_1.setPosition(motor_1.getPosition() + stepper_trim_values[0] - l_trim);
      motor_2.setPosition(motor_2.getPosition() + stepper_trim_values[1] - r_trim);
      stepper_trim_values[0] = l_trim;
      stepper_trim_values[1] = r_trim;
      writeTrimsIntoEEPROM();
      updatePositions();
    }

    void moveServo(int servo_pos) {
      /* 0 = Min Servo Pos
         1 = Home Servo Pos
         2 = Max Servo Pos
      */
      int new_pos = servo_positions[servo_pos];
      Serial.print("Current Servo Position: ");
      Serial.println(new_pos);
      if (new_pos != current_servo_position) {
        pen_servo.write(new_pos);
        delay(1000); //Wait for servo to hit new position
        current_servo_position = new_pos;
      }

    }
    void setServoWritingPosition(int servo_pos) {
      if (servo_pos == -1) {
        return;
      }
      else if (servo_pos > servo_positions[0] && servo_pos < servo_positions[2]) {
        Serial.print("Setting Servo Position to: ");
        Serial.println(servo_pos);
        servo_positions[1] = servo_pos;
      }
      else {
        Serial.println("Servo writing position out of bounds");
      }
    }

    void writeTrimsIntoEEPROM()
    {
      byte data_bytes[4];
      data_bytes[0] = stepper_trim_values[0] >> 8;
      data_bytes[1] = stepper_trim_values[0] & 0xFF;
      data_bytes[2] = stepper_trim_values[1] >> 8;
      data_bytes[3] = stepper_trim_values[1] & 0xFF;
      for (int i = 0; i < 4; i++) {
        EEPROM.write(i, data_bytes[i]);
      }

      Serial.print("Wrote Trim Values into EEPROM: ");
      Serial.print(stepper_trim_values[0]);
      Serial.print(", ");
      Serial.println(stepper_trim_values[1]);
    }

    void readTrimsFromEEPROM()
    {
      byte data_bytes[4];
      for (int i = 0; i < 4; i++) {
        data_bytes[i] = EEPROM.read(i);
        data_bytes[i] = (data_bytes[i] == 255) ? 0 : data_bytes[i];
      }
      stepper_trim_values[0] = (data_bytes[0] << 8) + data_bytes[1];
      stepper_trim_values[1] = (data_bytes[2] << 8) + data_bytes[3];

      Serial.print("Read Trim Values from EEPROM: ");
      Serial.print(stepper_trim_values[0]);
      Serial.print(", ");
      Serial.println(stepper_trim_values[1]);

    }



};

#endif
