#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>
#include <PubSubClient.h>
//#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <Servo.h>

#include "lazy-tv.h"

struct STATE {
  boolean isMoving;
  unsigned long timeOfLastCommand;
};

struct TV_STATE {
  bool isOn;
  unsigned long timeOfLastCheck;
};

ESP8266WebServer server(80);
WiFiClient espClient;
PubSubClient mqttClient(espClient);

unsigned long mqttLastConnectAttempt = 0;
const int MQTT_CONNECTION_ATTEMPT_INTERVAL = 30000;

const char* WIFI_SSID = "...";
const char* WIFI_PASSWORD = "...";
const char* MQTT_SERVER_HOST = "...";
const char* OTA_PASSWORD = "...";

const int COMMAND_IDLE_THRESHOLD = 400;

const byte SERVO_PIN = D6;
const byte SERVO_MOVING_LEFT_POSITION = 76;
const byte SERVO_MOVING_RIGHT_POSITION = 104;
const byte SERVO_STOP_POSITION = 90;

const byte TV_USB_PIN = A0;
const int TV_USB_THRESHOLD = 512;
const int TV_USB_CHECK_INTERVAL = 1000;
TV_STATE tvState = { false, 0 };

Servo myservo;
STATE state = { false, 0 };

void setup(){
  Serial.begin(115200);
  connectToWifi();
  OTASetup();

  mqttClient.setServer(MQTT_SERVER_HOST, 1883);
  mqttClient.setKeepAlive(60);

  server.on("/", HTTP_GET, handleServerRoot);
  server.on("/camera", HTTP_GET, handleServerCamera);
  server.on("/move", HTTP_GET, handleServerMove);
  server.begin();
}

void handleServerRoot() {
  server.send(200, "text/html", MAIN_HTML);
}

void handleServerCamera() {
  server.send(200, "text/html", CAMERA_HTML);
}

void handleServerMove() {
  state.timeOfLastCommand = millis();
  String direction = server.arg("direction");
  if (direction == "left") {
    moveLeft();
  }
  if (direction == "right") {
    moveRight();
  }
  server.send(200, "text/plain", direction);
}

void connectToMQTTServer() {
  // Create a random client ID
  char clientId[25];
  snprintf(clientId, sizeof(clientId), "lazytv_esp8266_%04X", random(0xFFFF));
  Serial.print("Attempting MQTT connection (clientId=");
  Serial.print(clientId);
  Serial.print(")...");
  // Attempt to connect
  if (mqttClient.connect(clientId)) {
    Serial.println(" connected");
  } else {
    Serial.print("failed. Client state=");
    Serial.println(mqttClient.state());
  }
}

void motorLoop() {
  unsigned long currentMillis = millis();

  if (state.isMoving && currentMillis - state.timeOfLastCommand > COMMAND_IDLE_THRESHOLD) {
    stop();
  }
}

void mqttLoop() {
  unsigned long currentMillis = millis();

  if (!mqttClient.connected() && currentMillis - mqttLastConnectAttempt > MQTT_CONNECTION_ATTEMPT_INTERVAL) {
    mqttLastConnectAttempt = currentMillis;
    Serial.print("Not connected inside loop. Client state=");
    Serial.println(mqttClient.state());

    connectToMQTTServer();
  }
  mqttClient.loop();  
}

void tvStateLoop() {
  unsigned long currentMillis = millis();

  if (currentMillis - tvState.timeOfLastCheck > TV_USB_CHECK_INTERVAL) {
    tvState.timeOfLastCheck = currentMillis;
    int tvUSBValue = analogRead(TV_USB_PIN);
    if (!tvState.isOn && tvUSBValue >= TV_USB_THRESHOLD) {
      Serial.println("TV turned on");
      tvState.isOn = true;
      if (mqttClient.connected()) {
          mqttClient.publish("lazytv/tv/state", "on");
      }
    }
    if (tvState.isOn && tvUSBValue < TV_USB_THRESHOLD) {
      Serial.println("TV turned off");
      tvState.isOn = false;
      if (mqttClient.connected()) {
          mqttClient.publish("lazytv/tv/state", "off");
      }
    }
  }
}

void loop(){
  ArduinoOTA.handle();
  server.handleClient();

  motorLoop();
  mqttLoop();
  tvStateLoop();
}

void stop() {
  Serial.println("STOP");
  myservo.write(SERVO_STOP_POSITION);
  myservo.detach();
  state.isMoving = false;
}

void moveLeft() {
  if (!state.isMoving) {
    Serial.println("MOVING LEFT");
    state.isMoving = true;
    myservo.attach(SERVO_PIN);
    myservo.write(SERVO_MOVING_LEFT_POSITION);
  }
}

void moveRight() {
  if (!state.isMoving) {
    Serial.println("MOVING RIGHT");
    state.isMoving = true;
    myservo.attach(SERVO_PIN);
    myservo.write(SERVO_MOVING_RIGHT_POSITION);
  }
}

void connectToWifi() {
  Serial.println("Connecting to Wifi");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }
}

void OTASetup() {
  // Port defaults to 8266
  // ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
  ArduinoOTA.setHostname("lazytv");

  // No authentication by default
  ArduinoOTA.setPassword(OTA_PASSWORD);

  ArduinoOTA.onStart([]() {
    Serial.println("Start");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  ArduinoOTA.begin();
  Serial.println("OTA Ready");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.print("Hostname: ");
  Serial.println(ArduinoOTA.getHostname());
}
