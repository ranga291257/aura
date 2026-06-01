# Aura — project structure

What each top-level folder is for. Platform folders (`android/`, `ios/`, etc.) are mostly **Flutter boilerplate**; Aura-specific logic lives under `lib/`.

## Application code (edit here)

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, notification init on mobile |
| `lib/models/` | `UserProfile`, `Mood`, `DayCardModel` |
| `lib/data/` | Offline `quotes.dart`, `birth_locations.dart` |
| `lib/services/` | Astrology, mood, quotes, storage, notifications |
| `lib/screens/` | Splash, onboarding, home, day card UI |
| `lib/theme/` | Colors, typography (Google Fonts) |
| `test/` | Unit tests (6 tests; see `dart_test.yaml`) |

## Documentation

| Path | Purpose |
|------|---------|
| `README.md` | Install, Docker, Android/iOS, architecture summary |
| `BETA_TESTERS.md` | Short beta testing guide |
| `docs/FUNCTIONAL_SPEC.md` | Offline engine spec (first principles) |
| `docs/Aura_iPhone_Setup_Guide.docx` | Optional Xcode / Simulator checklist (Mac) |
| `docs/PROJECT_STRUCTURE.md` | This file |

## Shipping & ops

| Path | Purpose |
|------|---------|
| `pubspec.yaml` / `pubspec.lock` | Dependencies |
| `analysis_options.yaml` | Linter / analyzer rules |
| `dart_test.yaml` | Serial test runs (reliable on all filesystems) |
| `Dockerfile`, `docker-compose.yml`, `docker/` | Web demo via nginx |
| `.github/workflows/ci.yml` | CI: analyze + test on push/PR |
| `.github/ISSUE_TEMPLATE/` | Beta bug report template |
| `LICENSE` | MIT |

## Platform shells (generated / maintained by Flutter)

| Path | Purpose |
|------|---------|
| `android/` | Android app shell, manifest, WorkManager permissions |
| `ios/` | iOS app shell, Xcode project |
| `web/` | PWA manifest, `index.html` for `flutter build web` |
| `linux/`, `macos/`, `windows/` | Desktop targets (optional; web/Docker preferred on Linux) |

**Do not commit:** `build/`, `.dart_tool/`, `ios/Flutter/ephemeral/`, local `.env` (see root `.gitignore`).

## Not in repo (local only)

- `build/` — compile output
- `android/gradlew`, `gradle-wrapper.jar` — ignored; Flutter invokes Gradle via tooling
- IDE folders (`.idea/`) unless you choose to share them
