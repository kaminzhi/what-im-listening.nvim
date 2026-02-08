#!/bin/bash

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This plugin only works on macOS"
    exit 1
fi

mkdir -p macos

echo "Building Universal Media Tool..."

swiftc -framework Foundation \
       -framework AppKit \
       -o macos/UniversalMediaTool \
       macos/UniversalMediaTool.swift

if [ $? -eq 0 ]; then
    echo "Universal Media Tool built successfully."
    chmod +x macos/UniversalMediaTool
    echo "Environment check passed."
else
    echo "Failed to build Universal Media Tool."
    exit 1
fi