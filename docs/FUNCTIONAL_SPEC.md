# Aura — Functional specification (first principles)

Reverse-engineered description of how Aura works **without requiring astrology background knowledge**. For developers and students who want to rebuild or extend similar software.

**Repository:** https://github.com/ranga291257/aura  
**Last verified against:** `main` branch (offline Dart engine in `lib/services/`).

---

## 1. Problem statement

**Goal:** Each day, show a short personal message (“day card”) that feels aligned with the user’s emotional energy, using only:

- Data collected once at onboarding (name, birth date, birth time, birth place).
- The device clock (what “today” means).
- Content bundled inside the app (quotes, city coordinates, timezone rules, astronomy formulas).

**Non-goals in current code:**

- No network calls for charts, maps, or AI at runtime (mobile).
- No telescope or GPS input.
- No claim of medical/psychological prediction.

**Honest framing:** The app **calculates approximate planet positions** with published astronomy formulas, applies **Vedic labeling rules**, then maps labels to **moods and quotes** via fixed tables. It does not “see” the sky.

---

## 2. Glossary (astrology → programming)

| Term | Programmer view | In Aura |
|------|-----------------|--------|
| **Ecliptic longitude** | Angle 0–360° along the zodiac belt | `double`, normalized with `norm360()` |
| **Tropical zodiac** | 0° tied to seasons (Western) | Output of Meeus-style formulas |
| **Sidereal / Vedic zodiac** | 0° tied to fixed stars (shifted) | `tropical - ayanamsa` |
| **Sign (rashi)** | 12 buckets × 30° | `signs[floor(lon / 30) % 12]` |
| **Nakshatra** | 27 buckets × (360/27)° | `nakshatras[floor(lon / (360/27)) % 27]` |
| **Tithi** | Lunar day index (0–29) from Sun–Moon angle | `floor((moonLon - sunLon) / 12) % 30` |
| **Mahadasha / Antardasha** | Major / sub “life period” lords | Discrete 120-year state machine from natal Moon |
| **Transit** | Planet positions at “now” | `todayTransit()` using `DateTime.now()` |
| **Mood** | App enum (10 values) | Winner of weighted score map |

---

## 3. System architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER / DEVICE                               │
│  Onboarding → UserProfile → StorageService (+ BirthYearVault)    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  DayCardService.build(profile, onDate?)                          │
│    1. AstrologyService.todayTransit(profile)  ← uses device NOW   │
│    2. MoodEngine.determineMood(transit)                          │
│    3. QuoteService.getQuoteForDay(..., date: onDate ?? now)      │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
  BirthTimezoneService   AstrologyService      quotes.dart
  birth_locations.dart   mood_engine.dart     quote_service.dart
  (timezone DB)          (planet math+dasha)
```

**Bundled offline assets (no download at runtime):**

- `lib/data/birth_locations.dart` — city lat/long list.
- `lib/data/quotes.dart` — 100 strings (10 moods × 10).
- `timezone` package data — IANA rules (via `BirthTimezoneService`).
- All planet formulas — inline in `astrology_service.dart`.

---

## 4. Data model

### 4.1 `UserProfile` (`lib/models/user_profile.dart`)

| Field | Purpose |
|-------|---------|
| `name`, `firstName` | UI + quote personalization |
| `dateOfBirth` | Dasha elapsed time; day/month in prefs |
| `birthHour`, `birthMinute` | Local civil birth time |
| `birthLatitude`, `birthLongitude` | From selected city |
| `birthTimezoneOffsetMinutes` | Minutes east of UTC; subtract from UTC to get local |
| `birthCity` | Display label only |

**Privacy:** `toPrefsJson()` omits birth year. Year is stored in `BirthYearVault` (Keychain / EncryptedSharedPreferences on mobile).

### 4.2 `DailyTransit` (computed)

Today’s sidereal signs, natal Moon labels, dasha lords, tithi, waxing flag, etc. Built in `AstrologyService.todayTransit`.

### 4.3 `DayCardModel` (UI output)

Mood, original + rephrased quote, `AstroSnapshot`, guidance string.

---

## 5. Pipeline (step by step)

### Step A — Birth place and timezone

**Module:** `BirthTimezoneService` + `birth_locations.dart`

1. User picks country → city from static list (approximate coordinates).
2. `latLngToTimezoneString(lat, lng)` → IANA zone id.
3. `TZDateTime(zone, y, m, d, h, min)` → `birthTimezoneOffsetMinutes`.

**First principle:** Wrong timezone ⇒ wrong birth instant ⇒ wrong natal Moon ⇒ wrong dasha.

### Step B — Birth instant in UTC

**Module:** `AstrologyService._toBirthUtc`

```text
birthUtc = DateTime.utc(y, m, d, hour, minute)
           .subtract(Duration(minutes: birthTimezoneOffsetMinutes))
