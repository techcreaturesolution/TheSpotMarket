# PRE-PHASE 3 — BACKEND vs EXTERNAL API ARCHITECTURE AUDIT REPORT

**Project Name:** TheSpotMarket  
**Workspace Path:** `c:\TCS-P\TheSpotMarket`  
**Audit Timestamp:** September 17, 2026  
**Audit Scope:** Full Repository & Workspace Forensic Audit  

---

## 1. EXECUTIVE SUMMARY

A strict forensic audit of the entire `TheSpotMarket` workspace (`c:\TCS-P\TheSpotMarket`) was conducted prior to Phase 3. The audit evaluated workspace files, client architecture, service layers, network calls, configuration hooks, database usage, and Firebase integrations.

### Key Audit Findings

1. **No Custom Backend Source Code in Workspace:** The workspace contains **ONLY** the Flutter client codebase. There are **NO** server-side source files, backend frameworks, database schemas, Docker containers, API server routes, or Cloud Functions in this workspace.
2. **Flutter Client Backend Hook:** The Flutter app includes an optional environment configuration hook (`AppConfig.backendBaseUrl`, read from `--dart-define=BACKEND_URL`). When empty, the app falls back to direct external public APIs (Yahoo Finance, NSE India, RSS news publishers, Google Gemini/OpenAI) and local sample data.
3. **External API Dependence:** Market data, global indices, and news are fetched directly by the Flutter client from third-party public endpoints and RSS XML feeds.
4. **Firebase Role:** Firebase is included in `pubspec.yaml` strictly for client-side Authentication (`firebase_auth`). However, Firebase configuration files (`google-services.json` / `GoogleService-Info.plist`) are **missing** from the workspace, causing the app to automatically run in Guest Mode. Firebase is **NOT** used as a database or primary backend.
5. **Local Persistence:** All user data (watchlist, PAN profiles, app settings, local chat history) is stored locally on-device using `shared_preferences` and encrypted `flutter_secure_storage`. No user data is stored on a server database.

---

## 2. WORKSPACE INVENTORY

A complete recursive scan of `c:\TCS-P\TheSpotMarket` (excluding `.git`, `.dart_tool`, and `build`) was performed.

### Directory Structure Inventory

```text
c:\TCS-P\TheSpotMarket\
├── android/                        # Android native project files
├── ios/                            # iOS native project files
├── lib/                            # Flutter Dart client source code
│   ├── config/
│   │   └── app_config.dart         # Environment variables & API endpoints
│   ├── models/
│   │   └── models.dart             # Dart data models
│   ├── providers/
│   │   └── app_state.dart          # State management (Provider)
│   ├── screens/                    # 10 UI screens
│   │   ├── ai_chat_screen.dart
│   │   ├── allotment_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── global_market_screen.dart
│   │   ├── home_screen.dart
│   │   ├── ipo_screens.dart
│   │   ├── market_screen.dart
│   │   ├── news_screen.dart
│   │   ├── settings_screen.dart
│   │   └── suggestions_screen.dart
│   ├── services/                   # 10 client service wrappers
│   │   ├── ad_service.dart
│   │   ├── ai_service.dart
│   │   ├── allotment_service.dart
│   │   ├── auth_service.dart
│   │   ├── global_market_service.dart
│   │   ├── ipo_service.dart
│   │   ├── market_service.dart
│   │   ├── news_service.dart
│   │   ├── sample_data.dart
│   │   └── storage_service.dart
│   ├── widgets/
│   │   ├── common.dart
│   │   └── curved_nav_bar.dart
│   └── main.dart                   # Application entry point
├── test/
│   └── core_test.dart              # Core unit tests
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── PHASE_0_AUDIT_REPORT.md
├── PHASE_1_CHANGELOG.md
├── PHASE_1_REPORT.md
├── PHASE_2_CHANGELOG.md
├── PHASE_2_REPORT.md
├── pubspec.lock
├── pubspec.yaml
└── README.md
```

### Specific Backend Artifact Verification

