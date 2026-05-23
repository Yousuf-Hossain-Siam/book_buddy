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
flutter run --flavor dev -t lib/main_dev.dart
```

4. Build release artifacts (example, production flavor):

```bash
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build ios --flavor prod -t lib/main_prod.dart
```

If your project uses additional platform configuration for flavors, make sure to open the platform projects and verify the flavor targets in Android Studio / Xcode.

## Flavor setup (how this project is organized)

This repository uses a flavor-based approach to produce different app variants and the project includes a minimal implementation for `dev`, `staging`, and `prod`.

- Separate Dart entrypoints per flavor are included: `lib/main_dev.dart`, `lib/main_prod.dart` (the default `lib/main.dart` remains for a single-entrypoint run). Each entrypoint should initialize environment-specific configuration and then call the common `runApp()`.
- Use Flutter's `--flavor` flag for platform-specific configuration and the `-t` flag to point to the flavor entrypoint:

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

- Pass environment-specific values with `--dart-define` when needed:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev
```

- Platform specifics (Android/iOS):
	- Android flavor definitions are implemented in `android/app/build.gradle.kts` (see the `productFlavors` block). The flavors add `applicationIdSuffix` and `versionNameSuffix` for non-prod builds.
	- iOS flavor schemes/targets are not changed by this commit; if you need iOS scheme/target setup I can add Xcode guidance and a suggested changes list.

This setup keeps flavor differences explicit (entrypoints and platform config) while sharing most application code.

Implemented base URLs per flavor (example):

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

- Flavor entrypoints `lib/main_dev.dart` and `lib/main_prod.dart` have been added. If you want, I can add a `lib/main_staging.dart` entrypoint, wire production/dev-specific configs into the app (for example a `Config` provider), and add iOS scheme guidance.

---

For general Flutter help and resources see https://docs.flutter.dev/
