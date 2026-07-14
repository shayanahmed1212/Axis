# Axis — A Flutter To-Do App

A production-grade Flutter to-do list application called **"Axis"** (a task manager built for focus and momentum). Built as a one-week individual internship assessment submission — 100% original, fully functional, demonstrating professional engineering discipline.

Dark mode-first design with a custom "Flow Dark" design system implemented entirely in Dart code (no UI kits, no templates).

## Tech Stack

| Concern | Choice |
|---|---|
| Language | Dart (null-safety, sound typing) |
| Framework | Flutter (stable channel) |
| State management | Riverpod (`flutter_riverpod`) |
| Routing | `go_router` — auth redirect guards |
| Backend | Firebase Auth + Cloud Firestore |
| Models | Immutable data classes with `freezed` |
| UI fonts | Inter via `google_fonts` |

## Features

- Email/password registration, login, logout (Firebase Auth)
- Full task CRUD: create, view, edit, delete, mark complete/incomplete
- Per-user task isolation (tasks stored under `users/{uid}/tasks/`)
- Task filtering: All / Active / Completed
- Priority levels: Low, Medium, High
- Due date picker
- Swipe-to-delete with undo snackbar
- Inline validation on all forms
- Loading, empty, validation, and error states on every screen
- Dark mode design system with custom design tokens
- Profile screen with logout
- Auth-guarded routes (unauthenticated users redirected to login)

## Prerequisites

- Flutter SDK (stable channel, latest version)
- A Firebase project (free Spark plan is sufficient)
- Android Studio or VS Code with Flutter plugins
- An Android device/emulator for testing

## Setup Instructions

### 1. Clone and install dependencies

```bash
git clone <repo-url> flow-app
cd flow-app
flutter pub get
```

### 2. Create a Firebase project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**, name it (e.g., "Flow Todo App")
3. Disable Google Analytics (optional, not required)
4. Once created, click the **Android** icon to add an Android app
5. Register your app with package name (check `android/app/build.gradle` for `applicationId`)
6. Download `google-services.json` and place it in `android/app/`
7. Register an iOS app (optional, requires Xcode/macOS)

### 3. Enable Firebase services

- **Authentication**: Go to Authentication → Sign-in method → Enable **Email/Password**
- **Cloud Firestore**: Go to Firestore Database → Create database → Start in test mode (or use the provided `firestore.rules`)

### 4. Generate Firebase options

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (select your project and platforms)
flutterfire configure --project=your-project-id
```

This generates a `lib/firebase_options.dart` file with your project's configuration. **This file is gitignored** — never commit it to version control.

### 5. Deploy Firestore security rules

```bash
firebase deploy --only firestore:rules
```

Or copy the contents of `firestore.rules` into the Firebase Console → Firestore → Rules tab.

### 6. Run the app

```bash
# Debug mode on connected device/emulator
flutter run

# Or specify a device
flutter devices
flutter run -d <device-id>
```

### 7. Build a release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

### 8. iOS build (requires macOS)

```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase config (gitignored)
├── core/
│   ├── config/app_config.dart     # App-level configuration
│   ├── constants/app_strings.dart # All user-facing strings
│   ├── theme/
│   │   ├── app_colors.dart        # Color design tokens
│   │   ├── app_typography.dart    # Typography tokens
│   │   ├── app_tokens.dart        # Spacing, radius tokens
│   │   └── app_theme.dart         # ThemeData + FlowThemeExtension
│   ├── routing/app_router.dart    # GoRouter with auth guards
│   ├── utils/
│   │   ├── validators.dart        # Form validation
│   │   ├── date_formatter.dart    # Date formatting
│   │   ├── error_mapper.dart      # Firebase → AppException mapping
│   │   └── result.dart            # Result type
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── app_exception_types.dart
│   └── widgets/                   # Reusable UI components
│       ├── primary_button.dart
│       ├── secondary_button.dart
│       ├── app_text_field.dart
│       ├── app_loading_indicator.dart
│       ├── app_empty_state.dart
│       ├── app_error_state.dart
│       ├── app_snackbar.dart
│       └── confirm_dialog.dart
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/app_user.dart
│   │   ├── application/auth_controller.dart
│   │   └── presentation/
│   │       ├── screens/ (splash, login, register, forgot_password)
│   │       └── widgets/ (auth_error_banner, password_field)
│   └── tasks/
│       ├── data/task_repository.dart
│       ├── domain/task.dart, task_priority.dart
│       ├── application/ (task_providers.dart, task_controller.dart)
│       └── presentation/
│           ├── screens/ (dashboard, task_detail, task_form)
│           └── widgets/ (task_card, filter_tabs, chips, etc.)
└── profile/presentation/screens/profile_screen.dart
```

## Security

- Tasks are stored as Firestore subcollections under `users/{uid}/tasks/{taskId}`
- Firestore security rules enforce that users can only read/write their own data
- Client-side queries are scoped per-user using the authenticated UID
- Firebase config (`firebase_options.dart`) is gitignored

## Code Generation

Some files require code generation to compile:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates part files for `freezed` models and `json_serializable`.

## License

This project is created for academic/assessment purposes.
