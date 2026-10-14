# PHASE 5 CHANGELOG — INDIAN MARKET DATA, NSE RELIABILITY & PERFORMANCE HARDENING

## 1. Files Changed

### `lib/models/models.dart`
- **Reason**: Harden numeric helpers (`_numToDouble`, `_numToNullableDouble`, `_numToInt`, `_numToNullableInt`) to parse numeric strings containing formatting commas (e.g. `"24,812.35"` or `"8,120,000"`) and sanitize `NaN`/`Infinity` float states. Harden `StockQuote.fromNse` by replacing unchecked `j['meta'] as Map<String, dynamic>?` casts with safe runtime type checks (`j['meta'] is Map`) to prevent `TypeError` crashes on unexpected API response shapes.
- **Behavior Preserved**: Domain model properties, data types, calculations (`isUp`, `change`, `changePct`), and default fallbacks.
- **Performance Changes**: Zero allocation overhead; fast regex-free comma removal and safety guards.

### `lib/services/market_service.dart`
- **Reason**: Remove unsafe `as List` and `.cast<Map<String, dynamic>>()` calls in `_fromBackend()`, `_fromNse()`, and `_quotes()`. Replace sequential await calls for independent NSE endpoints (`/api/allIndices` and `/api/equity-stockIndices?index=NIFTY%2050`) with concurrent `Future.wait` after cookie handshake. Optimize `_trackedIndices` sort comparator by using static positional lookup map instead of recreating a `List` on every comparator invocation.
- **Behavior Preserved**: Strict order of data sources (`Backend` -> `NSE` -> `SampleData`), index tracking, gainers/losers count, and timestamp creation.
- **Performance Changes**: Reduced network latency for live NSE fetches by parallelizing independent endpoint requests; eliminated redundant memory allocations during list sorting.

### `lib/providers/app_state.dart`
- **Reason**: Update `loadMarket({bool force = false})` to assign fetched snapshot state only upon successful fetch, ensuring existing market snapshot data is preserved on refresh errors instead of clearing the UI.
- **Behavior Preserved**: Provider listener notifications, loading flag management in `finally` block, deduplication logic, and `refreshAll()` functionality.

### `test/core_test.dart`
- **Reason**: Added comprehensive test suite (`Phase 5 — Indian Market & NSE Reliability Hardening`) validating defensive parsing of formatted numbers, malformed meta structures, NSE 403 Akamai block fallback, malformed JSON fallback, and AppState lifecycle state transitions.
- **Behavior Preserved**: All existing Phase 0-4 unit tests remain 100% passing.

---

## 2. Summary of Tests Added
1. `parses formatted numeric strings with commas and handles NaN/Infinity`
2. `handles null, missing, or unexpected meta field structure in NSE stock quotes`
3. `falls back to SampleData on NSE 403 Akamai block`
4. `falls back to SampleData on malformed JSON response`
5. `AppState loadMarket maintains state lifecycle and preserves snapshot on exception`
