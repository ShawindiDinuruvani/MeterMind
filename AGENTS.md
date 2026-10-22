# MeterMind - Flutter Project

## Commands
- `flutter pub get` - Install dependencies
- `flutter analyze` - Run static analysis (lints)
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run single test file
- `flutter run` - Run app in debug mode (hot reload: `r`, hot restart: `R`)
- `flutter build <platform>` - Build release (platforms: apk, ipa, windows, macos, linux, web)

## Project Structure
- `lib/main.dart` - App entry point
- `test/` - Widget tests
- `analysis_options.yaml` - Lint config (extends `flutter_lints`)

## Conventions
- Dart SDK: ^3.13.1
- Lints: `flutter_lints` v6.0.0 (default rules)
- Platform dirs (android/, ios/, etc.) excluded from analysis
- No code generation, migrations, or custom build steps