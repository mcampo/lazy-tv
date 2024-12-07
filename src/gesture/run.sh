#!/bin/env bash
LAZYTV_HOST=http://192.168.0.2
LAZYTV_MQTT_HOST=raspberrypi.local

source env/bin/activate

export LAZYTV_HOST
export LAZYTV_MQTT_HOST
python3 main.py --frameWidth 1024 --frameHeight 768 --headless --verbose
#python3 main.py --frameWidth 1024 --frameHeight 768 --verbose