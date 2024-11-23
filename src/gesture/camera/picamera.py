import cv2
from picamera2 import Picamera2

class PiCamera:
    def __init__(self, frame_width, frame_height):
        self.frame_width = frame_width
        self.frame_height = frame_height

    def start(self):
        self.picam2 = Picamera2()
        config = self.picam2.create_preview_configuration(main={
            "format": "RGB888",
            "size": (int(self.frame_width), int(self.frame_height)),
            },
            buffer_count=2)
        self.picam2.align_configuration(config)
        self.picam2.configure(config)
        self.picam2.start()
        print(config)
    
    def is_available(self):
        return True
    
    def read(self):
        image = self.picam2.capture_array("main")
        return image
    
    def destroy(self):
        self.picam2.stop()
        self.picam2.stop_encoder()
        self.picam2.close()
