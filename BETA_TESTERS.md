# Aura — Beta tester guide

Thank you for trying Aura. This build is **beta**: expect rough edges, and please send feedback.

**Repository:** https://github.com/ranga291257/aura

---

## Fastest way to try (Docker, ~2 minutes after first build)

No Flutter install required.

```bash
git clone https://github.com/ranga291257/aura.git
cd aura
docker compose up --build
```

Open **http://localhost:8080** in your browser.

- Complete onboarding (name, birth date, country/city, approximate time).
- Open the app daily in the browser for your card — **morning push notifications are not available on web/Docker** (Android/iOS only).
- Your data stays in **your browser** on that machine; clearing site data resets the app.

---

## Android (recommended for daily use)

You need [Flutter](https://docs.flutter.dev/get-started/install) and Android Studio (or SDK + a device).

```bash
git clone https://github.com/ranga291257/aura.git
cd aura
flutter pub get
flutter run -d android
```

**Release APK** (install without USB):

```bash
flutter build apk --release
```

APK path: `build/app/outputs/flutter-apk/app-release.apk`

On first launch, **allow notifications** during onboarding for the morning inspiration card (roughly 5–10 AM, once per day). Battery optimization on some phones may delay alerts — allow Aura to run in the background if prompted.

---

## iPhone (beta on Mac only)

Requires **macOS** + Xcode.

```bash
git clone https://github.com/ranga291257/aura.git
cd aura
flutter pub get
flutter run -d ios
```

Allow notifications when asked. Background delivery depends on iOS scheduling (not a fixed alarm time).

For signing and Simulator setup, see **[README.md — iOS](README.md#ios)**.

---

## What to test

1. **Onboarding** — country/city search, approximate birth time chips, finish flow.
2. **Home screen** — today’s mood, Vedic strips, tap through to the full day card.
3. **Day card** — quote, mood gradient, readability.
4. **Next day** — open again (or wait for morning notification on mobile) and confirm the reading changes.
5. **Privacy** — airplane mode / offline: app should still work after first launch (mobile); web works offline in browser after first load.

---

## Known limitations (beta)

| Topic | Note |
|--------|------|
| Web / Docker | No morning push; open the browser to see today’s card |
| Birth time | City-level approximation, not hospital-exact coordinates |
| Astrology | Educational / inspirational; not professional advice |
| Android package | `com.example.aura` — will change before store release |
| iOS | Simulator and local builds only unless maintainer provides TestFlight |

---

## Feedback

Open a **GitHub Issue**: https://github.com/ranga291257/aura/issues

Include:

- Device / OS (e.g. Pixel 8 / Android 14, or Docker + Firefox)
- Steps to reproduce
- Expected vs actual behavior
- Screenshot if UI-related

Do **not** post your full birth date or name in public issues if you prefer privacy — describe the bug generically.

---

## Full documentation

| Doc | What it covers |
|-----|----------------|
| **[README.md](README.md)** | Install, Docker, Android/iOS, architecture, privacy |
| **[docs/FUNCTIONAL_SPEC.md](docs/FUNCTIONAL_SPEC.md)** | How offline “stars → mood → quote” works (first principles, no astrology jargon required) |

**Already cloned?** Pull the latest: `git pull` in your `aura` folder. Docker users: `docker compose up --build` again. An installed APK does not auto-update from GitHub — rebuild or install a new APK.
