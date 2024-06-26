import subprocess
import time

# Send Ctrl+C keystroke
keyboard.send_keys("<ctrl>+c")

# Wait for the clipboard to be updated
time.sleep(0.01)

# Run your program
subprocess.run(["~/.local/bin/read-selected-text"])