# Phase 4 — Global Market Data, API Reliability & Performance Hardening Report

## 1. Phase Objective
Harden and optimize the International Market functionality of **TheSpotMarket**, improving network query throughput, defensive JSON parsing, Provider loading resilience, error state management, and fallback reliability without altering existing UI design, business logic, or backend/auth architecture.

---

## 2. Audit Findings
- **Sequential Network Latency:** Previously, `GlobalMarketService._fromYahoo()` executed sequential `Future.wait` calls: first awaiting 12 global index queries, then awaiting 12 global stock queries.
- **Strict Cast Vulnerabilities:** Yahoo Finance chart endpoints occasionally return malformed JSON, empty arrays, or string numbers (`"220.50"`). Direct `as Map<String, dynamic>` and `as double` casts posed potential `TypeError` risks.
- **State Lifecycle Risk:** In `AppState.loadGlobal()`, async operations lacked a `finally` block, risking stuck loading flags if an unhandled exception occurred during network fetch.

---

## 3. Global Market Architecture
- **Architecture:** Client-side service layer (`GlobalMarketService`) consumed by state manager (`AppState`), providing global market indices, international stock quotes, world news feeds, and AI market mood metrics to `GlobalMarketScreen`.
- **State Management:** Preserved original Provider (`provider: ^6.1.2`) architecture.

---

## 4. API / Data Flow
```text
GlobalMarketScreen / AppState.loadGlobal()
   ↓
GlobalMarketService.fetchSnapshot()
   ↓
1. BACKEND CHECK (AppConfig.backendBaseUrl configured?)
   ├─► YES ──► GET {BACKEND_URL}/global/snapshot
   └─► NO ───► 2. YAHOO FINANCE (query1.finance.yahoo.com/v8/finance/chart/...)
                   Concurrent parallel fetch for 12 Indices + 12 Stocks
                   ↓ (If Yahoo Finance fails or returns empty)
               3. SAMPLE DATA FALLBACK (SampleData.globalIndices() & SampleData.globalStocks())
   ↓
GlobalSnapshot ──► AppState ──► GlobalMarketScreen UI
```

---

## 5. Yahoo Finance Handling
- **Concurrent Execution:** Index and stock symbol queries execute simultaneously using nested `Future.wait`.
- **Type-Safe Extraction:** Safely extracts nested maps (`chart`, `result[0]`, `meta`, `indicators`, `quote[0]`) with explicit runtime type checks (`is Map<String, dynamic>`, `is List`).
- **Robust Numeric Parsing:** Uses helper functions (`_numToNullableDouble`, `_numToNullableInt`) to parse numeric fields returned as `num`, `String`, or `null`.
- **Sparkline & Null Filtering:** Safely filters out `null` price points from Yahoo chart historical arrays (`close`).

---

## 6. Provider / State Improvements
- **Loading State Guard:** `AppState.loadGlobal()` now executes in a `try-catch-finally` block. `_globalLoading` is guaranteed to reset to `false` in `finally`.
- **Concurrency Guard:** Re-entrance guard `if (_globalLoading && !force) return;` prevents duplicate parallel refresh triggers.
- **Previous Snapshot Preservation:** If a refresh attempt fails, previous successful data (`_globalSnapshot`) is retained rather than cleared.

---

## 7. Error Handling
- **Graceful Exception Catching:** Errors during network fetch are caught without exposing raw stack traces or breaking the UI widget tree.
- **Error State Tracking:** `_globalError` captures exception strings for diagnostic inspection while keeping the UI functional.

---

## 8. Fallback Behavior
- **Multi-Tier Fallback Intact:**
  1. Custom Backend (if `BACKEND_URL` is set)
  2. Yahoo Finance Public Chart API
  3. Bundled `SampleData`
- **Fallback Transparency:** When running on sample data, UI displays: *"Showing sample data – live global feed unreachable. Configure BACKEND_URL for a reliable feed."*

---

## 9. Performance Improvements
- **Parallel Query Execution:** Reduced network wait time by querying global indices and global stocks in parallel rather than sequentially.
- **Minimized UI Rebuilds:** Guarded notifyListeners calls prevent unnecessary widget re-renders when data has not changed.

---

## 10. Tests
Added new unit test suite `GlobalMarketService & Hardened Global Data Flow` in `test/core_test.dart`:
1. `fetches fallback snapshot safely when live endpoints fail or backend is unconfigured`
2. `AppState loadGlobal manages globalLoading and loads snapshot without throwing`

---

## 11. flutter analyze Result
**NOT VERIFIABLE** (Flutter CLI binary is not present in terminal sandbox environment PATH).

---

## 12. flutter test Result
**NOT VERIFIABLE** (Flutter CLI binary is not present in terminal sandbox environment PATH).

---

## 13. Runtime Verification Result
**NOT VERIFIABLE** (Native device/emulator execution unavailable in terminal sandbox environment).

---

## 14. Remaining Limitations
- Terminal execution of `flutter analyze` and `flutter test` could not be run directly due to sandbox PATH environment settings (`flutter` CLI not found).
- Live network response validation against Yahoo Finance API is subject to external network availability and rate limits.

---

## 15. Files Changed
1. [`lib/services/global_market_service.dart`](file:///c:/TCS-P/TheSpotMarket/lib/services/global_market_service.dart)
2. [`lib/providers/app_state.dart`](file:///c:/TCS-P/TheSpotMarket/lib/providers/app_state.dart)
3. [`test/core_test.dart`](file:///c:/TCS-P/TheSpotMarket/test/core_test.dart)
4. [`PHASE_4_CHANGELOG.md`](file:///c:/TCS-P/TheSpotMarket/PHASE_4_CHANGELOG.md)
5. [`PHASE_4_REPORT.md`](file:///c:/TCS-P/TheSpotMarket/PHASE_4_REPORT.md)

---

## 16. Final Phase Status
**COMPLETE WITH VERIFICATION LIMITATIONS**
