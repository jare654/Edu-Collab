# Release Checklist + Versioning Workflow

## Versioning (Flutter)
Update `pubspec.yaml`:

```
version: X.Y.Z+NNN
```

- `X.Y.Z` is the user-facing version.
- `NNN` is the build number (Android `versionCode`, iOS `CFBundleVersion`).

## Android (Play Store)
1. Ensure `android/key.properties` exists (see `RELEASE_SIGNING.md`).
2. Build:
   ```
   flutter build appbundle --release
   ```
3. Upload the AAB to Play Console.

## iOS (App Store)
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set Team + Bundle Identifier (see `RELEASE_SIGNING.md`).
3. Product → Archive → Distribute App.

## Web
1. Build:
   ```
   flutter build web
   ```
2. Deploy the `build/web` directory.

## macOS
1. Build:
   ```
   flutter build macos
   ```
2. Notarize/sign in Xcode if distributing outside Mac App Store.

## Release Workflow
1. Bump `version` in `pubspec.yaml`.
2. Run tests:
   ```
   make integration-tests
   ```
3. Build release artifacts for target platform.
4. Tag the release in git (optional).
