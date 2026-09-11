# ChatAI Android Build Setup

This directory contains the Capacitor configuration and Android project files for building ChatAI as a native Android app.

## Quick Start

### Prerequisites
- Node.js 18+
- JDK 17+ (from Android Studio or java.oracle.com)
- Android SDK (API 34)
- Gradle 8.1.4+

### Build Locally

```bash
# From the project root
chmod +x build-android.sh
./build-android.sh
```

This will:
1. Build the React web app to `dist/`
2. Copy the build to Android assets
3. Build a debug APK

### Build Via GitHub Actions

Push to the `android/capacitor-androidize` branch:

```bash
git push origin android/capacitor-androidize
```

The workflow will:
1. Build the web app
2. Build debug APK and release AAB
3. Upload artifacts to GitHub Actions
4. Create release with downloadable files

### Install APK

**Method 1: Via ADB (if connected to computer)**
```bash
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
```

**Method 2: Manual install**
1. Download `app-debug.apk` from GitHub Actions artifacts or release
2. Transfer to your Android device
3. On device: Settings → Security → Allow installation from unknown sources
4. Open file manager, tap the APK, and select Install

## Directory Structure

```
android/
├── app/                          # Main Android app module
│   ├── build.gradle              # App build config (dependencies, version codes)
│   ├── proguard-rules.pro         # Obfuscation rules for release builds
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml      # App permissions and activities
│           ├── java/com/chatai/app/
│           │   └── MainActivity.java    # Capacitor activity (loads web app)
│           └── res/
│               ├── values/strings.xml   # App strings
│               ├── values/styles.xml    # UI themes
│               └── ic_launcher-*.png    # App icons
├── build.gradle                  # Root project config
├── settings.gradle               # Module includes
└── gradlew                        # Gradle wrapper script

capacitor.config.json              # Capacitor framework configuration
build-android.sh                   # Local build script
```

## Configuration

### capacitor.config.json

- **appId**: `com.chatai.app` - Unique identifier for your app
- **webDir**: `dist` - Where the built React app is located
- **server.url**: API endpoint (configure via `VITE_API_BASE` env var)
- **plugins**: Status bar, splash screen, and other native features

### AndroidManifest.xml

Permissions configured:
- `INTERNET` - Required for API calls
- `ACCESS_NETWORK_STATE` - Check connectivity
- `READ/WRITE_EXTERNAL_STORAGE` - File access

### Build Variants

- **Debug**: `minifyEnabled=false`, `debuggable=true`
  - Smaller build time
  - Easier debugging
  - Use for development and testing

- **Release**: `minifyEnabled=true`, `proguardRules` applied
  - Optimized code size
  - Obfuscated (harder to reverse engineer)
  - Use for Play Store submission

## GitHub Actions Workflow

The `.github/workflows/android-build.yml` workflow:

1. **Triggered on**:
   - Push to `android/capacitor-androidize` branch
   - Push to `main` branch
   - Manual trigger via GitHub UI

2. **Build Steps**:
   - Checkout code
   - Install Node.js dependencies
   - Build React web app with Vite
   - Set up Java 17 and Android SDK
   - Copy web build to Android assets
   - Build debug APK via Gradle
   - Build release AAB via Gradle

3. **Artifacts**:
   - `app-debug.apk` - Debug APK (30-day retention)
   - `app-release.aab` - Release AAB (30-day retention)

4. **Output**:
   - Download from GitHub Actions tab
   - Files available for 30 days

### Accessing Build Artifacts

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select the latest workflow run
4. Scroll to **Artifacts** section
5. Download `chatai-debug-apk` or `chatai-release-aab`

## Troubleshooting

### Build fails with "SDK not found"
```bash
# Set ANDROID_HOME if not set
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
# or
export ANDROID_HOME=$HOME/Android/Sdk          # Linux
```

### "Gradle wrapper not found"
```bash
cd android
chmod +x gradlew
```

