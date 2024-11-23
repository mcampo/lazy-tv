import cv2

class OpenCVCamera:
    def __init__(self, camera_id, frame_width, frame_height):
        self.camera_id = camera_id
        self.frame_width = frame_width
        self.frame_height = frame_height
    
    def start(self):
        self.cap = cv2.VideoCapture(self.camera_id)
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, float(self.frame_width))
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, float(self.frame_height))
    
    def is_available(self):
        return self.cap.isOpened()
    
    def read(self):
        success, image = self.cap.read()
        if not success:
            raise Exception("Unable to read from camera")
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        return image
    
    def destroy(self):
        self.cap.release()
