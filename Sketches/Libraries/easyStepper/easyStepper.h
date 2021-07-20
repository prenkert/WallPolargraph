#ifndef easyStepper_h
#define easyStepper_h

#include "Arduino.h"

class easyStepper 
{
  private:
    int _STEP;
    int _DIR;
    int _MS1;
    int _MS2;
    int _EN;

  public:
    easyStepper(int STEP, int DIR, int MS1, int MS2, int EN);
    void begin();
    void enable();
    void disable();
    void setMicrostepRes(int res);
    void resetEDPins();
};

#endif
