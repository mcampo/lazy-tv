# Copyright 2023 The MediaPipe Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Main scripts to run gesture recognition."""

import argparse
import time
import sys

import cv2
import mediapipe as mp

from mediapipe.tasks import python
from mediapipe.tasks.python import vision

from state_controller import StateController

from camera.opencv import OpenCVCamera
from status_logger.frame_logger import FrameStatusLogger
from status_logger.text_logger import TextStatusLogger
from status_logger.composite_logger import CompositeStatusLogger

# from camera.picamera import PiCamera

# Global variables to calculate FPS
COUNTER, FPS = 0, 0
START_TIME = time.time()

FPS_LIMIT_LAST_TIME = time.time_ns() // 1_000_000


def run(
    model: str,
    num_hands: int,
    min_hand_detection_confidence: float,
    min_hand_presence_confidence: float,
    min_tracking_confidence: float,
    camera_id: int,
    width: int,
    height: int,
    vertical_flip: bool,
    headless: bool,
    verbose: bool,
) -> None:
    """Continuously run inference on images acquired from the camera.

    Args:
        model: Name of the gesture recognition model bundle.
        num_hands: Max number of hands can be detected by the recognizer.
        min_hand_detection_confidence: The minimum confidence score for hand
          detection to be considered successful.
        min_hand_presence_confidence: The minimum confidence score of hand
          presence score in the hand landmark detection.
        min_tracking_confidence: The minimum confidence score for the hand
          tracking to be considered successful.
        camera_id: The camera id to be passed to OpenCV.
        width: The width of the frame captured from the camera.
        height: The height of the frame captured from the camera.
    """

    stateController = StateController()

    statusLogger = CompositeStatusLogger()
    if verbose:
        statusLogger.add_logger(TextStatusLogger(sys.stdout))
    if not headless:
        statusLogger.add_logger(FrameStatusLogger())

    camera = OpenCVCamera(camera_id, width, height)
    camera.start()

    # Visualization parameters
    fps_avg_frame_count = 1

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
    base_options = python.BaseOptions(model_asset_path=model)
    options = vision.GestureRecognizerOptions(
        base_options=base_options,
        running_mode=vision.RunningMode.LIVE_STREAM,
        num_hands=num_hands,
        min_hand_detection_confidence=min_hand_detection_confidence,
        min_hand_presence_confidence=min_hand_presence_confidence,
        min_tracking_confidence=min_tracking_confidence,
        result_callback=save_result,
        canned_gesture_classifier_options=mp.tasks.components.processors.ClassifierOptions(
            category_allowlist=["Pointing_Up"]
        ),
    )
    recognizer = vision.GestureRecognizer.create_from_options(options)

    # Continuously capture images from the camera and run inference
    while camera.is_available():
        image = camera.read()

        if vertical_flip:
            image = cv2.flip(image, -1)

        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_image)

        # Run gesture recognizer using the model.
        recognizer.recognize_async(mp_image, time.time_ns() // 1_000_000)

        current_frame = image
        statusLogger.set_current_frame(current_frame)

        statusLogger.write_fps(FPS)

        # Draw the hand landmarks.
        if recognition_result_list:
            stateController.handle_recognition_results(recognition_result_list)
            statusLogger.write_hand_landmarks(recognition_result_list[0].hand_landmarks)

        stateController.write_status(statusLogger)

        statusLogger.flush_log()
        if current_frame is not None and not headless:
            cv2.imshow("gesture_recognition", current_frame)

        # Stop the program if the ESC key is pressed.
        if cv2.waitKey(1) == 27:
            break

    recognizer.close()
    camera.destroy()
    cv2.destroyAllWindows()


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "--model",
        help="Name of gesture recognition model.",
        required=False,
        default="gesture_recognizer.task",
    )
    parser.add_argument(
        "--numHands",
        help="Max number of hands that can be detected by the recognizer.",
        required=False,
        default=1,
    )
    parser.add_argument(
        "--minHandDetectionConfidence",
        help="The minimum confidence score for hand detection to be considered "
        "successful.",
        required=False,
        default=0.5,
    )
    parser.add_argument(
        "--minHandPresenceConfidence",
        help="The minimum confidence score of hand presence score in the hand "
        "landmark detection.",
        required=False,
        default=0.5,
    )
    parser.add_argument(
        "--minTrackingConfidence",
        help="The minimum confidence score for the hand tracking to be "
        "considered successful.",
        required=False,
        default=0.5,
    )
    # Finding the camera ID can be very reliant on platform-dependent methods.
    # One common approach is to use the fact that camera IDs are usually indexed sequentially by the OS, starting from 0.
    # Here, we use OpenCV and create a VideoCapture object for each potential ID with 'cap = cv2.VideoCapture(i)'.
    # If 'cap' is None or not 'cap.isOpened()', it indicates the camera ID is not available.
    parser.add_argument("--cameraId", help="Id of camera.", required=False, default=0)
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

    run(
        args.model,
        int(args.numHands),
        args.minHandDetectionConfidence,
        args.minHandPresenceConfidence,
        args.minTrackingConfidence,
        int(args.cameraId),
        args.frameWidth,
        args.frameHeight,
        args.verticalFlip,
        args.headless,
        args.verbose,
    )


if __name__ == "__main__":
    main()
