# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

App overview
- Stack: Flutter (Dart 3.8) mobile app using Provider for state management.
- Purpose: Quranic companion app (auth, profile, groups, Khitma and Dhikr flows) consuming the Laravel API in the parent directory.
- Networking: Centralized in lib/services/api_client.dart. Tokens are stored in shared_preferences and sent as Authorization: Bearer on protected endpoints.
- i18n and theming: Custom localizations (English/Arabic) via LanguageProvider and AppLocalizations; dynamic Google Fonts (Manrope for EN, Amiri for AR). ThemeProvider persists theme and language in shared_preferences.

Common commands
Setup
```bash path=null start=null
flutter pub get
flutter doctor
```

Run (set API base)
- The API base URL is compiled via Dart define and defaults to http://192.168.1.3:8000/api (see ApiClient.baseUrl).
- Override it per run or build with API_BASE:
```bash path=null start=null
# Android emulator/device
flutter run --dart-define=API_BASE=http://127.0.0.1:8000/api

# iOS simulator/device (on macOS)
flutter run -d ios --dart-define=API_BASE=http://127.0.0.1:8000/api

# Web (if enabled)
flutter run -d chrome --dart-define=API_BASE=http://127.0.0.1:8000/api
```

Build artifacts
```bash path=null start=null
# Android APK (release)
flutter build apk --release --dart-define=API_BASE=https://api.example.com/api

# Android App Bundle
flutter build appbundle --release --dart-define=API_BASE=https://api.example.com/api

# iOS (on macOS)
flutter build ios --release --dart-define=API_BASE=https://api.example.com/api
```

Testing
```bash path=null start=null
# All tests
flutter test

# Single test file
flutter test test/example_test.dart

# Filter by test name substring
flutter test --plain-name "login"
```

Linting and formatting
```bash path=null start=null
# Static analysis (rules in analysis_options.yaml)
dart analyze .

# Format (dry-run / check only)
dart format . --set-exit-if-changed
# Apply formatting
dart format .
```

Project architecture (big picture)
- Entry and DI: lib/main.dart wires a MultiProvider with:
  - ThemeProvider: dark/light theme, persistent; also persists currentLanguage for initial locale.
  - LanguageProvider: toggles and exposes Locale plus TextDirection.
  - ProfileProvider: user profile snapshot hydrated from /auth/me at startup.
  - DhikrProvider: in-memory model for a currently selected dhikr with progress.
- Splash gating: lib/splash_screen.dart checks a saved auth token; verifies it by calling /auth/me and then routes to Home or Login. This ensures stale/invalid tokens are purged.
- Networking: lib/services/api_client.dart wraps http with:
  - baseUrl from String.fromEnvironment('API_BASE'), defaulting to http://192.168.1.3:8000/api.
  - SharedPreferences for token persistence (saveToken/clearToken).
  - JSON request/response helpers; common error extraction for {message} and {errors} from the Laravel backend.
  - Auth: register, login, me, logout, delete-account checks.
  - Profile: update (multipart form with optional avatar), delete avatar.
  - Groups: CRUD-ish for groups and membership (create, list, show, invites, join/leave/remove member).
  - Khitma: auto-assign, manual-assign, list assignments, update assignment.
- Navigation and screens (selected):
  - Login/Signup: calls ApiClient then saves token and navigates to Home.
  - Home/Dhikr/Khitma/Groups/Profile flows via bottom navigation; profile includes logout and account deletion with confirmation dialogs and password verification.
- Localization and fonts:
  - AppLocalizations and lib/l10n provide AR/EN strings; LanguageProvider switches locale and text direction; GoogleFonts.amiri/manrope are applied per locale in MaterialApp theme.
- Assets: declared in pubspec.yaml (assets/background_elements/*, assets/splash/*, assets/surah_data.json). Ensure these directories/files exist when building.

Platform notes
- Android: AndroidManifest enables cleartext HTTP (android:usesCleartextTraffic="true") to support local non-HTTPS dev endpoints. For production, prefer HTTPS and consider turning this off.
- iOS: If using non-HTTPS endpoints in development, add NSAppTransportSecurity exceptions in ios/Runner/Info.plist.
- Image Picker: image_picker is declared; on Android 13+ you may need READ_MEDIA_IMAGES permissions, the plugin typically injects them, but verify manifests and Info.plist if you ship avatar uploads.

Backend coordination
- Protected calls require Authorization: Bearer <token>. Tokens are issued by POST /api/auth/login and stored in shared_preferences.
- The client targets the Laravel API defined one level up (routes/api.php). Adjust API_BASE to the reachable host for your device/emulator (e.g., use your machine IP when running on a real device on the same LAN).

Troubleshooting tips specific to this repo
- If you get network failures on Android emulator with 127.0.0.1, remember emulator-loopback rules:
  - Android emulator to host: http://10.0.2.2:8000
  - For a real device: use your host machine's LAN IP.
- If fonts don’t update for Arabic/English, ensure Google Fonts package is fetched and LanguageProvider.currentLocale is toggled; ThemeProvider persists currentLanguage which seeds the LanguageProvider on boot.
- If avatars don’t render after upload, ensure you ran php artisan storage:link in the backend and your API_BASE points to that backend.

