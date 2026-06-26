#!/bin/bash
# Simple mock that just touches the output file
# The output file is usually the last argument
OUT_FILE="${@: -1}"
echo "MOCK FFMPEG: encoding frames to $OUT_FILE"
touch "$OUT_FILE"
