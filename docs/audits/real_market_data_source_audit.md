# Source-Code & Data-Flow Audit: Market Data & IPO Sections
**Project:** TheSpotMarket (Flutter Mobile Application)  
**Date:** September 28, 2026  
**Auditor:** Senior Flutter Engineer + Financial Market Data Integration Engineer  

---

## 1. Executive Summary

This document presents a comprehensive Phase 1 & Phase 2 audit of the current market and IPO data architecture within **TheSpotMarket**. It outlines the exact widgets, state providers, service classes, API endpoints, error handling, static fallbacks, and live/demo status indicators.

---

## 2. Phase 2: Source Matrix

| Feature | UI Widget | Provider | Service | Current API Endpoint | Actual Source at Runtime | Fallback | Live? |
|---|---|---|---|---|---|---|---|
| **Open IPOs** | `DashboardScreen` (`open.take(3)`), `IpoListScreen` (Tab 1), `IpoCard` | `AppState` (`lib/providers/app_state.dart:153-178`) | `IpoService` (`lib/services/ipo_service.dart`) | 1. `BACKEND_URL/ipos`<br>2. `https://www.nseindia.com/api/ipo-current-issue` | `SampleData.ipos()` when direct NSE fails/blocked | Static `SampleData.ipos()` (`lib/services/sample_data.dart:13`) | `isLive: false` (displays `DEMO DATA`) |
| **Upcoming IPOs** | `DashboardScreen` (`_UpcomingTile`), `IpoListScreen` (Tab 2), `IpoCard` | `AppState` (`lib/providers/app_state.dart:153-178`) | `IpoService` (`lib/services/ipo_service.dart`) | 1. `BACKEND_URL/ipos`<br>2. `https://www.nseindia.com/api/all-upcoming-issues?category=ipo` | `SampleData.ipos()` when direct NSE fails/blocked | Static `SampleData.ipos()` (`lib/services/sample_data.dart:13`) | `isLive: false` (displays `DEMO DATA`) |
| **Top Gainers** | `DashboardScreen` (`s.snapshot!.gainers`), `MarketScreen` (`StockTile`) | `AppState` (`lib/providers/app_state.dart:120-146`) | `MarketService` (`lib/services/market_service.dart`) | 1. `BACKEND_URL/market/snapshot`<br>2. `https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050` | Real NIFTY 50 quotes when NSE succeeds; `SampleData.gainers()` when NSE blocked | Static `SampleData.gainers()` (`lib/services/sample_data.dart:240`) | `isLive: true` when NSE succeeds; `isLive: false` on fallback |
| **Top Losers** | `DashboardScreen` (`s.snapshot!.losers`), `MarketScreen` (`StockTile`) | `AppState` (`lib/providers/app_state.dart:120-146`) | `MarketService` (`lib/services/market_service.dart`) | 1. `BACKEND_URL/market/snapshot`<br>2. `https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050` | Real NIFTY 50 quotes when NSE succeeds; `SampleData.losers()` when NSE blocked | Static `SampleData.losers()` (`lib/services/sample_data.dart:260`) | `isLive: true` when NSE succeeds; `isLive: false` on fallback |

---

## 3. Comprehensive Technical Findings (Phase 1 Audit)

