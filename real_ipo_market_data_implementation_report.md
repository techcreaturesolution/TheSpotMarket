# Real IPO & Market Data Integration Report
**Project:** TheSpotMarket (Flutter Mobile Application)  
**Date:** September 28, 2026  
**Engineer:** Senior Flutter Engineer + Financial Market Data Integration Engineer  

---

## 1. Executive Summary

This report documents the full source audit, dynamic data integration, data authenticity enforcement, and test verification for **TheSpotMarket** Flutter app. Hardcoded static `SampleData` for Open IPOs, Upcoming IPOs, Top Gainers, and Top Losers has been audited and integrated with real-data flows, strict date filtering, status labeling, deduplication, and zero-false-LIVE badge protection.

---

## 2. Current Source Before & After Changes

| Section | Source Before Changes | Data Source After Implementation | Status Labeling |
|---|---|---|---|
| **Top Gainers** | Hardcoded `SampleData.gainers()` list when direct API calls failed or were unconfigured | Derived dynamically from real NIFTY 50 quotes (`pChange` sorted descending) when NSE/backend succeeds. | `LIVE` when real NIFTY 50 quotes arrive; `DEMO DATA` on fallback. |
| **Top Losers** | Hardcoded `SampleData.losers()` list when direct API calls failed or were unconfigured | Derived dynamically from real NIFTY 50 quotes (`pChange` sorted ascending) when NSE/backend succeeds. | `LIVE` when real NIFTY 50 quotes arrive; `DEMO DATA` on fallback. |
| **Open IPOs** | Hardcoded `SampleData.ipos()` list | Fetched from backend (`BACKEND_URL/ipos`) or live NSE public API (`/api/ipo-current-issue`). Enforces status `currentDate >= openDate && currentDate <= closeDate`. | `LIVE` when real API succeeds; `DEMO DATA` on sample fallback. |
| **Upcoming IPOs** | Hardcoded `SampleData.ipos()` list | Fetched from backend (`BACKEND_URL/ipos`) or live NSE public API (`/api/all-upcoming-issues?category=ipo`). Enforces status `openDate > currentDate`. Sorted by nearest `openDate` ascending. | `LIVE` when real API succeeds; `DEMO DATA` on sample fallback. |

---

## 3. Exact Files Modified

1. [lib/services/market_service.dart](file:///c:/TCS-P/TheSpotMarket/lib/services/market_service.dart)
   - Dynamic Top Gainers calculation: sorts valid quotes by `changePct` descending.
   - Dynamic Top Losers calculation: sorts valid quotes by `changePct` ascending.
   - Throws explicit exception on malformed/empty response to trigger fallback cleanly.
   - Added debug logging `[MARKET_DATA]` in `kDebugMode`.

2. [lib/services/ipo_service.dart](file:///c:/TCS-P/TheSpotMarket/lib/services/ipo_service.dart)
   - Updated `IpoFeed` container with `fetchedAt` and `source` (`MarketDataSource`).
   - Removed fake GMP calculation (`gmp: null` for direct NSE endpoints).
   - Added strict date validation (`openDate <= closeDate`).
   - Deduplicated IPO records by `id`/`symbol`.
   - Sorted upcoming IPOs by nearest `openDate` ascending.
   - Added debug logging `[IPO_DATA]` in `kDebugMode`.

3. [lib/providers/app_state.dart](file:///c:/TCS-P/TheSpotMarket/lib/providers/app_state.dart)
   - Added getters for `ipoFetchedAt` and `ipoSource`.
   - Initialized `_profiles` as a growable list to prevent `UnmodifiableListMixin` exceptions.
   - Throttled IPO and News fetches to at most once every 60 seconds during 1s auto-refresh ticks (`refreshAllSilently`), protecting network bandwidth and API rate limits while allowing rapid 1s market quote ticks.

4. [lib/screens/market_screen.dart](file:///c:/TCS-P/TheSpotMarket/lib/screens/market_screen.dart)
   - Removed unused widget `_Mini` to satisfy strict static analysis.

5. [test/core_test.dart](file:///c:/TCS-P/TheSpotMarket/test/core_test.dart)
   - Updated test imports (`AppConfig`) and test assertions to match hardened `IpoService` and `AppState` behaviors.

---

## 4. API & Data Source Details

### Top Gainers & Top Losers API
- **Endpoint:** `https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050`
- **Method:** `HTTP GET`
- **Headers:** User-Agent (Chrome/124), Accept (`application/json`), Referer (`https://www.nseindia.com/`), Cookie (obtained via initial handshake `https://www.nseindia.com/`).
- **Update Frequency:** Real-time / 1-second ticker in app state.
- **Top Gainers Mapping:** `quotes.where(valid).sort((a,b) => b.changePct.compareTo(a.changePct)).take(5)`
- **Top Losers Mapping:** `quotes.where(valid).sort((a,b) => a.changePct.compareTo(b.changePct)).take(5)`

### IPO Data Source
- **Endpoints:**
  - Backend: `${AppConfig.backendBaseUrl}/ipos`
  - Direct NSE: `https://www.nseindia.com/api/ipo-current-issue` and `https://www.nseindia.com/api/all-upcoming-issues?category=ipo`
- **Update Frequency:** Throttled to 60-second intervals or on manual pull-to-refresh / screen open.
- **Open IPO Mapping:** `currentDate >= openDate && currentDate <= closeDate`
- **Upcoming IPO Mapping:** `openDate > currentDate`, sorted by nearest `openDate` ascending.

---

## 5. Live vs Demo Status & Zero False-LIVE Guarantee

- **Real API Success:** `isLive = true`, `source = MarketDataSource.nse` / `MarketDataSource.backend`. UI displays **LIVE** badge (Emerald Green dot).
- **Static Sample Fallback:** `isLive = false`, `source = MarketDataSource.sampleFallback`. UI displays **DEMO DATA** (Slate Gray badge).
- **Rule Enforced:** The app **NEVER** displays "LIVE" when data comes from hardcoded `SampleData`, failed API calls, or static fallbacks.

---

## 6. Verification & Test Results

### A. Static Analysis (`flutter analyze`)
```text
Analyzing TheSpotMarket...
No issues found! (ran in 3.0s)
```
- **Status:** **PASS (0 errors, 0 warnings)**

### B. Automated Unit Tests (`flutter test`)
```text
00:00 +36: All tests passed!
```
- **Status:** **PASS (36 / 36 tests passed)**

---

## 7. Categorized Integrity Statements

- **SOURCE-CODE VERIFIED:**
  - Top Gainers and Top Losers math derives dynamically from parsed NIFTY 50 quotes when live endpoint succeeds.
  - Date filtering (`openDate` vs `closeDate` vs `currentDate`) correctly classifies Open and Upcoming IPOs.
  - Nearest upcoming start date sorting puts upcoming IPO opening tomorrow ahead of next week.
  - Fake GMP generation removed from NSE parser.
  - 1s auto-refresh throttles IPO and News fetches to 60s intervals.

- **RUNTIME VERIFIED:**
  - `flutter analyze` executed with zero errors.
  - `flutter test` executed with 36/36 passing unit tests.

- **NOT VERIFIED (Real Data Source Requirement for Unofficial GMP):**
  - Direct public exchange APIs (NSE/BSE) do not publish informal Grey Market Premium (GMP). If real GMP or subscription breakdown is required in production, a dedicated licensed market-data provider or custom scraping backend must be configured via `BACKEND_URL`.
