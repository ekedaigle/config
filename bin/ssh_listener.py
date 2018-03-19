import socket
import subprocess
import sys
import re

PORT=3128
XPRA_EXPR = re.compile('XPRA ([0-9]+)')
TMUX_EXPR = re.compile('TMUX ([LR])')

if __name__ == '__main__':
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('', PORT))
    s.listen(1)

    while True:
        conn, addr = s.accept()
        conn.settimeout(5)
        msg = conn.recv(4096).decode()
        conn.close()
        
        m = re.match(XPRA_EXPR, msg)
        if m:
            port = m.group(1)
            subprocess.Popen(['xpra', 'attach', 'ssh/{0}/{1}'.format(addr, port)])
            continue

        m = re.match(TMUX_EXPR, msg)
        if m:
            direction = m.group(1)

            if direction == 'L':
                subprocess.Popen(['osascript', '/Users/ekedaigle/bin/iterm_select_left.scpt'])
            else:
                subprocess.Popen(['osascript', '/Users/ekedaigle/bin/iterm_select_right.scpt'])