| Directory / Artifact File | Status | Verification Detail |
| ------------------------- | ------ | ------------------- |
| `backend/` | **NOT FOUND** | No folder named `backend` exists. |
| `server/` | **NOT FOUND** | No folder named `server` exists. |
| `api/` | **NOT FOUND** | No server `api` folder exists (only client `lib/services/`). |
| `server.js` / `app.js` / `index.js` | **NOT FOUND** | No Node.js entry point exists. |
| `package.json` / `yarn.lock` | **NOT FOUND** | No Node.js / JavaScript backend config exists. |
| `requirements.txt` / `pyproject.toml` | **NOT FOUND** | No Python backend config exists. |
| `manage.py` / `Pipfile` | **NOT FOUND** | No Django or Flask backend exists. |
| `Dockerfile` / `docker-compose.yml` | **NOT FOUND** | No containerization specs exist. |
| `.env` / `.env.example` | **NOT FOUND** | No environment file exists in workspace. |
| `firebase.json` / `firestore.rules` | **NOT FOUND** | No Firebase backend rules or deploy specs exist. |
| `functions/` / `cloud_functions/` | **NOT FOUND** | No Cloud Functions directory exists. |
| `supabase/` / `prisma/` | **NOT FOUND** | No Supabase or ORM configuration exists. |
| `migrations/` / `schema/` / `SQL files` | **NOT FOUND** | No database schemas or migration scripts exist. |
| `controllers/` / `routes/` (server) | **NOT FOUND** | No server route controllers exist. |

---

## 3. BACKEND SOURCE FINDINGS

### Custom Backend Source Found?
**NO — no backend source found.**

### Audit Finding Statement
> "Flutter client contains references to a custom backend/API via `AppConfig.backendBaseUrl`, but backend source code was not found in the inspected workspace."

The Flutter codebase references 4 backend endpoints (`/allotment`, `/global/snapshot`, `/ipos`, `/market/snapshot`) under `AppConfig.backendBaseUrl`. However, **no backend repository or server source code exists anywhere inside this workspace**.

---

## 4. BACKEND TECHNOLOGY

### Custom Backend Technology
**NOT FOUND / NOT VERIFIABLE**

### Verification Summary
- **Node.js / Express / NestJS / Fastify / Koa:** No `package.json`, `.js`, or `.ts` server files.
- **Python / FastAPI / Flask / Django:** No `requirements.txt` or `.py` files.
- **PHP / Laravel / Symfony:** No `composer.json` or `.php` files.
- **Java / Spring Boot:** No `pom.xml`, `build.gradle`, or `.java` server files.
- **.NET / C#:** No `.csproj` or `.cs` server files.
- **Go:** No `go.mod` or `.go` files.
- **Firebase Cloud Functions:** No `functions/` folder or deployed function source.

---

## 5. DATABASE FINDINGS

### Database Technology
**NOT FOUND / NOT VERIFIABLE**

### Verification Summary
- **Server Databases (MongoDB, PostgreSQL, MySQL, SQLite, Redis):** **None.** No connection strings, drivers, models, schemas, or migrations exist in the workspace.
- **Cloud Databases (Firestore, Firebase Realtime Database, Supabase):** **None.** Zero dependencies or code references exist for Firestore or Realtime DB in `pubspec.yaml` or `lib/`.
- **Client-Side Storage:**
  - `shared_preferences` (v2.3.2): Non-sensitive preferences (dark mode, watchlist, allotment history, local settings).
  - `flutter_secure_storage` (v11.1.1): Encrypted local storage for sensitive PAN profiles.

---

## 6. FLUTTER API INVENTORY

Complete inventory of all network endpoints and remote services referenced in the Flutter client:

