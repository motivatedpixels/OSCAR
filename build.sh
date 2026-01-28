#!/bin/bash

# Build OSCAR app using DerivedData and copy to bin folder

echo "Building OSCAR..."
xcodebuild -project OSCAR.xcodeproj -scheme OSCAR -configuration Debug build

if [ $? -eq 0 ]; then
    echo "Build succeeded. Copying app to bin folder..."
    mkdir -p bin
    rm -rf bin/OSCAR.app
    cp -R ~/Library/Developer/Xcode/DerivedData/OSCAR-*/Build/Products/Debug/OSCAR.app bin/

    echo "Done! App is at: bin/OSCAR.app"
    echo "Run with: open bin/OSCAR.app"
else
    echo "Build failed."
    exit 1
fi
