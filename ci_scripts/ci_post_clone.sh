#!/bin/sh

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

# Generate Flutter build files
flutter build ios --config-only --release --no-codesign

# Fix Pods deployment targets
cd $CI_PRIMARY_REPOSITORY_PATH/ios
pod install