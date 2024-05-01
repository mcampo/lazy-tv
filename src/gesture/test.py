import subprocess
import os
import signal
import time

def start_program(program_path):
    try:
        # Start the program as a subprocess
        process = subprocess.Popen(['bash', program_path])
        return process
    except Exception as e:
        print("Error starting program:", e)
        return None

def stop_program(process):
    try:
        # Send SIGTERM signal to gracefully stop the process
        process.terminate()
        subprocess.run(['pkill', '-f', "recognize.py"])
    except Exception as e:
        print("Error stopping program:", e)

if __name__ == "__main__":
    # Example paths to programs
    program_path = "run.sh"

    # Start the program
    running_process = start_program(program_path)

    # Wait for a while (simulate program running)
    time.sleep(15)

    # Stop the program
    stop_program(running_process)