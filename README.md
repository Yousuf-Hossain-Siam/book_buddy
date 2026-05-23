# book_buddy_

A Flutter app for managing and discovering books.

## Setup

Prerequisites:

- Install Flutter (recommended channel stable). See https://docs.flutter.dev/get-started/install
- Android SDK (Android Studio) for Android builds
- Xcode for iOS builds on macOS

Getting started locally:

1. Clone the repo:

```bash
git clone <repo-url>
cd book_buddy_
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run on an emulator or device (example, development flavor):

```bash
flutter run
```

4. Build release artifacts:

```bash
flutter build apk
flutter build ios
```

If your project uses additional platform configuration for URL selection, keep that in Dart rather than in Android product flavors.

## URL configuration (how this project is organized)

This repository uses a single Android build that produces one APK. URL differences are handled in Dart instead of Android product flavors.

- The default Android entrypoint is `lib/main.dart` and it produces the single APK.
- If you need environment-specific API URLs, keep them in Dart entrypoints or `--dart-define` values rather than in Android build flavors.

```bash
flutter run -t lib/main_dev.dart
```

- Pass environment-specific values with `--dart-define` when needed:

```bash
flutter run -t lib/main_dev.dart --dart-define=ENV=dev
```

- Platform specifics (Android/iOS):
	- Android is no longer split into product flavors, so `flutter build apk` now yields one APK.
	- iOS flavor schemes/targets are not changed by this commit; if you need iOS scheme/target setup I can add Xcode guidance and a suggested changes list.

This setup keeps URL differences explicit in Dart while sharing one Android application package.

Implemented base URLs per environment example:

- `dev` (entrypoint `lib/main_dev.dart`) uses `https://api.dev.bookbuddy.example`
- `prod` (entrypoint `lib/main_prod.dart`) uses `https://api.bookbuddy.example`

The app exposes these via a `Config` provider (`lib/src/core/config.dart`) — the entrypoints override `configProvider` with the flavor-specific `Config` instance. Access the base URL in code with:

```dart
final config = ref.watch(configProvider);
final base = config.baseUrl;
```

## State management approach

This project uses Riverpod (`flutter_riverpod`) for state management (see `pubspec.yaml`). Key reasons and patterns:

- Why Riverpod:
	- Provider scoping and testability without relying on `BuildContext`.
	- First-class support for synchronous and asynchronous state (`AsyncValue`).
	- Simple-to-use providers that compose well across features.

- Recommended patterns used in this repo:
	- Keep providers colocated with their feature code (for example, a `providers` file inside a feature folder).
	- Use `StateNotifier`/`StateNotifierProvider` (or `AsyncNotifier`/`AsyncNotifierProvider`) for stateful logic and immutable state objects.
	- Use `Provider` for lightweight, derived, or configuration values.

Examples:

- Create a provider:

```dart
final booksRepositoryProvider = Provider((ref) => BooksRepository());

final booksNotifierProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
	final repo = ref.watch(booksRepositoryProvider);
	return BooksNotifier(repo);
});
```

- In widgets, read/watch providers with `ref.watch(...)` or `ref.read(...)` inside `ConsumerWidget` or using `Consumer`.

## Notes & next steps

- URL entrypoints `lib/main_dev.dart` and `lib/main_prod.dart` have been added. If you want, I can add a `lib/main_staging.dart` entrypoint or switch the URL selection to `--dart-define` so the same entrypoint can target different environments.

---

For general Flutter help and resources see https://docs.flutter.dev/
