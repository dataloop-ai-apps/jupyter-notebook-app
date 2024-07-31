import shutil
import subprocess
import logging
import select
import stat
import os

"""
https://github.com/coder/code-server
https://hub.docker.com/r/codercom/code-server
https://coder.com/docs/code-server/latest/install#debian-ubuntu

"""

logger = logging.getLogger("[NOTEBOOK]")


class Runner:
    def __init__(self):
        src = os.getcwd()
        dst = '/tmp/app'
        if os.path.exists(dst):
            shutil.rmtree(dst)
        print('copyyyy')
        shutil.copytree(src=src, dst=dst)
        print('change dir')
        os.chdir('/tmp/app')
        os.chmod('/tmp/app/start.sh', 0o0777)
        proc = subprocess.Popen('./start.sh', stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True)
        try:
            while True:
                # Use select to wait for output
                readable, _, _ = select.select([proc.stdout, proc.stderr], [], [], 0.1)
                for f in readable:
                    line = f.readline()
                    if line:
                        print(f"Output: {line.strip()}")
                # Check if the process has terminated
                if proc.poll() is not None:
                    print("Process finished.")
                    break
        except KeyboardInterrupt:
            print("Stopped by user.")
        finally:
            proc.terminate()

    def run(self):
        ...


if __name__ == "__main__":
    runner = Runner()
