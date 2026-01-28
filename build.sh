#!/bin/bash

# Build OSCAR app using DerivedData and copy to bin folder

echo "Building OSCAR..."
xcodebuild -project OSCAR.xcodeproj -scheme OSCAR -configuration Debug build

if [ $? -eq 0 ]; then
    echo "Build succeeded. Copying app to bin folder..."
    mkdir -p bin
    rm -rf bin/O.S.C.A.R..app
    cp -R ~/Library/Developer/Xcode/DerivedData/OSCAR-*/Build/Products/Debug/O.S.C.A.R..app bin/

    echo "Done! App is at: bin/O.S.C.A.R..app"
    echo "Run with: open bin/O.S.C.A.R..app"
else
    echo "Build failed."
    exit 1
fi
