#/bin/env bash
PI_USER=mcampo
PI_HOST=raspberrypi.local
GESTURE_HOME=/home/$PI_USER/gesture

rsync -avz --exclude="env" --exclude="**/__pycache__" ./ $PI_USER@$PI_HOST:$GESTURE_HOME
