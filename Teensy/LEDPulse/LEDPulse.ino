/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.

  This example code is in the public domain.
 */

// Pin 13 has an LED connected on most Arduino boards.
// Pin 11 has the LED on Teensy 2.0
// Pin 6  has the LED on Teensy++ 2.0
// Pin 13 has the LED on Teensy 3.0
// give it a name:
int LED_pin = 35;

// the setup routine runs once when you press reset:
void setup() {
  // initialize the digital pin as an output.
  pinMode(LED_pin, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
}

// the loop routine runs over and over again forever:
void loop() {
  for (int i=0; i<=255; i++){
    analogWrite(LED_pin, i);
    delay(5);
  }
  for (int i=255; i>=0; i+=-1){
    analogWrite(LED_pin, i);
    delay(5);
  }
}
