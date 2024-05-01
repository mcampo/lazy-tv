import time
import urllib.request
import os
from concurrent.futures import ThreadPoolExecutor

TIME_BETWEEN_CALLS_MS = 200
LAZYTV_HOST = os.environ["LAZYTV_HOST"]

def get_current_time():
    return time.time_ns() // 1_000_000

class LazyTVClient:
    def __init__(self):
        self.last_call_time = 0
        self.executor = ThreadPoolExecutor(max_workers=3)
    
    def __del__(self):
        self.executor.shutdown(wait=False)

    def move(self, direction):
        time_since_last_call = get_current_time() - self.last_call_time
        if time_since_last_call >= TIME_BETWEEN_CALLS_MS:
            self.executor.submit(do_request, f"/move?direction={direction}")
            self.last_call_time = get_current_time()

def do_request(resource):
    full_url = f"{LAZYTV_HOST}{resource}"
    try:
        urllib.request.urlopen(full_url)
    except Exception as err:
        print(f"Error calling {full_url}", err)
