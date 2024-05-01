import cv2
import mediapipe as mp
from mediapipe.framework.formats import landmark_pb2

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

# Visualization parameters
row_size = 50  # pixels
horizontal_margin = 24  # pixels
text_color = (0, 0, 0)  # black
font_size = 1
font_thickness = 1


class FrameStatusLogger:
    def __init__(self):
        self.current_frame = None

    def set_current_frame(self, current_frame):
        self.current_frame = current_frame

    def write_fps(self, fps):
        if self.current_frame is None:
            return

        fps_text = f"FPS = {fps:.1f}"
        text_location = (horizontal_margin, row_size)
        cv2.putText(
            self.current_frame,
            fps_text,
            text_location,
            cv2.FONT_HERSHEY_DUPLEX,
            font_size,
            text_color,
            font_thickness,
            cv2.LINE_AA,
        )

    def write_no_gesture(self, state):
        if self.current_frame is None:
            return

        status_text = "No Gesture"
        text_location = (horizontal_margin, row_size * 2)
        cv2.putText(
            self.current_frame,
            status_text,
            text_location,
            cv2.FONT_HERSHEY_DUPLEX,
            font_size,
            text_color,
            font_thickness,
            cv2.LINE_AA,
        )

    def write_gesture_recognized(
        self, state, recognition_score, relative_position, initial_position, moving_delta
    ):
        if self.current_frame is None:
            return

        status_text = f"Gesture ({recognition_score:.2f})"
        text_location = (horizontal_margin, row_size * 2)
        cv2.putText(
            self.current_frame,
            status_text,
            text_location,
            cv2.FONT_HERSHEY_DUPLEX,
            font_size,
            text_color,
            font_thickness,
            cv2.LINE_AA,
        )
        cv2.putText(
            self.current_frame,
            relative_position,
            (horizontal_margin, row_size * 3),
            cv2.FONT_HERSHEY_DUPLEX,
            font_size,
            text_color,
            font_thickness,
            cv2.LINE_AA,
        )

        x_pos = round(initial_position.x * self.current_frame.shape[1])
        x_pos_left_threshold = round(
            (initial_position.x + moving_delta) * self.current_frame.shape[1]
        )
        x_pos_right_threshold = round(
            (initial_position.x - moving_delta) * self.current_frame.shape[1]
        )
        for line_x_position in [x_pos, x_pos_right_threshold, x_pos_left_threshold]:
            cv2.line(
                self.current_frame,
                (line_x_position, 0),
                (line_x_position, self.current_frame.shape[0]),
                (0, 255, 0),
                2,
            )

    def write_hand_landmarks(self, hand_landmarks):
        for hand_landmarks in hand_landmarks:
            hand_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            hand_landmarks_proto.landmark.extend(
                [
                    landmark_pb2.NormalizedLandmark(
                        x=landmark.x, y=landmark.y, z=landmark.z
                    )
                    for landmark in hand_landmarks
                ]
            )
            mp_drawing.draw_landmarks(
                self.current_frame,
                hand_landmarks_proto,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing_styles.get_default_hand_landmarks_style(),
                mp_drawing_styles.get_default_hand_connections_style(),
            )
    
    def flush_log(self):
        pass
