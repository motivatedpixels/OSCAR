#!/bin/bash
# Build OSCAR app and copy to bin folder

echo "Building OSCAR app..."
xcodebuild -project OSCAR.xcodeproj -scheme OSCAR -configuration Debug build

if [ $? -eq 0 ]; then
    echo "Build succeeded!"
    echo "Copying app to bin folder..."
    mkdir -p bin
    rm -rf bin/O.S.C.A.R..app
    cp -R "/Users/rhodesm/Library/Developer/Xcode/DerivedData/OSCAR-ecdyctqnrbqwxhdbumllsbhdysvl/Build/Products/Debug/O.S.C.A.R..app" bin/
    echo "App copied to bin/O.S.C.A.R..app"
    echo "Done!"
else
    echo "Build failed!"
    exit 1
fi
