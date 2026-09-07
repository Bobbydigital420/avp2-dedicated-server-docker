#!/bin/bash
set -e

# 1. Start the invisible X-Server (Screen :1, 1024x768 resolution)
Xvfb :1 -screen 0 1024x768x16 &

# 2. Start the window manager so we can control the AVP2 UI layout engine
export DISPLAY=:1
fluxbox &

# 3. Start the VNC server to capture our invisible display
x11vnc -display :1 -nopw -forever -listen 0.0.0.0 -rfbport 5900 &

# 4. Start the web-proxy so users can configure the server via their browser
websockify --web=/usr/share/novnc/ 8080 0.0.0.0:5900 &

# Wait for the X-Server socket to actually appear in /tmp before letting Wine launch
echo "Waiting for X-Server virtual display to initialize..."
until [ -e /tmp/.X11-unix/X1 ]; do
    sleep 0.1
done
echo "X-Server is ready!"

# 5. Route based on the exact user-defined Unraid variable state
if [ "$GAME_MODE" = "primal_hunt" ]; then
    echo "Configuring environment context for: Aliens versus Predator 2 - Primal Hunt"
    TARGET_DIR="/avp2ph"
    TARGET_EXE="AVP2XServ.exe"
else
    echo "Configuring environment context for: Aliens versus Predator 2 - Base Game"
    TARGET_DIR="/avp2"
    TARGET_EXE="AVP2Serv.exe"
fi

# Confirm execution context target directory exists
cd "$TARGET_DIR"

if [ ! -f "$TARGET_EXE" ]; then
    echo "ERROR: Executable '$TARGET_EXE' was not found inside the mounted directory: $TARGET_DIR"
    echo "Please ensure your AVP2 server binaries are present inside your mapped Unraid storage location."
    exit 1
fi

# 6. Hand execution over to Wine
echo "Starting Dedicated Server with arguments: ${SERVER_ARGS:-None} $@"
exec ${ARCH_EMU_PREFIX} wine "$TARGET_EXE" ${SERVER_ARGS:-} "$@"

