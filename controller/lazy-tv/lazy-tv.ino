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

const unsigned long REMOTE_KEY_REWIND = 0xB68AB4C8; // DB31820E 
const unsigned long REMOTE_KEY_FORWARD = 0xC28EC9F8; // 3DC53C42


const byte COMMAND_IDLE_THRESHOLD = 120;

const byte SERVO_PIN = 9;
const byte SERVO_ACCELERATING_LEFT_POSITION = 105;
const byte SERVO_MOVING_LEFT_POSITION = 120;//103;//112;
const byte SERVO_ACCELERATING_RIGHT_POSITION = 81;
const byte SERVO_MOVING_RIGHT_POSITION = 60;//85;//74;
const byte SERVO_STOP_POSITION = 90;
const int SERVO_ACCELERATION_DURATION = 200;

const byte MOTOR_PIN_ENABLE = 9;
const byte MOTOR_PIN_1 = 10;
const byte MOTOR_PIN_2 = 11;

const byte MOTOR_MAX_SPEED = 50; // 115 = ~6V


IRrecv irrecv(RECV_PIN);
decode_results results;
//Servo myservo;
STATE state = { false, false, 0, 0, 0 };

void setup(){
  pinMode(MOTOR_PIN_ENABLE, OUTPUT);
  pinMode(MOTOR_PIN_1, OUTPUT);
  pinMode(MOTOR_PIN_2, OUTPUT);
  
  Serial.begin(9600);
  irrecv.enableIRIn();
  irrecv.blink13(true);
//  myservo.attach(SERVO_PIN);
}

void loop(){
  delay(2000);
  moveLeft();
  delay(4000);
  stopMoving();
  delay(2000);
  moveRight();
  delay(4000);
  stopMoving();

//  state.differenceSinceLastCommand = millis() - state.timeOfLastCommand;
//
//  if (irrecv.decode(&results)) {
//    Serial.println(results.value, HEX);
//    switch(results.value) {
//      case REMOTE_KEY_LEFT:
//        if (!state.isMoving) {
//          Serial.println("MOVING LEFT");
//          moveLeft();
//          state.isMoving = true;
//        }
//        break;
//      case REMOTE_KEY_RIGHT:
//        if (!state.isMoving) {
//          Serial.println("MOVING RIGHT");
//          moveRight();
//          state.isMoving = true;
//        }
//        break;
//    }
//
//    state.timeOfLastCommand = millis();
//    irrecv.resume();
//  } else {
//    if (state.isMoving && state.differenceSinceLastCommand > COMMAND_IDLE_THRESHOLD) {
//      Serial.println("STOP");
//      stopMoving();
//      state.isMoving = false;
//    }
//  }
}

void moveLeft() {
  digitalWrite(MOTOR_PIN_1, HIGH);
  digitalWrite(MOTOR_PIN_2, LOW);
  analogWrite(MOTOR_PIN_ENABLE, MOTOR_MAX_SPEED);
}

void moveRight() {
  digitalWrite(MOTOR_PIN_1, LOW);
  digitalWrite(MOTOR_PIN_2, HIGH);
  analogWrite(MOTOR_PIN_ENABLE, MOTOR_MAX_SPEED);
}

void stopMoving() {
  digitalWrite(MOTOR_PIN_1, LOW);
  digitalWrite(MOTOR_PIN_2, LOW);
  analogWrite(MOTOR_PIN_ENABLE, 0);
}
