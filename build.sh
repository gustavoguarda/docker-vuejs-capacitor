#!/usr/bin/env bash

npx cap init
npx cap copy
npx cap add android
npx cap open android
cd android

# This will generate an APK file in the android/app/build/outputs/apk/debug directory.
./gradlew assembleDebug