| API / Service | URL / Host | Called From | Purpose | Type | Authentication | Status |
| ------------- | ---------- | ----------- | ------- | ---- | -------------- | ------ |
| Custom Backend Allotment | `{BACKEND_URL}/allotment` | `AllotmentService.checkMany()` | Automated multi-PAN allotment check | `CUSTOM_BACKEND` | Optional Header | Unconfigured (`BACKEND_URL` empty) |
| Custom Backend Global Snapshot | `{BACKEND_URL}/global/snapshot` | `GlobalMarketService._fromBackend()` | Global indices & stock quotes snapshot | `CUSTOM_BACKEND` | None | Unconfigured (`BACKEND_URL` empty) |
| Custom Backend IPO Feed | `{BACKEND_URL}/ipos` | `IpoService.fetchIpos()` | Indian IPO calendar & subscription stats | `CUSTOM_BACKEND` | None | Unconfigured (`BACKEND_URL` empty) |
| Custom Backend Market Snapshot | `{BACKEND_URL}/market/snapshot` | `MarketService._fromBackend()` | Indian market snapshot (indices, gainers/losers) | `CUSTOM_BACKEND` | None | Unconfigured (`BACKEND_URL` empty) |
| Yahoo Finance Public Chart API | `query1.finance.yahoo.com/v8/finance/chart/{ticker}` | `GlobalMarketService._chart()` | 5-day price history & quote data for global symbols | `EXTERNAL_API` | None | Active Public API |
| NSE India Cookie Handshake | `www.nseindia.com` | `MarketService._ensureNseCookie()` | Session cookie retrieval for NSE API calls | `EXTERNAL_API` | Cookie Handshake | Active Public API |
| NSE India All Indices | `www.nseindia.com/api/allIndices` | `MarketService._fromNse()` | Live Nifty/BSE index quotes | `EXTERNAL_API` | Cookie | Active Public API |
| NSE India Nifty 50 Stocks | `www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050` | `MarketService._fromNse()` | Nifty 50 stock quotes & gainers/losers | `EXTERNAL_API` | Cookie | Active Public API |
| Indian News RSS Feeds | Economic Times, Moneycontrol, Livemint, Business Standard (7 URLs) | `NewsService.fetchFeeds()` | Parse Indian financial news RSS XML | `EXTERNAL_API` | None | Active Public RSS |
| Global News RSS Feeds | CNBC, MarketWatch, Yahoo Finance, Investing.com (6 URLs) | `NewsService.fetchFeeds()` | Parse global financial news RSS XML | `EXTERNAL_API` | None | Active Public RSS |
| Gemini Generative AI API | `generativelanguage.googleapis.com/v1beta/models/{model}:generateContent` | `AiService._gemini()` | SpotAI financial analyst chatbot | `EXTERNAL_API` | API Key (`AI_API_KEY`) | Configurable via Settings/Define |
| OpenAI Chat API | `api.openai.com/v1/chat/completions` | `AiService._openAi()` | SpotAI financial analyst chatbot | `EXTERNAL_API` | Bearer Token (`AI_API_KEY`) | Configurable via Settings/Define |
| Firebase Auth Service | Firebase SDK (`FirebaseAuth.instance`) | `AuthService` | User Sign-Up, Sign-In, Phone OTP | `FIREBASE` | Firebase Auth Credentials | Unconfigured (`google-services.json` missing) |
| Registrar Public Portals | Link Intime, KFintech, Bigshare, Cameo, etc. (8 URLs) | `AllotmentService.registrarFor()`, `AllotmentScreen` | In-app WebView PAN allotment lookup | `EXTERNAL_API` | Captcha / Web Form | Direct Web Navigation |

---

## 7. IDENTIFY OUR OWN BACKEND APIs

The Flutter client defines contracts for 4 custom backend endpoints:

1. **`POST /allotment`**
   - **Service:** `AllotmentService.checkMany()`
   - **Request Body:** `{"ipoId": "...", "ipoName": "...", "registrar": "...", "pans": ["ABCDE1234F", ...]}`
   - **Expected Response:** `{"results": [{"pan": "...", "status": "allotted|not_allotted|pending", "shares": 15, "message": "..."}]}`
   - **Purpose:** Server-side headless browser or CAPTCHA solving service for multi-PAN allotment checking.
   - **Current Fallback:** In-app WebView with JavaScript auto-fill of PAN on registrar portals.

2. **`GET /market/snapshot`**
   - **Service:** `MarketService._fromBackend()`
   - **Expected Response:** `{"indices": [...], "gainers": [...], "losers": [...]}`
   - **Purpose:** Aggregated server feed for Indian stock market indices and gainers/losers.
   - **Current Fallback:** Direct client calls to NSE India (`www.nseindia.com/api/...`) with cookie handshake, falling back to `SampleData`.

