import argparse
import signal
import sys
import time
import os
from functools import partial

from mqtt.client import MQTTClient
from servo import ServoController
from recognizer import Recognizer

LAZYTV_MQTT_HOST = os.environ["LAZYTV_MQTT_HOST"]
LAZYTV_MQTT_PORT = 1883


def main(width: int, height: int, vertical_flip: bool, headless: bool, verbose: bool):
    servo_controller = ServoController()
    servo_controller.toOffPosition()
    recognizer = Recognizer(
        width=width,
        height=height,
        vertical_flip=vertical_flip,
        headless=headless,
        verbose=verbose,
    )

    mqtt_client = MQTTClient(LAZYTV_MQTT_HOST, LAZYTV_MQTT_PORT)
    mqtt_client.connect()

    mqtt_client.subscribe(
        "lazytv/camera/servo/value/set", partial(on_servo_value_set, servo_controller)
    )
    mqtt_client.subscribe(
        "lazytv/tv/state", partial(on_tv_state, servo_controller, recognizer)
    )

    while True:
        time.sleep(1)


def on_servo_value_set(servo_controller: ServoController, msg):
    print(f"set value received {float(msg.payload)}")
    servo_controller.toPosition(float(msg.payload))


def on_tv_state(servo_controller: ServoController, recognizer: Recognizer, msg):
    state = msg.payload.decode("ascii")
    print(f"state={state}")
    if state == "on":
        servo_controller.toOnPosition()
        recognizer.start()
        print(f"state is on")
    else:
        servo_controller.toOffPosition()
        recognizer.stop()
        print(f"state is off")


def signal_handler(signum, frame):
    print("\nShutdown requested...")
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)  # Handles Ctrl+C
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "--frameWidth",
        help="Width of frame to capture from camera.",
        required=False,
        default=640,
    )
    parser.add_argument(
        "--frameHeight",
        help="Height of frame to capture from camera.",
        required=False,
        default=480,
    )
    parser.add_argument(
        "--verticalFlip",
        help="Enables a vertical flip of the image before processing.",
        required=False,
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "--headless",
        help="Enables headless mode",
        required=False,
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "--verbose",
        help="Enables extra logging for debugging",
        required=False,
        default=False,
        action="store_true",
    )
    args = parser.parse_args()
    main(
        args.frameWidth,
        args.frameHeight,
        args.verticalFlip,
        args.headless,
        args.verbose,
    )
