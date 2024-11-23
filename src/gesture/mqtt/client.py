from typing import Callable, Dict, List
import paho.mqtt.client as mqtt


class MQTTClient:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        # Dictionary to store topic -> list of subscriber functions
        self.subscribers: Dict[str, List[Callable]] = {}

    def connect(self):
        self.client = mqtt.Client()
        self.client.connect(self.host, self.port, 60)
        self.client.on_connect = self.on_connect
        self.client.loop_start()

    def on_connect(self, client: mqtt.Client, userdata, flags, rc):
        print(f"Connected with result code {rc}")
        self.client.on_message = self.on_message

    def on_message(self, client, userdata, msg):
        print(f"Received message topic={msg.topic} payload={str(msg.payload)}")
        if msg.topic in self.subscribers:
            for callback in self.subscribers[msg.topic]:
                callback(msg)

    def subscribe(self, topic: str, callback: Callable) -> None:
        if topic not in self.subscribers:
            self.subscribers[topic] = []
        self.subscribers[topic].append(callback)
        self.client.subscribe((topic, 1))
