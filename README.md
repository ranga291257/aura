# Aura — Your Daily Cosmic Guide

[![Beta](https://img.shields.io/badge/status-beta-orange)](BETA_TESTERS.md)

A fully **offline** Flutter app for **Android** and **iOS** that delivers a personalized spiritual morning card each day, driven by **Vedic astrology** (Parashari + KP, Lahiri ayanamsa). No internet, no servers.

You can also run a **browser preview** on Linux/macOS/Windows via Flutter or **Docker** (for sharing with others).

**Beta testers:** start with **[BETA_TESTERS.md](BETA_TESTERS.md)** (Docker quick start, APK, feedback).

```bash
git clone https://github.com/ranga291257/aura.git
cd aura
```

---

## Features

| Feature | Detail |
|---|---|
| Fully offline | Onboarding, chart, and daily cards — no network |
| Vedic astrology | Parashari + KP blended system, Lahiri ayanamsa, Vimshottari Dasha |
| Birth year privacy | Year stored only in OS secure vault (Keychain / EncryptedSharedPreferences) |
| 10 mood categories | 100 original quotes mapped to mood + celestial energy |
| SLM rephrasing | Quote is lightly personalized daily (upgradeable to real on-device LLM) |
| Morning inspiration | Local notification once per day (Android / iOS only) |
| Beautiful day card UI | Mood-specific gradients, Cormorant Garamond typography |

---

## Choose how to run Aura

| Platform | Morning notification | Best for |
|----------|---------------------|----------|
| **Android** | Yes (after you allow notifications) | Daily use on phone |
| **iOS** | Yes (after you allow notifications) | Daily use on iPhone |
| **Docker / web** | No — open the app in the browser | Demos, sharing, Ubuntu without a phone |
| **Linux desktop** | No | Optional native window (can be tricky with Snap Flutter) |

All paths use the same Vedic engine and UI. Profile data stays **on the device** (or in the **browser** for web/Docker).

---

## Prerequisites (Flutter builds)

- [Flutter](https://docs.flutter.dev/get-started/install) **3.19+** / Dart **3.0+**
- **Android:** Android SDK **21+**, device or emulator  
- **iOS:** **macOS**, Xcode **15+**, iOS **14+** (cannot build iOS on Linux/Windows)  
- **Docker (optional):** [Docker Engine](https://docs.docker.com/get-docker/) 20+ or Docker Desktop  

Clone and install dependencies:

```bash
git clone https://github.com/ranga291257/aura.git
cd aura
flutter pub get
flutter test          # 6 unit tests — no device needed
flutter analyze
```

---

## Android

### Setup

1. Install [Android Studio](https://developer.android.com/studio) and the Android SDK.  
2. Accept licenses: `flutter doctor --android-licenses`  
3. Create an AVD (**Device Manager**) or enable **USB debugging** on a physical phone.  
4. Verify: `flutter doctor -v` and `flutter devices`

Custom permissions (notifications, background work, activity recognition) are in `android/app/src/main/AndroidManifest.xml`.

### Run (debug)

```bash
cd aura
flutter emulators                    # list AVDs
flutter emulators --launch <id>      # optional
flutter run -d android
```

Or connect a USB device → `flutter devices` → `flutter run -d <device-id>`.

### Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install on a device: copy the APK and open it, or `adb install build/app/outputs/flutter-apk/app-release.apk`.

### Daily morning card (Android)

- After onboarding, Aura requests **notification** (and **activity recognition**) permission.  
- A **WorkManager** task runs about every **15 minutes** between **5:00–10:00 AM** and shows **one** notification per day with your mood and quote.  
- Battery savers and OEM “optimize battery” settings can delay notifications — allow Aura to run in the background if prompts appear.  
- Optional upgrade to Google Sleep API: see [Android — Sleep API (optional)](#android--sleep-api-optional-upgrade) below.

---

## iOS

**Requires a Mac.** iOS Simulator and App Store builds do not run on Ubuntu or Windows alone.

### Setup

1. Install Xcode from the Mac App Store.  
2. Open Xcode once and accept the license; install iOS Simulator components.  
3. From the project: `cd aura && flutter pub get`  
4. If needed: `cd ios && pod install && cd ..`  
5. `flutter doctor -v` — ensure Xcode and CocoaPods are OK.

### Run (debug)

```bash
cd aura
open ios/Runner.xcworkspace    # optional: open in Xcode for signing
flutter run -d ios             # Simulator or connected iPhone
```

Pick a Simulator in Xcode (**Window → Devices and Simulators**) if `flutter devices` shows none.

### Release (TestFlight / device)

Configure **Signing & Capabilities** in Xcode for your Apple Developer team, then:

```bash
flutter build ipa --release
```

Or **Product → Archive** in Xcode. Cloud macOS CI (Codemagic, GitHub Actions macOS runners) works if you do not have a local Mac.

### Daily morning card (iOS)

- Onboarding requests notification permission.  
- Background refresh schedules a morning check (typically when iOS grants background time, often **6–8 AM**).  
- **One** notification per day with your mood and quote.  
- Optional HealthKit sleep integration: see [iOS — HealthKit (optional)](#ios--healthkit-sleep-detection-optional-upgrade) below.

---

## Docker (browser — try without Flutter)

Packages the **web** build (same UI as `flutter run -d web-server`). Others only need Docker.

From the repo root:

```bash
docker compose up --build
```

Open **http://localhost:8080** (or `http://<host-ip>:8080` on your LAN).

Without Compose:

```bash
docker build -t aura-web .
docker run --rm -p 8080:80 aura-web
```

**Notes**

- First build downloads Flutter inside the image (~5–15 min); later builds use cache.  
- **No morning push** — users open the browser to see today’s card.  
- Data lives in **each visitor’s browser storage**, not in the container.  
- Publish: `docker tag aura-web:latest youruser/aura-web:1.0.0 && docker push youruser/aura-web:1.0.0`

### Flutter web (without Docker)

```bash
flutter config --enable-web
flutter run -d web-server --web-port=8080
```

Open **http://localhost:8080**. If the page is blank, restart the server (web uses notification stubs). Morning notifications are **not** available on web.

---

## Linux development (Ubuntu)

Use this section for **contributing** or **testing on Ubuntu**. For a quick demo for friends, prefer **Docker** above.

### Install Flutter

```bash
sudo snap install flutter --classic
# or manual: https://docs.flutter.dev/get-started/install/linux
flutter doctor -v
```

### First-time platform folders

If `android/` or `linux/` are incomplete:

```bash
cd aura
flutter create . --project-name aura
```

If `flutter create` overwrites `AndroidManifest.xml`, restore notification permissions from git.

### What works on Ubuntu

| Target | Command |
|--------|---------|
| Unit tests | `flutter test` |
| Analyzer | `flutter analyze` |
| Web preview | `flutter run -d web-server --web-port=8080` |
| Docker demo | `docker compose up --build` |
| Android emulator / USB | `flutter run -d android` (see [Android](#android)) |
| iOS | **No** — use a Mac ([iOS](#ios)) |
| Linux desktop | `flutter run -d linux` (see linker note below) |

### Linux desktop linker errors (Snap Flutter)

If `flutter run -d linux` fails with `undefined reference to g_task_set_static_name`, Snap Flutter’s GTK often conflicts with `flutter_secure_storage`. Fixes:

- Use **web** or **Docker** (recommended on Ubuntu), or  
- Install desktop deps: `sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev liblzma-dev libsecret-1-dev`, or  
- Use a **manual** Flutter SDK (not Snap) under `~/flutter`.

`flutter test` does not need the native Linux binary.

---

## Onboarding & birth place

Onboarding uses **country** + **nearest city** from a built-in offline list — no map, no API key.

The chart needs **latitude, longitude, and timezone**; city is the usual approximation when the exact place is unknown. **Approximate birth time:** time picker or chips (e.g. Morning ~9, Unknown → noon).

---

## Code quality

- Lint rules: `analysis_options.yaml`  
- Before commits: `flutter analyze` and `flutter test`

---

## Android — Sleep API (optional upgrade)

The app uses WorkManager polling (every 15 min, 5–10 AM window) by default. For the full Google Sleep API:

1. Add to `android/app/build.gradle`:
   ```groovy
   implementation 'com.google.android.gms:play-services-location:21.2.0'
   ```

2. In `MainActivity.kt`, register a sleep segment receiver:
   ```kotlin
   ActivityRecognition.getClient(this)
     .requestSleepSegmentUpdates(
       PendingIntent.getBroadcast(this, 0,
         Intent(this, SleepReceiver::class.java), PendingIntent.FLAG_UPDATE_CURRENT
       ),
       SleepSegmentRequest.getDefaultSleepSegmentRequest()
     )
   ```

3. In `SleepReceiver.kt`, call Flutter via MethodChannel when a wake event fires after local midnight.

---

## iOS — HealthKit sleep detection (optional upgrade)

1. In Xcode: **Signing & Capabilities → + Capability → HealthKit**
2. In `AppDelegate.swift`, query `HKCategoryTypeIdentifier.sleepAnalysis` on BGAppRefreshTask execution
3. When the latest sleep segment end-time is after midnight → trigger the day card via `FlutterMethodChannel`

---

## Architecture

```
lib/
├── main.dart                     App entry, notification init (mobile only)
├── models/
│   ├── mood.dart                 10 Mood enum values + metadata/colors
│   ├── user_profile.dart         User birth data model
│   └── day_card_model.dart       Daily reading output model
├── data/
│   ├── quotes.dart               100 original quotes (10 × 10 categories)
│   └── birth_locations.dart      Offline country/city coordinates
├── services/
│   ├── astrology_service.dart    Offline planet positions + Dasha
│   ├── birth_year_vault.dart     Secure storage for birth year only
│   ├── birth_timezone_service.dart  Timezone from city coordinates
│   ├── day_card_service.dart     Shared daily card builder
│   ├── mood_engine.dart          Vedic transit + Dasha → Mood
│   ├── quote_service.dart        Quote selection + SLM-style rephrasing
│   ├── storage_service.dart      SharedPreferences + vault coordination
│   ├── notification_service.dart Conditional export (web vs mobile)
│   ├── notification_service_mobile.dart  WorkManager + local notifications
│   └── notification_service_web.dart     No-op stubs for browser/Docker
├── screens/
│   ├── splash_screen.dart        Entry routing
│   ├── onboarding_screen.dart    3-step onboarding (name → DOB/TOB → country/city)
│   ├── home_screen.dart          Daily card home + Vedic strips
│   └── day_card_screen.dart      Full-screen beautiful day card
└── theme/
    └── app_theme.dart            Typography, colors, gradients

docker/                           nginx config for production web image
Dockerfile                        Multi-stage Flutter build + nginx
docker-compose.yml                Local demo on port 8080
```

---

## Astrology Engine

Planet positions are computed using truncated VSOP87 / Meeus algorithms:

| Body | Accuracy | Method |
|---|---|---|
| Sun | ±0.01° | Jean Meeus Ch. 25 |
| Moon | ±0.3° | Truncated ELP2000 (Meeus) |
| Mars / Jupiter / Saturn | ±1.0° | Mean motion + principal correction |
| Mercury / Venus | ±0.5° | Mean motion + principal correction |
| Rahu / Ketu | ±0.2° | Standard mean node formula |

**Ayanamsa:** 60% Lahiri + 40% KP (blended, as specified).

**Dasha calculation:** Full Vimshottari 120-year cycle from natal Moon nakshatra. Antardasha (sub-period) also computed.

**Mood scoring:** Transit Moon sign (45%), Mahadasha (35%), Antardasha (15%), plus waxing/waning tithi modifier.

---

## Upgrading to a Real On-Device SLM

The `QuoteService._rephrase()` method currently uses a deterministic template engine. To upgrade to a real SLM (e.g., Phi-1B, Gemma-1B):

1. Add to `pubspec.yaml`:
   ```yaml
   llama_cpp_dart: ^0.1.0   # or: flutter_llama_cpp
   ```

2. Download a quantized GGUF model (~400 MB for Phi-1B Q4):
   ```
   assets/models/phi-1b-q4.gguf
   ```

3. In `QuoteService`, replace the template call with:
   ```dart
   final llm = LlamaModel.load('assets/models/phi-1b-q4.gguf');
   final prompt = _buildSlmPrompt(...);
   final result = await llm.complete(prompt, maxTokens: 80);
   return result.trim();
   ```

The `_buildSlmPrompt()` method is already written and ready to use.

---

## Quote Categories

| # | Mood | Energy |
|---|---|---|
| 1 | Confident | Solar |
| 2 | Low / Gentle | Lunar |
| 3 | Stressed / Steady | Mars |
| 4 | Unmotivated / Flowing | Jupiter |
| 5 | Anxious / Present | Venus |
| 6 | Confused / Seeking | Mercury |
| 7 | Angry / Channelled | Mars fire |
| 8 | Hopeful / Rising | Jupiter light |
| 9 | Discouraged / Renewing | Saturn depth |
| 10 | Determined / Focused | Saturn will |

---

## Privacy

- Name, birth day/month, time, and city stored in `SharedPreferences` (or browser local storage on web)
- **Birth year** stored only in the device secure vault (`flutter_secure_storage`) on mobile — not in profile JSON, logs, or notifications
- No analytics, no tracking, no telemetry
- No network permission or calls in the mobile app; Docker only serves static files
- Birth data never leaves the device (web: stays in the user’s browser)

---

## Disclaimer

Aura is designed for personal reflection and guidance. Astrological interpretations are for inspirational and entertainment purposes. They do not constitute medical, psychological, or life advice.
