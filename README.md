# TheSpotMarket

Flutter app for the Indian market: IPO analysis, NSE/BSE share-market analysis,
stock/market/business news, multi-person IPO allotment tracking (PAN based),
AI insights (SpotAI) and Google AdMob monetisation.

## Features

| Area | What it does |
| --- | --- |
| IPOs | Open / upcoming / closed / listed tabs, mainboard & SME, subscription (QIB/NII/Retail), GMP & expected listing gain, AI score (0–100) with reasons, watchlist |
| Market | NIFTY 50, SENSEX, BANK NIFTY etc. with sparklines, top gainers/losers, live NSE data with sample fallback |
| Buy / Sell ideas | SpotAI BUY / SELL / HOLD tags for Indian large caps (dashboard + Market tab) with target, stop-loss, confidence and reasons, scored from momentum, 5-day trend, headline sentiment, market mood and volume |
| International Market | New *Global* tab: S&P 500, Dow, NASDAQ, FTSE, DAX, Nikkei, Hang Seng, Shanghai, Gold, Crude, USD/INR + world stocks (Yahoo Finance public data, sample fallback), global buy/sell ideas and international news (CNBC, MarketWatch, Yahoo Finance, Investing.com) |
| News | Aggregated RSS from Economic Times, Moneycontrol, Livemint, Business Standard; search, category filter, bullish/bearish sentiment tag |
| Allotment | Save PAN of family/friends (stored on-device), pick an IPO, auto-check via your backend or open the registrar site with PAN pre-filled and record the result per person |
| SpotAI | Chat assistant (Gemini or OpenAI, or offline heuristic mode), daily AI market brief, IPO scoring, headline sentiment |
| Auth | Firebase email/password + mobile OTP (free Spark plan), password reset, email verification, guest mode |
| Ads | AdMob banner, native and interstitial ads targeted with stock-market / business / startup keywords |

## Quick start

```bash
flutter pub get
flutter run
```

The app runs out of the box with **sample data**, **Google test ad units** and
**guest mode**. Configure the pieces below to go live.

### 1. Firebase Authentication (free)

1. Create a project at <https://console.firebase.google.com> (Spark plan is enough).
2. **Build → Authentication → Sign-in method**: enable **Email/Password** and **Phone**.
3. **Project settings → Your apps**:
   * Add an Android app with package `com.thespotmarket.thespotmarket`, download
     `google-services.json` → put it at `android/app/google-services.json`.
     For phone OTP also add your debug/release SHA-1 and SHA-256 fingerprints
     (`cd android && ./gradlew signingReport`).
   * Add an iOS app with bundle id `com.thespotmarket.thespotmarket`, download
     `GoogleService-Info.plist` → put it at `ios/Runner/GoogleService-Info.plist`
     and add it to the Runner target in Xcode. Add the `REVERSED_CLIENT_ID` as a
     URL scheme and enable Push Notifications / Background Modes for silent APNs
     (required by Firebase phone auth on iOS).
4. Rebuild. Both files are git-ignored; never commit them.

Without these files the app starts in guest mode and Settings shows
"Firebase not configured". Phone OTP on the free plan is limited to
10 SMS/day per project for testing; add test phone numbers in the console.

### 2. AdMob

Replace the Google **test** IDs:

* App IDs: `android/app/src/main/AndroidManifest.xml`
  (`com.google.android.gms.ads.APPLICATION_ID`) and `ios/Runner/Info.plist`
  (`GADApplicationIdentifier`).
* Ad unit IDs via `--dart-define`:

```bash
flutter build apk --release \
  --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/yyy \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/yyy \
  --dart-define=ADMOB_NATIVE_ANDROID=ca-app-pub-xxx/yyy
```

(`*_IOS` variants exist too.) Ad requests carry finance/business keywords
(`lib/config/app_config.dart → adKeywords`) so market, broking, loan and
startup advertisers are preferred.

### 3. AI (SpotAI)

Either pass a key at build time or let the user paste one in Settings.

```bash
--dart-define=AI_PROVIDER=gemini --dart-define=AI_API_KEY=...   # default provider
--dart-define=AI_PROVIDER=openai --dart-define=AI_API_KEY=...
```

Gemini has a free tier at <https://aistudio.google.com>. Without a key SpotAI
answers with built-in educational heuristics.

### 4. Optional backend (`BACKEND_URL`)

Live IPO lists, GMP and automatic allotment checks need a small server because
registrar sites are CAPTCHA protected and NSE blocks non-browser clients.
Pass `--dart-define=BACKEND_URL=https://api.example.com` and implement:

| Endpoint | Response |
| --- | --- |
| `GET /ipos` | `[Ipo, ...]` (see `lib/models/models.dart → Ipo.fromJson`) |
| `GET /market/snapshot` | `{ "indices": [...], "gainers": [...], "losers": [...] }` |
| `GET /global/snapshot` | `{ "indices": [...], "stocks": [...] }` – stocks may include `currency` and `sparkline` |
| `POST /allotment` `{ "ipoId", "pans": ["ABCDE1234F"] }` | `{ "results": [{ "pan", "outcome": "allotted\|not_allotted\|unknown", "shares", "message" }] }` |

If no backend is configured, PANs never leave the device.

## Build

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build ipa
```

## Disclaimer

Market data may be delayed or sample data. AI output is informational and is
not SEBI-registered investment advice.
