#include "Arduino.h"
#include "easyStepper.h"

easyStepper::easyStepper(int STEP, int DIR, int MS1, int MS2, int EN)
{
  _STEP = STEP;
  _DIR = DIR;
  _MS1 = MS1;
  _MS2 = MS2;
  _EN = EN;
}

void easyStepper::begin()
{
  pinMode(_MS1, OUTPUT);
  pinMode(_MS2, OUTPUT);
  pinMode(_EN, OUTPUT);
  resetEDPins();
  setMicrostepRes(1);
  enable();
}

void easyStepper::enable() 
{
  digitalWrite(_EN, LOW);
}

void easyStepper::disable() 
{
  digitalWrite(_EN, HIGH);
}

void easyStepper::setMicrostepRes(int res) 
{
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
void easyStepper::resetEDPins()
{
  digitalWrite(_MS1, LOW);
  digitalWrite(_MS2, LOW);
  digitalWrite(_EN, HIGH);
}
