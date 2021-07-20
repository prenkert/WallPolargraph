#include "WallBot.h"

#include <SD.h>
#include <SPI.h>

bool serial_flag = false;
File gcode_file;
const int chipSelect = BUILTIN_SDCARD;

const byte MAX_BUF = 128;
char cmd_buffer[MAX_BUF];
byte buffer_index = 0; 
bool buffer_ready = false;
bool end_flag = false;

const char EXIT_CHAR = 'E';


int microstep_res = 8;
int speed = 50*microstep_res;
int accel = 20*microstep_res;
int PIPO = 50;

WallBot wallbot(speed, accel, PIPO, microstep_res);

void setup() {
  Serial.begin(9600);
  delay(5000);
  Serial.print("Press Any Key to Enter USB Serial Mode: ");
  int current_time = millis();
  while ((millis() - current_time) < 10000 && !serial_flag) {
    if (Serial.available()) {
      Serial.println(Serial.read());
      serial_flag = true;
      while (Serial.available()) Serial.read();
    }
  }

  if (serial_flag) {
    Serial.println("Entering USB Serial Mode");
    Serial.println("Enter Command");
  }
  else {
    Serial.println("Entering SD Mode");
    initSD();
  }
  wallbot.begin();
  while ((serial_flag) ? !end_flag : (!end_flag && gcode_file.available())) {
    while (!buffer_ready && !end_flag) {
      while ((serial_flag) ? (!Serial.available()) : false) delay(100); //Pause between checking for command availability
      readCharToBuff((serial_flag) ? Serial.read() : gcode_file.read()); //This use of a ternary if/else might not work
    }
    if (!end_flag) {
      processCommand();
      clearBuffer();
      Serial.print("Enter Another Command or issue Exit Character: ");
      Serial.println(EXIT_CHAR);
    }
    else {
      Serial.println("Exiting Main Loop");
      if (!serial_flag) gcode_file.close();
      //resetSequence();
      break; //Break out of process loop
    }
  }
}


void loop() {

}

void initSD() {
  Serial.print("Initializing SD card...");
  if (!SD.begin(chipSelect)) {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization done.");
  // open the file.
  gcode_file = SD.open("GCODE.txt", FILE_READ);
  if (gcode_file) {
    Serial.println("Opened GCODE.txt for Reading:");
  }
  else {
    // if the file didn't open, print an error:
    Serial.println("error opening GCODE.txt");
  }
}

void readCharToBuff(char c) {
  Serial.print(c); // optional: repeat back what I got for debugging

  if (c == EXIT_CHAR) {
    Serial.println("Exit char received");
    end_flag = true;
    return; //Break out of loop over chars in line
  }
  else if (c == ';') {
    Serial.println(F("End of Line Reached"));
    cmd_buffer[buffer_index] = 0; // Final value in index will be zero unless an error occured
    buffer_ready = true; // do something with the command
  }
  else if (buffer_index < MAX_BUF) {
    if (c != '\n' && c != '\r')  cmd_buffer[buffer_index++] = c; // store the byte as long as there's room in the buffer.
  }
  else {
    Serial.println("Error in readCharToBuff");
    return;
  }
}

void processCommand() {
  Serial.println("Processing Command");

  // look for commands that start with 'G'
  int cmd_G = parseNumber('G', -1);
  int cmd_M = parseNumber('M', -1);
  Serial.print("Command Value: G");
  Serial.print(cmd_G);
  Serial.print(" M");
  Serial.println(cmd_M);
  switch (cmd_G) {
    case -1:
      break;
    case 0: // Direct linear move
      wallbot.setSpeed(parseNumber('F', -1));
      wallbot.setAccel(parseNumber('A', -1));
      wallbot.setPIPORelative(parseNumber('D', -100)); //Not Working Yet
      wallbot.lineDirect( parseNumber('L', -1),
                          parseNumber('R', -1),
                          parseNumber('Z', -1));
      break;
    default:
      Serial.println("Invalid Command");
      clearBuffer();
      break;
  }
  switch (cmd_M) {
    case -1:
      break;
    case 0: // Go to Home (zero) position
      Serial.println("Going Home");
      wallbot.lineDirect(0,0,0);
      break;
    case 1:
      Serial.println("Setting Trim Values");
      wallbot.setServoWritingPosition(parseNumber('Z', -1));
      wallbot.setTrims(parseNumber('L', -1), parseNumber('R', -1));
      break;
    case 2:
      Serial.print("Current Position: ");
      wallbot.updatePositions();
      Serial.print(wallbot.current_positions[0]);
      Serial.print(", ");
      Serial.println(wallbot.current_positions[1]);
      break;
    case 3:
      Serial.print("Setting Current Positions: ");
      wallbot.setPositions(parseNumber('L', -1), parseNumber('R', -1));
      Serial.print(wallbot.current_positions[0]);
      Serial.print(", ");
      Serial.println(wallbot.current_positions[1]);
      break;
    case 4:
      Serial.println("Disabling Drivers");
      wallbot.disable();
      break;
      }
}

void clearBuffer() {
  buffer_index = 0;
  buffer_ready = false;
}

int parseNumber(char code, int default_val) {
  /**
     Look for character /code/ in the buffer and read the int that immediately follows it.
     @return the value found.  If nothing is found, /val/ is returned.
     @input code the character to look for.
     @input val the return value if /code/ is not found.
   **/
  Serial.print("Parsing Number for ");
  Serial.print(code);
  Serial.print(": ");

  char *ptr = cmd_buffer; // start at the beginning of buffer
  int found_val = default_val;
  while ((long)ptr > 1 && (*ptr) && (long)ptr < (long)cmd_buffer + buffer_index) { // walk to the end
    //Serial.print(ptr);
    if (*ptr == code) { // if you find code on your walk,
      found_val = atoi(ptr + 1); // convert the digits that follow into a float and return it
      break;
    }
    ptr = strchr(ptr, ' ') + 1; // take a step from here to the letter after the next space
  }
  Serial.println(found_val);
  return found_val;  // end reached, nothing found, return default val.
}
