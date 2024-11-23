

# Setup

## Install and configure mosquitto broker

SSH into the raspberry and install mosquitto packages:

```
sudo apt install -y mosquitto mosquitto-clients
sudo bash -c 'echo -e "listener 1883\nallow_anonymous true\n\nlistener 9001\nprotocol websockets\nallow_anonymous true\n" > /etc/mosquitto/conf.d/lazytv.conf'
sudo systemctl restart mosquitto.service
```

## Install Gesture code 

To copy code to the raspberry:
```
./copy-files.sh
```

SSH into the raspberry and prepare the environment

```
mkdir ~/gesture
cd ~/gesture
python3 -m venv --system-site-packages env
source env/bin/activate
python3 -m pip install pip --upgrade
python3 -m pip install -r requirements.txt
```

```
cd ~/gesture
sudo cp ./lazytv-gesture.service /etc/systemd/system/lazytv-gesture.service
sudo systemctl enable lazytv-gesture
sudo systemctl start lazytv-gesture
```

See logs
```
journalctl -r -u lazytv-gesture
```


