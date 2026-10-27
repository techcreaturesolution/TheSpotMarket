# FINAL RECOMMENDED FIXES — THE SPOT MARKET (PHASE 0 → PHASE 6)

## 1. OVERVIEW
This document details recommendations and potential improvements identified during the Master Audit of **TheSpotMarket** (Phase 0 to Phase 6). In accordance with audit constraints, no source code was modified during this audit.

---

## 2. AUDIT OBSERVATIONS & RECOMMENDATIONS

### Item 1: RSS Feed URL Updates
- **Category:** Recommended for maintainability
- **Severity:** LOW
- **Affected File:** [`lib/services/news_service.dart`](file:///C:/TCS-P/TheSpotMarket/lib/services/news_service.dart)
- **Evidence:** 5 out of 13 RSS publisher feeds (e.g., Moneycontrol RSS) return HTTP 403 or 404 errors due to updated publisher RSS endpoints. `NewsService` isolates feed failures gracefully, so remaining live feeds and fallback sample news continue functioning.
- **Recommended Fix:** Update the RSS feed URLs in `NewsService.defaultFeeds` to match current publisher XML endpoints.
- **Risk of Fixing:** Low risk.

---

### Item 2: Backend & Proxy URL Configuration for Live NSE Requests
- **Category:** Recommended for reliability
- **Severity:** MEDIUM
- **Affected File:** [`lib/config/app_config.dart`](file:///C:/TCS-P/TheSpotMarket/lib/config/app_config.dart), [`lib/services/market_service.dart`](file:///C:/TCS-P/TheSpotMarket/lib/services/market_service.dart)
- **Evidence:** Direct client HTTP GET requests to `nseindia.com` trigger Akamai WAF 403 blocks on mobile user-agents. The app safely falls back to `SampleData`.
- **Recommended Fix:** Set `AppConfig.backendBaseUrl` to a production API proxy server that performs server-side cookie handshakes and caching for NSE market data.
- **Risk of Fixing:** Zero risk to Flutter app; backend deployment required.

---

### Item 3: iOS Firebase Native Configuration File (Optional for iOS builds)
- **Category:** Recommended for iOS release
- **Severity:** INFORMATIONAL
- **Affected File:** `ios/Runner/GoogleService-Info.plist`
- **Evidence:** `android/app/google-services.json` is already PRESENT and ACTIVE in `android/app/` (`project_id: thespotmarket-dfee1`). Android authentication (Email & Mobile Phone OTP) is fully supported. If compiling for native iOS targets, `GoogleService-Info.plist` must be placed in `ios/Runner/`.
- **Recommended Fix:** Download `GoogleService-Info.plist` from Firebase Console for project `thespotmarket-dfee1` and place in `ios/Runner/` if iOS build compilation is needed.
- **Risk of Fixing:** Zero code risk.

---

### Item 4: Environment Variable Injection for SpotAI API Key
- **Category:** Optional improvement
- **Severity:** INFORMATIONAL
- **Affected File:** [`lib/services/ai_service.dart`](file:///C:/TCS-P/TheSpotMarket/lib/services/ai_service.dart)
- **Evidence:** `AiService` uses offline rule-based heuristics (`scoreIpo`, `suggestStocks`, `marketMood`) when `AI_API_KEY` is empty.
- **Recommended Fix:** Pass `--dart-define=AI_API_KEY=your_key` during build to enable live cloud Gemini API integration.
- **Risk of Fixing:** Zero code risk.

---

## 3. SUMMARY TABLE

| Item | Category | Severity | File Affected | Recommended Action |
|------|----------|----------|---------------|-------------------|
| RSS Feed URL Updates | Maintainability | LOW | `lib/services/news_service.dart` | Update 5 outdated RSS feed publisher URLs |
| Backend Proxy Setup | Reliability | MEDIUM | `lib/config/app_config.dart` | Set `backendBaseUrl` for proxying NSE live feed |
| iOS Firebase File | iOS Release | INFO | `ios/Runner/` | Place `GoogleService-Info.plist` if iOS build needed |
| SpotAI API Key | Optional improvement | INFO | `lib/services/ai_service.dart` | Pass `AI_API_KEY` via `--dart-define` |
