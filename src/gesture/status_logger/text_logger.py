import time


class TextStatusLogger:
    def __init__(self, output_stream):
        self.current_relative_position = None
        self.output_stream = output_stream

    def set_current_frame(self, current_frame):
        self.current_frame = current_frame

    def write_fps(self, fps):
        self.current_fps = fps

    def write_no_gesture(self, state):
        self.current_gesture_text = "No Gesture"
        self.current_state = state
        self.current_relative_position = None

    def write_gesture_recognized(
        self,
        state,
        recognition_score,
        relative_position,
        initial_position,
        moving_delta,
    ):
        self.current_gesture_text = f"Gesture ({recognition_score:.2f})"
        self.current_state = state
        self.current_relative_position = relative_position

    def write_hand_landmarks(self, hand_landmarks):
        pass

    def flush_log(self):
        log_text = f"fps={self.current_fps:.0f}, gesture={self.current_gesture_text}, state={self.current_state.__class__.__name__}, position={self.current_relative_position}"
        self.output_stream.write(log_text + "\n")
        self.output_stream.flush()
