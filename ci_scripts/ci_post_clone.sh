#!/bin/sh
flutter pub get
flutter build ios --config-only
cd ios
pod install