```

### Step C — Julian time base

**Functions:** `julianDay(dt)`, `julianCenturies(dt)`

Standard conversion from calendar date/time to Julian Day and centuries since J2000.0. All planet functions use `T = julianCenturies(dt)`.

### Step D — Tropical longitudes (Western astronomy layer)

**Module:** `AstrologyService` — planet functions

| Body | Method | Documented accuracy |
|------|--------|---------------------|
| Sun | Jean Meeus Ch. 25 | ±0.01° |
| Moon | Truncated ELP / Meeus sum of sin terms | ±0.3° |
| Mars, Jupiter, Saturn | Mean longitude + anomaly correction | ±1° |
| Mercury, Venus | Mean longitude + multiple sin terms | ±0.5° |
| Rahu (mean node) | Linear formula in T | ±0.2° |
| Ketu | `rahu + 180°` | — |

**First principle:** Orbital motion is predictable; centuries of astronomy express it as **trigonometric series in time**. No ephemeris server required.

### Step E — Sidereal (Vedic) longitudes

```text
siderealLon = norm360(tropicalLon - blendedAyanamsa(dt))

blendedAyanamsa = 0.6 * lahiriAyanamsa(T) + 0.4 * kpAyanamsa(T)
```

**First principle:** “Which sign?” depends on where you place 0° Aries. Vedic systems subtract a fixed precession angle (ayanamsa).

### Step F — Labels

| Label | Rule |
|-------|------|
| Sign | `floor(sidereal / 30) % 12` → name table |
| Nakshatra | `floor(sidereal / (360/27)) % 27` |
| Nakshatra lord | Fixed 27-length table (Vimshottari order) |
| Tithi | `floor(norm360(moonTrop - sunTrop) / 12) % 30` |
| Waxing | `tithi < 15` |

### Step G — Vimshottari Dasha

**Inputs:** Natal sidereal Moon at `birthUtc`, `DateTime.now()` for elapsed time.

**Constants:** Nine lords in fixed order; year lengths summing to 120 (Ketu 7, Venus 20, Sun 6, Moon 10, Mars 7, Rahu 18, Jupiter 16, Saturn 19, Mercury 17).

**Logic:**

1. Find Moon’s nakshatra at birth and fraction already passed within that nakshatra.
2. Remaining years in starting lord’s period.
3. Walk the circular sequence, adding full period lengths until `elapsedYearsSinceBirth` falls in current block → **Mahadasha** lord.
4. **Antardasha:** subdivide active Mahadasha into nine proportional sub-blocks.

**First principle:** A **deterministic finite-state timeline**, not live observation.

### Step H — Today’s transit snapshot

**Function:** `AstrologyService.todayTransit(profile)`

- Computes sidereal positions for Sun, Moon, Mars, Jupiter, Saturn, Mercury, Venus, Rahu/Ketu at **`DateTime.now().toUtc()`**.
- Computes natal Moon sign/nakshatra at birth.
- Attaches `currentMahadasha` / `currentAntardasha`.

### Step I — Mood

**Module:** `MoodEngine`

Weighted vote over 10 `Mood` values:

| Signal | Weight |
|--------|--------|
| Transit Moon sign | 45 |
| Mahadasha lord | 35 |
| Antardasha lord | 15 |
| Waxing / waning tweak | +2 to +5 on selected moods |

Each signal uses a **hard-coded table** mapping sign or lord → fractional contributions per mood. Highest total wins.

**First principle:** Product policy encoded as data; swap tables to change “feel” without changing astronomy.

### Step J — Quote

**Modules:** `quotes.dart`, `QuoteService`

1. Select list for winning `Mood` (10 quotes).
2. `seed = (dayOfYear + birthDay + birthMonth*31 + name.length*7) % 100`
3. `quoteIndex = seed % 10`; pick template via `seed ~/ 10`.
4. Apply one of five string templates (deterministic rephrase).

**Note:** `_buildSlmPrompt()` exists for a future on-device LLM; **not used** in the shipping path.

### Step K — Orchestration

**Module:** `DayCardService.build`

```dart
final date = onDate ?? DateTime.now();
final transit = AstrologyService.todayTransit(profile);  // always device NOW
final mood = MoodEngine.determineMood(transit);
final dayQuote = QuoteService.getQuoteForDay(..., date: date, ...);
```

**Important implementation detail:** `onDate` affects the **card date label and quote seed only**. Planet/mood/dasha math always uses **current device time** inside `todayTransit`. Tests that pass `onDate` do not rewind the sky unless `todayTransit` is extended (future improvement).

---

## 6. Notifications (mobile only)

**Module:** `notification_service_mobile.dart`

- WorkManager periodic task every **15 minutes**.
- Background handler runs only if local hour ∈ **[5, 10)** and `StorageService.hasCardForToday()` is false.
- Builds card via `DayCardService.build(profile, onDate: now)` and shows one local notification.

Web/Docker: stubs in `notification_service_web.dart` (no push).

---

## 7. Storage

| Key / vault | Content |
|-------------|---------|
| SharedPreferences `user_profile` | JSON without birth year |
| `BirthYearVault` | Birth year only |
| `last_card_date` | Prevents duplicate morning notification |

Web: browser local storage via same prefs abstraction.

---

## 8. File map (source of truth)

| Concern | File |
|---------|------|
| Planet math, ayanamsa, dasha, transit | `lib/services/astrology_service.dart` |
| Timezone resolution | `lib/services/birth_timezone_service.dart` |
| Cities | `lib/data/birth_locations.dart` |
| Mood rules | `lib/services/mood_engine.dart` |
| Quotes + rephrase | `lib/data/quotes.dart`, `lib/services/quote_service.dart` |
| Wire-up | `lib/services/day_card_service.dart` |
| Profile + persistence | `lib/models/user_profile.dart`, `lib/services/storage_service.dart` |
| Tests | `test/day_card_service_test.dart`, `test/birth_timezone_service_test.dart`, etc. |

---

## 9. Pseudocode (minimal daily card)

```text
function buildDailyCard(profile, clock):
  birthUtc = localBirthToUtc(profile)
  nowUtc = clock.nowUtc()

  for body in PLANETS:
    trop[body] = bodyFormula(nowUtc)
    sid[body] = trop[body] - ayanamsa(nowUtc)

  transit = {
    moonSign: sign(sid.Moon),
    dasha: mahadasha(profile, nowUtc),
    antardasha: antardasha(profile, nowUtc),
    tithi: tithi(trop.Sun, trop.Moon),
    waxing: tithi < 15
  }

  mood = argmax(weightedTables(transit))
  quote = quoteBank[mood][hash(profile, clock.calendarDate) % 10]
  text = template(quote, profile, transit)

  return { mood, text, transit }
