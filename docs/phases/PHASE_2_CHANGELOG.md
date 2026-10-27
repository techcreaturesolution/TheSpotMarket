# Phase 2 Changelog — API / Data Layer & Network Reliability

## 1. Baseline Summary
- **Flutter / Dart Version**: Flutter 3.41.6 (channel stable), Dart 3.11.4
- **Analyzer Status**: 0 errors, 0 warnings, 0 infos (`dart analyze` 100% clean)
- **Unit Test Count**: 12 passed / 12 total (100% pass rate in `flutter test`)

---

## 2. Network & Data Layer Changes

### 1. In-Flight Request Deduplication
- **File**: `lib/providers/app_state.dart`
- **Change**: Added re-entry loading guards (`{bool force = false}`) to `loadMarket()`, `loadIpos()`, `loadNews()`, and `loadGlobal()`. Updated `refreshAll()` to pass `force: true`.
- **Reason**: Prevents duplicate simultaneous network calls triggered by rapid tab switching, screen rebuilds, or re-entry while data requests are already in-flight.
- **Risk Level**: Low.
- **Behavior Preserved**: Manual pull-to-refresh indicators (`refreshAll()`) force full reload as expected.

### 2. Model JSON Parsing Hardening
- **File**: `lib/models/models.dart`
- **Change**: Added robust numeric parsing helper functions (`_numToDouble`, `_numToNullableDouble`, `_numToInt`, `_numToNullableInt`) and `DateTime.tryParse` handling in `Ipo.fromJson`, `MarketIndex.fromJson`, `MarketIndex.fromNse`, `StockQuote.fromJson`, and `StockQuote.fromNse`.
- **Reason**: Guarantees that stringified numbers, missing fields, null values, or type variations in API responses never throw uncaught runtime `TypeError` exceptions.
- **Risk Level**: Low.
- **Behavior Preserved**: Existing domain getters and calculations continue operating cleanly.

### 3. RSS Feed XML Deserialization Resilience
- **File**: `lib/services/news_service.dart`
- **Change**: Wrapped `NewsService.parseRss` in a `try / catch` block and ensured per-publisher isolation in `_fetchFeed`.
- **Reason**: Ensures that if an individual RSS publisher returns malformed XML, an HTML 503/404 page, or fails network connection, the parser cleanly returns an empty list for that single feed without crashing or disrupting remaining news publishers.
- **Risk Level**: Low.
- **Behavior Preserved**: Article deduplication, categorization, and sorting across publishers remain fully functional.

### 4. Automated Unit Test Additions
- **File**: `test/core_test.dart`
- **Change**: Added unit test cases for:
  - `handles malformed or incomplete JSON gracefully in models`
  - `handles malformed XML in RSS parsing without throwing`
- **Reason**: Provides regression protection and automated validation for parser hardening.
- **Risk Level**: Zero.
- **Behavior Preserved**: All 12 unit tests pass cleanly.

---

## 3. API & Reliability Strategy Clarifications

- **Timeout Behavior**: Explicit timeouts verified per service (10s on backend market, 12s on backend IPOs, 12s on backend global, 60s on backend allotment, 8s cookie / 10s JSON on NSE, 10s on Yahoo Finance, 10s on RSS feeds, 30s on SpotAI).
- **HTTP Error Handling**: Generic non-success HTTP responses (`statusCode != 200`) are caught and routed through the existing error/fallback pathways without individual status-code specific handlers.
- **Retry Strategy**: **NOT IMPLEMENTED / NOT APPLICABLE**. The network layer executes zero automated request retries or exponential backoffs. Failed requests fall back directly to bundled `SampleData` or offline heuristic fallbacks.
- **Caching Audit**: **NOT IMPLEMENTED / NOT APPLICABLE for network responses**. `SharedPreferences` and `FlutterSecureStorage` persist local application state (PAN profiles, watchlist, dark mode, chat history), NOT network API responses.
- **Duplicate Request Deduplication**: In-flight loading flags in `AppState` prevent redundant concurrent calls during UI rebuilds.

---

## 4. Files Modified

| File Path | Component | Description of Change | Risk Level |
| --- | --- | --- | --- |
| [app_state.dart](file:///c:/TCS-P/TheSpotMarket/lib/providers/app_state.dart) | Providers | Added request deduplication re-entry guards to data loading methods | Low |
| [models.dart](file:///c:/TCS-P/TheSpotMarket/lib/models/models.dart) | Models | Added robust numeric and date parsing helpers to JSON deserializers | Low |
| [news_service.dart](file:///c:/TCS-P/TheSpotMarket/lib/services/news_service.dart) | Services | Hardened RSS XML parser with exception handling for broken/HTML feeds | Low |
| [core_test.dart](file:///c:/TCS-P/TheSpotMarket/test/core_test.dart) | Tests | Added model JSON parser hardening and RSS XML error resilience tests | Low |

---

## 5. Files Intentionally Not Modified
- Backend API endpoints / backend codebase (0 backend modifications made).
- Database schemas / models structure.
- State management framework (Provider architecture preserved 100%).
- App UI design and layout structure.

---

## 6. Known External Limitations & Verification Gaps
- **NSE India API**: Direct non-browser curl requests encounter Akamai 403 WAF restrictions; `MarketService` falls back to `SampleData` as designed.
- **RSS News Feeds**: Live probe verified 8 of 13 feeds operational (Economic Times, Livemint, Investing.com, Yahoo Finance US, MarketWatch, Bloomberg); 5 feeds are currently unreachable, returning 403, 404, or malformed HTML.
- **Runtime Smoke Test**: **NOT PERFORMED**. The project repository contains `android` and `ios` platform targets; `windows` and `web` platform folders are not configured in this codebase.
- **Backend / Firebase / SpotAI API / AdMob**: Infrastructure code verified; live network calls depend on external configuration files/keys absent from the workspace.