3. **`GET /global/snapshot`**
   - **Service:** `GlobalMarketService._fromBackend()`
   - **Expected Response:** `{"indices": [...], "stocks": [...]}`
   - **Purpose:** Aggregated server feed for international market indices, commodities, forex, and stocks.
   - **Current Fallback:** Direct client calls to Yahoo Finance (`query1.finance.yahoo.com`), falling back to `SampleData`.

4. **`GET /ipos`**
   - **Service:** `IpoService.fetchIpos()`
   - **Expected Response:** `[{"id": "...", "name": "...", "status": "open|upcoming|closed|listed", "openDate": "...", "issueSizeCr": 1200, ...}]`
   - **Purpose:** Server feed aggregating IPO calendar, subscription numbers, and GMP data.
   - **Current Fallback:** `SampleData.ipos()`.

> **Backend Source Status:** These 4 endpoints are defined on the client side, but **no server source code exists in this workspace**.

---

## 8. FIREBASE ROLE AUDIT

| Firebase Service | Used in Code? | Evidence | Runtime Verified? |
| ---------------- | ------------- | -------- | ----------------- |
| Firebase Core | **YES** | `pubspec.yaml` (`firebase_core: ^3.8.0`), `lib/main.dart` (`Firebase.initializeApp()`) | Unconfigured (`google-services.json` missing; caught gracefully in `main.dart`) |
| Firebase Authentication | **YES** | `pubspec.yaml` (`firebase_auth: ^5.3.3`), `lib/services/auth_service.dart` | Unconfigured (Fallback to Guest Mode) |
| Firestore Database | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Realtime Database | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Cloud Storage | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Cloud Functions | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Firebase Messaging (FCM) | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Firebase Analytics | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Crashlytics | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| Remote Config | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |
| App Check | **NO** | 0 imports; missing from `pubspec.yaml` | N/A |

### Is Firebase the Primary Application Backend?
**Answer: NO**

**Evidence:**
Firebase is utilized **solely for client-side user authentication** (Email/Password & Phone OTP) via `firebase_auth`. It does **NOT** store market data, IPO data, news, watchlist items, PAN profiles, or chat history. No database services (Firestore / Realtime DB) are included in the project.

---

## 9. CONFIGURATION AUDIT

### Configuration Findings

1. **Custom Backend URL (`BACKEND_URL`):**
   - Configured via: `--dart-define=BACKEND_URL=https://...`
   - Default Value: `''` (empty string) in `lib/config/app_config.dart`.
   - Workspace Status: **Missing / Placeholder**. No backend URL is hardcoded or configured by default.

2. **Firebase Configuration Files:**
   - Android: `android/app/google-services.json` -> **MISSING**
   - iOS: `ios/Runner/GoogleService-Info.plist` -> **MISSING**
   - Workspace Status: **Unconfigured**. Runtime initialization (`Firebase.initializeApp()`) catches missing config gracefully and sets `firebaseReady = false`.

3. **External API Keys (`AI_API_KEY`):**
   - Configured via: `--dart-define=AI_API_KEY=...` or user entry in Settings screen (stored in `shared_preferences`).
   - Default Value: `''` (empty string).
   - Workspace Status: **Optional**. When absent, SpotAI falls back to offline rule-based financial advice and on-device IPO scoring / sentiment analysis.

4. **AdMob Configuration:**
   - Configured with official Google Test Ad Unit IDs by default (`ca-app-pub-3940256099942544/...`). Production IDs can be passed via `--dart-define=ADMOB_*`.

---

## 10. FEATURE-BY-FEATURE DATA FLOW

