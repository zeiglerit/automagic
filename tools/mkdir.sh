#!/usr/bin/bash


while read p; do mkdir -p "$(dirname "$p")"; touch "$p"; done < data/files.txt
