# Release Signing Setup

## Android
1. Create a keystore (example):
   ```
   keytool -genkeypair -v -keystore /path/to/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your_key_alias
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill in:
   - `storeFile`
   - `storePassword`
   - `keyAlias`
   - `keyPassword`

The Gradle config will use the release signing config when `android/key.properties` exists.

## iOS
Signing is managed in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set your `Bundle Identifier`.
3. Choose your Team and enable Automatic Signing.
4. Ensure an App ID + provisioning profile exist in Apple Developer.