```text
1. INDIAN MARKET DATA FLOW
Flutter UI (MarketScreen)
   ↓
AppState
   ↓
MarketService.fetchSnapshot()
   ↓
AppConfig.backendBaseUrl configured?
   ├─► YES ──► GET /market/snapshot ──► Backend Server
   └─► NO ───► GET www.nseindia.com/api/... (NSE Cookie Handshake)
                   ↓ (If NSE blocked/fails)
               SampleData.indices() / SampleData.gainers()

2. GLOBAL MARKET DATA FLOW
Flutter UI (GlobalMarketScreen)
   ↓
AppState
   ↓
GlobalMarketService.fetchSnapshot()
   ↓
AppConfig.backendBaseUrl configured?
   ├─► YES ──► GET /global/snapshot ──► Backend Server
   └─► NO ───► GET query1.finance.yahoo.com/v8/finance/chart/... (Yahoo Finance)
                   ↓ (If Yahoo fails)
               SampleData.globalIndices() / SampleData.globalStocks()

3. IPO DATA FLOW
Flutter UI (IpoScreen)
   ↓
AppState
   ↓
IpoService.fetchIpos()
   ↓
AppConfig.backendBaseUrl configured?
   ├─► YES ──► GET /ipos ──► Backend Server
   └─► NO ───► SampleData.ipos()

4. NEWS DATA FLOW
Flutter UI (NewsScreen)
   ↓
AppState
   ↓
NewsService.fetchAll() / fetchGlobal()
   ↓
Direct RSS XML HTTP GET requests to Economic Times, Moneycontrol, Livemint, CNBC, MarketWatch
   ↓ (If all RSS feeds fail)
SampleData.news() / SampleData.globalNews()

5. PAN / ALLOTMENT DATA FLOW
Flutter UI (AllotmentScreen)
   ↓
StorageService (Encrypted FlutterSecureStorage for PAN Profiles)
   ↓
AllotmentService.checkMany()
   ↓
AppConfig.backendBaseUrl configured?
   ├─► YES ──► POST /allotment ──► Backend Server (Captcha Solver)
   └─► NO ───► In-App WebView with prefillScript (JS Auto-fill on Registrar Website)

6. SPOTAI CHAT & ANALYTICS DATA FLOW
Flutter UI (AiChatScreen)
   ↓
AiService.chat()
   ↓
ApiKey configured?
   ├─► YES ──► Gemini API / OpenAI API (HTTP POST)
   └─► NO ───► On-Device Heuristic Reply Engine (Offline Rule-Based)

7. AUTHENTICATION DATA FLOW
Flutter UI (AuthScreen)
   ↓
AuthService
   ↓
Firebase ready?
   ├─► YES ──► FirebaseAuth SDK (Email / Phone OTP)
   └─► NO ───► Automatic Guest Mode Bypass

8. USER DATA & SETTINGS FLOW
Watchlist, Dark Mode, Settings, Chat History ──► Local SharedPreferences
PAN Profiles ──────────────────────────────────► Encrypted FlutterSecureStorage

9. OFFLINE / SAMPLE FALLBACK
All services feature seamless fallback to `SampleData` when offline or when external APIs are unreachable.
```

---

## 11. SECURITY FINDINGS

1. **No Hardcoded Secrets:** Search of `lib/` and project files confirmed zero hardcoded API keys, passwords, database passwords, or JWT secrets in source code.
2. **PAN Data Security:** Sensitive PAN profiles are stored using AES encryption via `flutter_secure_storage` (`_kSecureProfiles`). Unencrypted legacy SharedPreferences keys are automatically migrated and removed on startup.
3. **HTTPS Usage:** All external API endpoints (Yahoo Finance, Gemini, OpenAI, RSS feeds) use secure `https://` transport.
4. **Log Masking:** `AuthService` handles authentication exceptions without logging raw user credentials.

---

## 12. RUNTIME VERIFICATION

```text
Runtime Verification:
NOT PERFORMED

Reason:
Flutter SDK binary (`flutter`) is not installed in the system PATH within the execution sandbox environment. Live custom backend URL (`BACKEND_URL`) is also unconfigured.
```

---

## 13. VERIFICATION LIMITATIONS

To maintain 100% precision, audit findings are classified across four distinct categories:

1. **CODE VERIFIED:** **100%**. All Dart files in `lib/`, native configurations in `android/` and `ios/`, project dependencies in `pubspec.yaml`, and workspace file structure have been fully inspected.
2. **RUNTIME VERIFIED:** **NOT PERFORMED**. Execution of `flutter test` or app runtime was not possible due to lack of `flutter` CLI in the sandbox PATH environment.
3. **LIVE INTEGRATION VERIFIED:** **NOT PERFORMED**. No live custom backend URL (`BACKEND_URL`) or live server credentials were provided or deployed.
4. **NOT VERIFIABLE:** Server-side implementation details of any external custom backend server, as no server source code exists in this workspace.

