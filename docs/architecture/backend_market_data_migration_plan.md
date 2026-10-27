# Backend Market Data Migration Plan

## 1. Current Architecture
Currently, the Flutter app fetches market data and IPO data by directly calling NSE India's public endpoints (`/api/equity-stockIndices`, `/api/ipo-current-issue`, etc.). It negotiates a session cookie and hits endpoints on a 1-second interval, attempting to act as a web browser.

## 2. Confirmed NSE 403 Problem
The direct NSE mobile fetch fails with `HTTP 403 / Handshake Error`. This occurs because NSE's Web Application Firewall (WAF) aggressively blocks non-browser User-Agents, non-whitelisted IPs, and requests missing proper TLS fingerprints or Referrer headers. Repeated 1-second polling exacerbates this issue.

## 3. Current Yahoo Limitation
When the NSE fetch fails, the app falls back to Yahoo Finance. However, Yahoo is only queried for indices (NIFTY 50, SENSEX), but **not individual stock quotes**. This results in incomplete data.

## 4. Current SampleData Fallback
Because the Yahoo fallback lacks actual stock quotes, the `MarketService` explicitly fills the Top Gainers and Top Losers with `SampleData`. The `isLive` flag is set to `false`, causing the UI to show the `DEMO DATA` badge.

## 5. Proposed Backend Contract
The Flutter app will stop querying NSE directly. Instead, it will fetch aggregated data from a lightweight backend proxy (configured via `AppConfig.backendBaseUrl`).

### 6. Market Snapshot JSON Schema
**Endpoint:** `GET /market/snapshot`
**Response:**
```json
{
  "source": "backend",
  "timestamp": "2026-09-29T11:50:00Z",
  "indices": [
    {
      "name": "NIFTY 50",
      "exchange": "NSE",
      "last": 24500.00,
      "change": 150.50,
      "changePct": 0.62
    }
  ],
  "gainers": [
    {
      "symbol": "INFY",
      "name": "Infosys",
      "lastPrice": 1892.40,
      "change": 61.10,
      "changePct": 3.34,
      "volume": 1234567
    }
  ],
  "losers": [...]
}
```

### 7. IPO JSON Schema
**Endpoints:** `GET /ipos/current` and `GET /ipos/upcoming`
**Response:**
```json
{
  "source": "backend",
  "timestamp": "2026-09-29T11:50:00Z",
  "ipos": [
    {
      "id": "bajaj-housing",
      "name": "Bajaj Housing Finance",
      "symbol": "BAJAJHFL",
      "exchange": "NSE, BSE",
      "sector": "Financials",
      "openDate": "2026-09-09T00:00:00Z",
      "closeDate": "2026-09-11T00:00:00Z",
      "priceMin": 66.0,
      "priceMax": 70.0,
      "lotSize": 214,
      "issueSizeCr": 6560.0,
      "subscriptionQib": 10.5,
      "subscriptionNii": 5.2,
      "subscriptionRetail": 2.1
    }
  ]
}
```
*Note: GMP, Listing Dates, and lot sizes are ONLY provided if actually available from the source. No fake/derived data.*

## 8. Caching Strategy
1. **Backend Cache:** The backend fetches from NSE/Providers and caches the data in Redis or Memory (e.g., TTL = 30 seconds).
2. **Client Throttling:** The Flutter app requests data from the backend every 10-15 seconds. The 1-second UI timer simply re-renders the cached UI state without creating network calls.

## 9. Flutter Changes Required (Implemented)
- Added a 10-second throttle to `AppState.refreshAllSilently()` for market fetches.
- Updated `MarketService` to parse `gainers` and `losers` directly from the backend JSON, sorting them by `changePct`, and taking the top 5 without using `SampleData`.
- Blocked NSE retries if a 403 or handshake error is detected during the session to avoid spamming the upstream server.
- Fixed logging to accurately represent `BACKEND_SUCCESS`, `BACKEND_HTTP_ERROR`, etc.
- Yahoo fallback accurately retains `isLive = false` since stock quotes are demo data.

## 10. Backend Changes Required
- Create a Node.js/Python backend that polls the market provider periodically.
- Expose the endpoints `/market/snapshot`, `/ipos/current`, and `/ipos/upcoming`.
- Ensure the backend properly normalizes the provider's API structure to match the schemas above.

## 11. Error States
- `BACKEND_NOT_CONFIGURED`: The `BACKEND_URL` environment variable is empty.
- `BACKEND_SUCCESS`: 200 OK.
- `BACKEND_HTTP_ERROR`: Non-200 responses.
- `BACKEND_TIMEOUT`: The backend takes more than 10 seconds to respond.
- `BACKEND_NETWORK_ERROR`: Connectivity issues on the mobile device.
- `BACKEND_PARSE_ERROR`: The backend returned malformed JSON.
- `SAMPLE_FALLBACK`: Total failure, forcing the app to show Demo Data.

## 12. Security Considerations
- The backend should implement rate-limiting by IP to prevent abuse.
- The Flutter app must **never** log or transmit auth tokens, API keys, or cookies.

## 13. Performance Considerations
- Throttling network requests in `AppState` prevents unnecessary HTTP overhead, battery drain, and CPU spikes on the mobile device.
- The 1-second timer strictly limits its work to memory-based state changes and UI redraws.

## 14. Testing Plan
1. **No Backend (Default):** Run the app. Verify logs show `BACKEND_NOT_CONFIGURED` and the UI shows `DEMO DATA`.
2. **With Backend:** Launch with `flutter run --dart-define=BACKEND_URL=https://mock.api`. Verify logs show `provider=BACKEND status=200 live_result=true` and the UI shows `LIVE` without `DEMO DATA`.
