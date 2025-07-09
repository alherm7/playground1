# Workout Timer

This repository contains a very small Flutter starter project for a workout timer app.
The app provides a basic example of how to implement an interval timer in Flutter.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) SDK installed on your machine.
  After installation, run `flutter doctor` to ensure your environment is ready.

## Getting Started

1. Clone this repository.
2. Run `flutter create .` from the project directory to generate platform-specific
   files for Android and iOS. This command will not overwrite existing files
   such as `lib/main.dart`.
3. Fetch dependencies:

   ```bash
   flutter pub get
   ```
4. Run the app on a device or simulator:

   ```bash
   flutter run
   ```

The provided code in `lib/main.dart` implements a simple timer that switches
between "WORK" and "REST" states every 30 seconds. You can customize the
interval logic to suit your workouts.

## Notes

This project is intended as a starting point for learning Flutter. Feel free to
extend it with features such as configurable intervals, sounds, or saving
workout presets.