---

## 14. FINAL ARCHITECTURE DIAGRAM

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT APPLICATION                       │
│                        (c:\TCS-P\TheSpotMarket)                        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           │                         │                         │
           ▼                         ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│  EXTERNAL PUBLIC    │   │  FIREBASE AUTH      │   │  LOCAL DEVICE       │
│  APIs               │   │  (OPTIONAL)         │   │  STORAGE            │
├─────────────────────┤   ├─────────────────────┤   ├─────────────────────┤
│ • Yahoo Finance API │   │ • FirebaseAuth      │   │ • SharedPreferences │
│ • NSE India Public  │   │   (Missing Config   │   │   (Watchlist, Dark  │
│ • RSS News Feeds    │   │    file -> Runs as  │   │    Mode, Chat)      │
│ • Gemini / OpenAI   │   │    Guest Mode)      │   │ • FlutterSecure-    │
│ • Registrar Portals │   └─────────────────────┘   │   Storage (PANs)    │
└─────────────────────┘                             │ • SampleData        │
                                                    │   (Offline Fallback)│
                                                    └─────────────────────┘
```

---

## 15. FINAL CLASSIFICATION SUMMARY

```text
==================================================
THE SPOT MARKET — BACKEND ARCHITECTURE RESULT
==================================================

Flutter Frontend:
Flutter (Dart 3.x, Provider state management)

Custom Backend Source:
NO — no backend source found

Custom Backend Technology:
NOT FOUND / NOT VERIFIABLE

Custom Backend Location:
NOT FOUND IN CURRENT WORKSPACE

Database:
NOT FOUND / NOT VERIFIABLE

Firebase:
Firebase Core (v3.8.0), Firebase Auth (v5.3.3) [Auth Only]

Firebase Primary Backend:
NO

External APIs:
Yahoo Finance, NSE India, 13 Financial RSS Feeds, Google Gemini, OpenAI, 8 Registrar Portals

Custom APIs:
POST /allotment, GET /market/snapshot, GET /global/snapshot, GET /ipos (Contracts defined in client, server source missing)

Backend Source Available In Current Workspace:
NO

Backend URL Configured:
NO (Default: '')

Runtime Backend Verification:
NOT PERFORMED

Overall Architecture:
Self-contained Flutter mobile application relying on direct external public APIs, local on-device encrypted storage, and offline sample fallbacks. Includes client-side contracts for an optional custom backend (BACKEND_URL), but no server-side source code exists in this workspace.
==================================================
```

---

## 16. PHASE 3 READINESS

### Readiness Classification
**READY WITH LIMITATIONS**

### Detailed Rationale
1. **Client Codebase Readiness:** The Flutter client codebase is clean, well-structured, thoroughly audited, and fully resilient with multi-tier fallback logic (Custom Backend -> External API -> Local Sample Data).
2. **Backend Infrastructure Requirement:** If Phase 3 requires developing or deploying custom backend APIs (for scraping NSE/BSE data, aggregating IPO/GMP figures, or automated captcha solving for allotment status), **a custom backend server project must be established or connected**, as no backend source code currently exists in this workspace.

---

## FINAL AUDIT STATEMENT

```text
PHASE 3 PRE-AUDIT COMPLETE

Backend Source:
NOT FOUND IN CURRENT WORKSPACE

Backend Technology:
NOT FOUND / NOT VERIFIABLE

Firebase Role:
AUTHENTICATION ONLY (UNCONFIGURED)

Custom APIs:
CLIENT CONTRACTS FOUND / SERVER SOURCE MISSING

External APIs:
YAHOO FINANCE, NSE INDIA, RSS FEEDS, GEMINI, OPENAI

Database:
LOCAL DEVICE STORAGE ONLY (SHARED PREFERENCES & FLUTTER SECURE STORAGE)

Phase 3 Readiness:
READY WITH LIMITATIONS

Source Changes:
NONE

Phase 3:
NOT STARTED
```
