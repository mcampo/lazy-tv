from gpiozero import Servo
from time import sleep

POSITION_ON = -0.8
POSITION_OFF = 0.9


class ServoController:
    def __init__(self) -> None:
        self.servo = Servo(17, min_pulse_width=0.0008, max_pulse_width=0.0024)

    def toPosition(self, value):
        self.servo.value = value
        sleep(0.5)
        self.servo.value = None

    def toOnPosition(self):
        self.toPosition(POSITION_ON)

    def toOffPosition(self):
        self.toPosition(POSITION_OFF)