### APK won't install: "App not installed"
- Ensure minimum API level 24 (Android 7.0+)
- Check device storage space
- Try: `adb uninstall com.chatai.app` then reinstall

### "Failed to find Build Tools version 34.0.0"
```bash
# Install via Android Studio SDK Manager:
# Tools → SDK Manager → SDK Tools → Show Package Details
# Check "Android SDK Build-Tools 34.0.0"
```

### GitHub Actions workflow not triggering
- Ensure `.github/workflows/android-build.yml` is on the branch
- Check branch name matches trigger conditions
- Try manual trigger: Actions tab → Select workflow → Run workflow

### "Could not find com.android.tools.build:gradle"
- Verify internet connection
- Check `android/build.gradle` Gradle plugin version
- Maven Central and Google repositories are configured

## Development Workflow

### Local Testing Loop

```bash
# 1. Make changes to React app
# 2. Build Android
./build-android.sh

# 3. Install on device
adb install -r android/app/build/outputs/apk/debug/app-debug.apk

# 4. Test on device
# 5. Check logs
adb logcat
```

### Hot Reload (Development)

For faster development iteration:

```bash
# Terminal 1: Start dev server (if your backend supports it)
npm run dev

# Terminal 2: Build and install
./build-android.sh
```

### Creating Release Builds

For production/Play Store submission:

```bash
cd android
./gradlew bundleRelease
```

Output: `android/app/build/outputs/bundle/release/app-release.aab`

This requires signing configuration (see "Sign for release" section below).

## Next Steps

1. **Test locally**: Run `./build-android.sh` and install APK
2. **Configure API endpoint**: Update `VITE_API_BASE` in `android-build.yml`
3. **Add app icons**: Replace `android/app/src/main/ic_launcher-*.png` with your branding
4. **Customize app name/strings**: Edit `android/app/src/main/res/values/strings.xml`
5. **Sign for release**: Set up a keystore for Play Store signing (see below)
6. **Submit to Play Store**: Use the release AAB for app store submission

### Sign for Release (Optional)

To submit to Google Play Store, you need to sign the release build:

1. **Generate a keystore**:
```bash
keytool -genkey -v -keystore my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

2. **Configure signing in `android/app/build.gradle`**:
```gradle
signingConfigs {
    release {
        storeFile file('/path/to/my-release-key.jks')
        storePassword 'your-password'
        keyAlias 'my-key-alias'
        keyPassword 'key-password'
    }
}
```

3. **Update release build type**:
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

4. **Build signed release**:
```bash
cd android
./gradlew bundleRelease
```

**⚠️ Security Note**: Never commit `my-release-key.jks` or keystore passwords to version control. Use GitHub Secrets for CI/CD.

## Resources

- [Capacitor Android Docs](https://capacitorjs.com/docs/android)
- [Android Gradle Plugin](https://developer.android.com/studio/build)
- [Google Play Console](https://play.google.com/console)
- [Android Manifest Documentation](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [ProGuard/R8 Obfuscation](https://developer.android.com/studio/build/shrink-code)

## Environment Variables

For CI/CD, set these in GitHub Secrets:

- `VITE_API_BASE`: Backend API URL (e.g., `https://api.example.com`)
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

## FAQ

**Q: Can I build without Android Studio?**
A: Yes, you only need JDK 17+ and Android SDK command-line tools.

**Q: How do I target a different API level?**
A: Edit `android/app/build.gradle` - modify `targetSdkVersion` and `compileSdkVersion`.

**Q: What's the difference between APK and AAB?**
A: APK is for direct installation. AAB is for Google Play Store (it creates optimized APKs per device).

**Q: How often should I update dependencies?**
A: Review monthly. Update Gradle plugin, Capacitor, and Android libraries for security patches.

**Q: Can I use Capacitor plugins?**
A: Yes! Install via npm and add to Capacitor config. See [Capacitor Plugin Registry](https://capacitorjs.com/docs/plugins).
