#!/bin/sh
set -e

flutter pub get
flutter pub run build_runner build
flutter build web --web-renderer canvaskit --source-maps