```

---

## 10. Limitations (spec level)

| Topic | Limitation |
|-------|------------|
| Ephemeris | Truncated analytical series, not NASA JPL DE |
| Birth place | City centroid from static list |
| Birth time | User estimate; “unknown” often defaults to noon in UI |
| `onDate` parameter | Does not change transit astronomy today |
| Dasha | Simplified antardasha walk; not a full professional panchang |
| Mood | Interpretive tables, not statistical forecasting |
| Ascendant | Computed in service but not driving mood in current `MoodEngine` |

---

## 11. Reimplementation checklist (student project)

1. **Profile + city DB + timezone** — unit-test Mumbai/New York offsets.
2. **Julian day module** — test one known JD.
3. **Sun + Moon only** — compare to almanac for one timestamp.
4. **Sidereal + one ayanamsa** — then add Lahiri/KP blend.
5. **Sign / nakshatra / tithi** — pure functions of longitude.
6. **Dasha FSM** — golden tests with fixed natal Moon.
7. **Mood tables** — externalize JSON for tuning without code changes.
8. **Quotes** — separate content pipeline from astronomy.
9. **Injectable clock** — `todayTransit(profile, at: Instant)` for reproducible tests.

---

## 12. Related documentation

- **[README.md](../README.md)** — install, Docker, Android/iOS, architecture overview.
- **[BETA_TESTERS.md](../BETA_TESTERS.md)** — how to try the beta and give feedback.

---

## Disclaimer

Aura is for personal reflection and inspiration. Astrological labels are entertainment and self-reflection tools, not medical or professional advice.