### A. Screen & Widget Mapping
1. **Open IPOs:**
   - [DashboardScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/home_screen.dart#L135-L149): Displays top 3 open IPOs.
   - [IpoListScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/ipo_screens.dart#L44): Tab index 1 filters `iposWhere(IpoStatus.open)`.
   - [IpoCard](file:///c:/TCS-P/TheSpotMarket/lib/screens/ipo_screens.dart#L103-L247): Renders company name, SME tag, sector, price band, lot size, issue size, listing date, total subscription, GMP, and AI score.
2. **Upcoming IPOs:**
   - [DashboardScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/home_screen.dart#L150-L162): Displays `_UpcomingTile` in horizontal list.
   - [IpoListScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/ipo_screens.dart#L45): Tab index 2 filters `iposWhere(IpoStatus.upcoming)`.
3. **Top Gainers:**
   - [DashboardScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/home_screen.dart#L164-L170): Displays top 3 gainers via `StockTile`.
   - [MarketScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/market_screen.dart#L66): Displays full list of gainers.
4. **Top Losers:**
   - [DashboardScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/home_screen.dart#L171-L176): Displays top 3 losers via `StockTile`.
   - [MarketScreen](file:///c:/TCS-P/TheSpotMarket/lib/screens/market_screen.dart): Displays full list of losers.

### B. Data Controllers & Providers
- **State Manager:** [AppState](file:///c:/TCS-P/TheSpotMarket/lib/providers/app_state.dart#L14) (ChangeNotifier, accessed via Provider).
- **Services:**
  - [MarketService](file:///c:/TCS-P/TheSpotMarket/lib/services/market_service.dart#L33): Fetches indices, gainers, losers.
  - [IpoService](file:///c:/TCS-P/TheSpotMarket/lib/services/ipo_service.dart#L21): Fetches open & upcoming IPOs.

### C. API Endpoints, HTTP Methods & Auth
1. **Market Endpoints (`MarketService`):**
   - Method: `HTTP GET`
   - Custom Backend: `${AppConfig.backendBaseUrl}/market/snapshot`
   - Direct Public NSE endpoints:
     - `https://www.nseindia.com/` (Handshake for `set-cookie`)
     - `https://www.nseindia.com/api/allIndices`
     - `https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050`
   - Headers: User-Agent Chrome/124, Accept application/json, Referer `https://www.nseindia.com/`, and `Cookie: _nseCookie`.
2. **IPO Endpoints (`IpoService`):**
   - Method: `HTTP GET`
   - Custom Backend: `${AppConfig.backendBaseUrl}/ipos`
   - Direct Public NSE endpoints:
     - `https://www.nseindia.com/api/ipo-current-issue`
     - `https://www.nseindia.com/api/all-upcoming-issues?category=ipo`
   - Headers: Same NSE session cookie headers.

### D. Network Failures & Fallback Behavior
- On HTTP 403, 429, 404, timeout, or malformed JSON:
  - Exception is caught silently.
  - Services fallback to static sample data (`SampleData.ipos()`, `SampleData.gainers()`, `SampleData.losers()`).
  - Flag `isLive` is set to `false` and `source` is set to `MarketDataSource.sampleFallback`.
  - UI `LiveDot` displays **DEMO DATA** (slate-gray chip), preventing false "LIVE" claims.

---

## 4. Immediate Architectural Recommendations & Integration Action Plan

1. **Top Gainers / Losers (Phase 3):**
   - When direct NSE call succeeds, `MarketService._fromNse()` fetches NIFTY 50 equity list (`/api/equity-stockIndices?index=NIFTY%2050`).
   - Derive Top Gainers dynamically by sorting `quotes` by `changePct` descending.
   - Derive Top Losers dynamically by sorting `quotes` by `changePct` ascending.
   - Perform strict validation: filter invalid symbols, negative prices, NaN/Infinity percentages.

2. **Open & Upcoming IPO Status Enforcement (Phase 4 & 5):**
   - Open IPOs must satisfy: `currentDate >= openDate && currentDate <= closeDate`.
   - Upcoming IPOs must satisfy: `openDate > currentDate`, sorted by `openDate` ascending (nearest upcoming first).
   - Deduplicate records by `symbol` or `id`.

3. **Data Integrity & Labeling (Phase 9 - 13):**
   - Never claim data is `LIVE` when using sample or static fallback data.
   - Preserve `isLive: false` and `MarketDataSource.sampleFallback` when APIs fail.
   - Retain authentic data fields (price, dates, lot size, issue size, exchange, subscription numbers).
