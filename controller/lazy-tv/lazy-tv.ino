#include <Servo.h>
#include <IRremote.h>

struct STATE {
  boolean isMoving;
  boolean isAccelerating;
  unsigned long timeOfAccelerationStart;
  unsigned long timeOfLastCommand;
  unsigned long differenceSinceLastCommand;
};

const int RECV_PIN = 7;
const unsigned long REMOTE_KEY_LEFT = 0xE0E0A659;
const unsigned long REMOTE_KEY_RIGHT = 0xE0E046B9;
const unsigned long REMOTE_KEY_UP = 0xE0E006F9;
const unsigned long REMOTE_KEY_DOWN = 0xE0E08679;

const byte COMMAND_IDLE_THRESHOLD = 120;

const byte SERVO_PIN = 9;
const byte SERVO_ACCELERATING_LEFT_POSITION = 105;
const byte SERVO_MOVING_LEFT_POSITION = 103;//112;
const byte SERVO_ACCELERATING_RIGHT_POSITION = 81;
const byte SERVO_MOVING_RIGHT_POSITION = 85;//74;
const byte SERVO_STOP_POSITION = 90;
const int SERVO_ACCELERATION_DURATION = 200;

IRrecv irrecv(RECV_PIN);
decode_results results;
Servo myservo;
STATE state = { false, false, 0, 0, 0 };

void setup(){
  Serial.begin(9600);
  irrecv.enableIRIn();
  irrecv.blink13(true);
}

void loop(){
  state.differenceSinceLastCommand = millis() - state.timeOfLastCommand;

  if (irrecv.decode(&results)) {
    switch(results.value) {
      case REMOTE_KEY_LEFT:
        if (!state.isMoving) {
          Serial.println("ACCELERATING LEFT");
          state.isMoving = true;
          state.isAccelerating = true;
          state.timeOfAccelerationStart = millis();
          myservo.attach(SERVO_PIN);
          myservo.write(SERVO_ACCELERATING_LEFT_POSITION);
        }
        if (state.isAccelerating) {
          unsigned long differenceSinceAccelerationStart = millis() - state.timeOfAccelerationStart;
          if (differenceSinceAccelerationStart > SERVO_ACCELERATION_DURATION) {
            Serial.println("MOVING LEFT");
            state.isAccelerating = false;
            myservo.write(SERVO_MOVING_LEFT_POSITION);
          }
        }
        break;
      case REMOTE_KEY_RIGHT:
        if (!state.isMoving) {
          Serial.println("ACCELERATING RIGHT");
          state.isMoving = true;
          state.isAccelerating = true;
          state.timeOfAccelerationStart = millis();
          myservo.attach(SERVO_PIN);
          myservo.write(SERVO_ACCELERATING_RIGHT_POSITION);
        }
        if (state.isAccelerating) {
          unsigned long differenceSinceAccelerationStart = millis() - state.timeOfAccelerationStart;
          if (differenceSinceAccelerationStart > SERVO_ACCELERATION_DURATION) {
            Serial.println("MOVING RIGHT");
            state.isAccelerating = false;
            myservo.write(SERVO_MOVING_RIGHT_POSITION);
          }
        }
        break;
    }

    state.timeOfLastCommand = millis();
    irrecv.resume();
  } else {
    if (state.isMoving && state.differenceSinceLastCommand > COMMAND_IDLE_THRESHOLD) {
      Serial.println("STOP");
      myservo.write(SERVO_STOP_POSITION);
      myservo.detach();
      state.isMoving = false;
    }
  }
}
