from multiprocessing import Process, Event
import time
import sys

import cv2
import mediapipe as mp

from mediapipe.tasks import python
from mediapipe.tasks.python import vision

from state_controller import StateController

from camera.opencv import OpenCVCamera
from camera.picamera import PiCamera

from status_logger.frame_logger import FrameStatusLogger
from status_logger.text_logger import TextStatusLogger
from status_logger.composite_logger import CompositeStatusLogger


# Global variables to calculate FPS
COUNTER, FPS = 0, 0
START_TIME = time.time()

FPS_LIMIT_LAST_TIME = time.time_ns() // 1_000_000


class Recognizer:
    def __init__(
        self,
        model: str = "gesture_recognizer.task",
        num_hands: int = 1,
        min_hand_detection_confidence: float = 0.5,
        min_hand_presence_confidence: float = 0.5,
        min_tracking_confidence: float = 0.5,
        camera_id: int = 0,
        width: int = 640,
        height: int = 480,
        vertical_flip: bool = False,
        headless: bool = False,
        verbose: bool = False,
    ):
        self.model = model
        self.num_hands = num_hands
        self.min_hand_detection_confidence = min_hand_detection_confidence
        self.min_hand_presence_confidence = min_hand_presence_confidence
        self.min_tracking_confidence = min_tracking_confidence
        self.camera_id = camera_id
        self.width = width
        self.height = height
        self.vertical_flip = vertical_flip
        self.headless = headless
        self.verbose = verbose

        self.stop_event = Event()
        self.process = None

    def start(self):
        if self.process is None or not self.process.is_alive():
            self.stop_event.clear()
            self.process = Process(target=self._start)
            self.process.start()

    def stop(self):
        self.stop_event.set()
        if self.process:
            self.process.join()

    def _start(self):
        stateController = StateController()

        statusLogger = CompositeStatusLogger()
        if self.verbose:
            statusLogger.add_logger(TextStatusLogger(sys.stdout))
        if not self.headless:
            statusLogger.add_logger(FrameStatusLogger())

        # camera = OpenCVCamera(self.camera_id, width, height)
        camera = PiCamera(self.width, self.height)
        camera.start()

        # Visualization parameters
        fps_avg_frame_count = 10

        recognition_result_list = []

        def save_result(
            result: vision.GestureRecognizerResult,
            unused_output_image: mp.Image,
            timestamp_ms: int,
        ):
            global FPS, COUNTER, START_TIME, FPS_LIMIT_LAST_TIME

            # if (time.time_ns() // 1_000_000 - FPS_LIMIT_LAST_TIME) <= 1:
            #     return
            # FPS_LIMIT_LAST_TIME = time.time_ns() // 1_000_000
            recognition_result_list.clear()

            # Calculate the FPS
            if COUNTER % fps_avg_frame_count == 0:
                FPS = fps_avg_frame_count / (time.time() - START_TIME)
                START_TIME = time.time()

            recognition_result_list.append(result)
            COUNTER += 1

        # Initialize the gesture recognizer model
        base_options = python.BaseOptions(model_asset_path=self.model)
        options = vision.GestureRecognizerOptions(
            base_options=base_options,
            running_mode=vision.RunningMode.LIVE_STREAM,
            num_hands=self.num_hands,
            min_hand_detection_confidence=self.min_hand_detection_confidence,
            min_hand_presence_confidence=self.min_hand_presence_confidence,
            min_tracking_confidence=self.min_tracking_confidence,
            result_callback=save_result,
            canned_gesture_classifier_options=mp.tasks.components.processors.ClassifierOptions(
                category_allowlist=["Pointing_Up"]
            ),
        )
        recognizer = vision.GestureRecognizer.create_from_options(options)

        # Continuously capture images from the camera and run inference
        while camera.is_available() and not self.stop_event.is_set():
            image = camera.read()

            if self.vertical_flip:
                image = cv2.flip(image, -1)

            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image)

            # Run gesture recognizer using the model.
            recognizer.recognize_async(mp_image, time.time_ns() // 1_000_000)

            current_frame = image
            statusLogger.set_current_frame(current_frame)

            statusLogger.write_fps(FPS)

            # Draw the hand landmarks.
            if recognition_result_list:
                stateController.handle_recognition_results(recognition_result_list)
                statusLogger.write_hand_landmarks(
                    recognition_result_list[0].hand_landmarks
                )

            stateController.write_status(statusLogger)

            statusLogger.flush_log()
            if current_frame is not None and not self.headless:
                cv2.imshow("gesture_recognition", current_frame)

            # Stop the program if the ESC key is pressed.
            if cv2.waitKey(1) == 27:
                break

        recognizer.close()
        camera.destroy()
        cv2.destroyAllWindows()
