#!/bin/bash

PROJECT_DIR="."
PIPE_NAME="flutter_pipe"
FLUTTER_CMD="flutter run"

# Cleanup old pipe if exists
if [ -p "$PIPE_NAME" ]; then
  rm "$PIPE_NAME"
fi

mkfifo "$PIPE_NAME"

# Cleanup on exit
cleanup() {
  echo "Cleaning up..."
  kill $FLUTTER_PID 2>/dev/null
  rm -f "$PIPE_NAME"
  exit
}

trap cleanup INT TERM EXIT

# Start Flutter
$FLUTTER_CMD < "$PIPE_NAME" &
FLUTTER_PID=$!

echo "Flutter started with PID $FLUTTER_PID"
echo "Watching Dart files only..."

# Debounce control
LAST_RUN=0

fswatch -o \
  --exclude="build/" \
  --exclude=".dart_tool/" \
  --exclude="ios/" \
  --exclude="android/" \
  --exclude=".git/" \
  --include="\\.dart$" \
  "$PROJECT_DIR" | while read change; do

    NOW=$(date +%s)

    # Debounce: only allow once per 2 seconds
    if (( NOW - LAST_RUN >= 2 )); then
        echo "Change detected. Reloading..."
        echo "r" > "$PIPE_NAME"
        LAST_RUN=$NOW
    fi
done



