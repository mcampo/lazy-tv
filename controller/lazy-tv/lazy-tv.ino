#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>
//#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <Servo.h>

struct STATE {
  boolean isMoving;
  unsigned long timeOfLastCommand;
  unsigned long differenceSinceLastCommand;
};

ESP8266WebServer server(80);

const char* ssid = "";
const char* password = "";

const byte COMMAND_IDLE_THRESHOLD = 250;

const byte SERVO_PIN = D6;
const byte SERVO_MOVING_LEFT_POSITION = 76;
const byte SERVO_MOVING_RIGHT_POSITION = 104;
const byte SERVO_STOP_POSITION = 90;

Servo myservo;
STATE state = { false, 0, 0 };

const String mainHTML = "<meta name=viewport content='width=device-width,initial-scale=1'><style>body{display:flex;flex-direction:column}h1{text-align:center}div{display:flex}input[type=button]{padding:20px;margin:0 20px;flex-grow:1}</style><script>let moveIntervalId=null;function onMoveStart(t){moveIntervalId&&clearInterval(moveIntervalId),moveIntervalId=setInterval((()=>fetch(`/move?direction=${t}`)),200)}function onMoveStop(){clearInterval(moveIntervalId)}document.addEventListener('DOMContentLoaded',(()=>{const t=void 0!==window.ontouchstart?'touchstart':'mousedown',e=void 0!==window.ontouchstart?'touchend':'mouseup';console.log(t,e),document.getElementById('button-left').addEventListener(t,(()=>onMoveStart('left'))),document.getElementById('button-right').addEventListener(t,(()=>onMoveStart('right'))),document.getElementById('button-left').addEventListener(e,(()=>onMoveStop())),document.getElementById('button-right').addEventListener(e,(()=>onMoveStop()))}))</script><h1>LazyTV</h1><div><input type=button value=Left id=button-left><input type=button value=Right id=button-right></div>";
const String cameraHTML = "<meta name=viewport content='width=device-width,initial-scale=1'><style>body{display:flex;flex-direction:column}h1{text-align:center}div{display:flex;align-items:center;margin-bottom:20px}input[type=button]{padding:20px;margin:0 20px;flex-grow:1}</style><script src=https://unpkg.com/mqtt@5.10.1/dist/mqtt.min.js></script><script>let client,cameraPosition=0;function setTVState(e){client.publish('lazytv/tv/state',e)}function decreaseCameraPosition(){cameraPosition-=.1,cameraPosition<-1&&(cameraPosition=-1),setCameraPosition()}function increseCameraPosition(){cameraPosition+=.1,cameraPosition>1&&(cameraPosition=1),setCameraPosition()}function setCameraPosition(){client.publish('lazytv/camera/servo/value/set',cameraPosition.toFixed(1)),document.getElementById('camera-position').innerHTML=cameraPosition.toFixed(1)}document.addEventListener('DOMContentLoaded',(()=>{document.getElementById('button-on').addEventListener('click',(()=>setTVState('on'))),document.getElementById('button-off').addEventListener('click',(()=>setTVState('off'))),document.getElementById('button-minus').addEventListener('click',(()=>decreaseCameraPosition())),document.getElementById('button-plus').addEventListener('click',(()=>increseCameraPosition())),document.querySelectorAll('input[type=button]').forEach((e=>e.disabled=!0)),client=mqtt.connect('ws://raspberrypi.local:9001',{clientId:'lazytv_camera_control'+Math.random().toString(16).substr(2,8)}),client.on('connect',(()=>{console.log('Connected to MQTT broker'),document.querySelectorAll('input[type=button]').forEach((e=>e.disabled=!1))})),client.on('error',(e=>{console.error('MQTT error:',e)})),client.on('close',(()=>{console.log('Connection to MQTT broker closed'),document.querySelectorAll('input[type=button]').forEach((e=>e.disabled=!0))}))}))</script><h1>LazyTV - Camera</h1><div><input type=button value=On id=button-on><input type=button value=Off id=button-off></div><div><input type=button value=- id=button-minus><span id=camera-position></span><input type=button value=+ id=button-plus></div>";

void setup(){
  Serial.begin(115200);
  OTASetup();

  server.on("/", HTTP_GET, handleServerRoot);
  server.on("/camera", HTTP_GET, handleServerCamera);
  server.on("/move", HTTP_GET, handleServerMove);
  server.begin();
}

void handleServerRoot() {
  server.send(200, "text/html", mainHTML);
}

void handleServerCamera() {
  server.send(200, "text/html", cameraHTML);
}

void handleServerMove() {
  String direction = server.arg("direction");
  if (direction == "left") {
    moveLeft();
  }
  if (direction == "right") {
    moveRight();
  }
  state.timeOfLastCommand = millis();
  server.send(200, "text/plain", direction);
}

void loop(){
  ArduinoOTA.handle();
  server.handleClient();

  state.differenceSinceLastCommand = millis() - state.timeOfLastCommand;
  if (state.isMoving && state.differenceSinceLastCommand > COMMAND_IDLE_THRESHOLD) {
    stop();
  }
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

void OTASetup() {
  Serial.println("Booting");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }

  // Port defaults to 8266
  // ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
  ArduinoOTA.setHostname("lazytv");

  // No authentication by default
  ArduinoOTA.setPassword((const char *)"lala");

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
