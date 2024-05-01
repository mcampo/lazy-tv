
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
journalctl -u lazytv-gesture
```


