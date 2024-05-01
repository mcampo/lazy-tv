import time

from lazytv_client import LazyTVClient

GESTURE_RECOGNITION_SETTLE_TIME = 250
lazytv_client = LazyTVClient()

def is_gesture_recognized(recognition_result_list):
    return recognition_result_list and \
            recognition_result_list[0].gestures and \
            recognition_result_list[0].gestures[0][0].category_name == "Pointing_Up" and \
            recognition_result_list[0].gestures[0][0].score >= 0.15

class BaseState:
    def handle_recognition_results(self, recognition_result_list):
        return self
        
    def write_status(self, statusLogger):
        statusLogger.write_no_gesture(self)

class NoGestureState(BaseState):
    def handle_recognition_results(self, recognition_result_list):
        if is_gesture_recognized(recognition_result_list):
            detection_time = time.time_ns() // 1_000_000
            return EarlyGestureRecognitionState(detection_time)
        return self
    
class EarlyGestureRecognitionState(BaseState):
    def __init__(self, detection_time):
        self.detection_time = detection_time

    def handle_recognition_results(self, recognition_result_list):
        if not is_gesture_recognized(recognition_result_list):
            return NoGestureState()

        current_time = time.time_ns() // 1_000_000
        has_gesture_settled = current_time - self.detection_time > GESTURE_RECOGNITION_SETTLE_TIME
        #print(current_time - self.detection_time)
        if has_gesture_settled:
            initial_position = recognition_result_list[0].hand_landmarks[0][8]
            moving_delta = abs(initial_position.x - recognition_result_list[0].hand_landmarks[0][17].x)
            return GestureRecognizedState(initial_position, moving_delta)
        return self

class GestureRecognizedState(BaseState):
    def __init__(self, initial_position, moving_delta) -> None:
        self.initial_position = initial_position
        self.moving_delta = moving_delta
        self.relative_position = "Center"
        self.recognition_score = None
        self.is_gesture_recognized = False

    def handle_recognition_results(self, recognition_result_list):
        self.is_gesture_recognized = is_gesture_recognized(recognition_result_list)
        if not self.is_gesture_recognized:
            return NoGestureState()

        self.recognition_score = recognition_result_list[0].gestures[0][0].score        
        current_position = recognition_result_list[0].hand_landmarks[0][8]
        position_delta = self.initial_position.x - current_position.x
        #print(position_delta)
        if abs(position_delta) >= self.moving_delta:
            return MovingState(self.initial_position, self.moving_delta)

        return self
    
    def write_status(self, statusLogger):
        if self.is_gesture_recognized:
            statusLogger.write_gesture_recognized(self, self.recognition_score, self.relative_position, self.initial_position, self.moving_delta)

class MovingState(GestureRecognizedState):
    def __init__(self, initial_position, moving_delta) -> None:
        super().__init__(initial_position, moving_delta)
        self.relative_position = None

    def handle_recognition_results(self, recognition_result_list):
        self.is_gesture_recognized = is_gesture_recognized(recognition_result_list)
        if not self.is_gesture_recognized:
            return NoGestureState()
        
        self.recognition_score = recognition_result_list[0].gestures[0][0].score
        current_position = recognition_result_list[0].hand_landmarks[0][8]
        position_delta = self.initial_position.x - current_position.x
        #print(position_delta)
        if abs(position_delta) < self.moving_delta:
            return GestureRecognizedState(self.initial_position, self.moving_delta)
        
        if position_delta < 0:
            #print("moving left")
            self.relative_position = "Left"
            lazytv_client.move("left")
        else:
            #print("moving right")
            self.relative_position = "Right"
            lazytv_client.move("right")

        return self

class StateController:
    def __init__(self) -> None:
        self.currentState = NoGestureState()

    def handle_recognition_results(self, recognition_result_list):
        next_state = self.currentState.handle_recognition_results(recognition_result_list)
        #print(self.currentState.__class__.__name__)
        self.currentState = next_state

    def write_status(self, statusLogger):
        self.currentState.write_status(statusLogger)
