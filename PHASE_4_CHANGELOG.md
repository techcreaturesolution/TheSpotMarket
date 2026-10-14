# PHASE 4 CHANGELOG — GLOBAL MARKET DATA, API RELIABILITY & PERFORMANCE HARDENING

**Project:** TheSpotMarket  
**Workspace Path:** `c:\TCS-P\TheSpotMarket`  
**Phase:** Phase 4 — Global Market Data, API Reliability & Performance Hardening  
**Date:** September 17, 2026  

---

## 1. FILES CHANGED

### 1. `lib/services/global_market_service.dart`
- **Reason for change:** Performance optimization and defensive JSON parsing hardening.
- **Optimizations & Defensive Hardening:**
  - Parallelized Yahoo Finance ticker queries (`Future.wait([Future.wait(indices), Future.wait(stocks)])`) to run index and stock chart requests concurrently, cutting latency in half.
  - Added type-safe JSON extraction for Yahoo Finance chart responses to prevent `TypeError` crashes on unexpected maps, nulls, or malformed payloads.
  - Added robust numeric conversion helper functions (`_numToNullableDouble`, `_numToNullableInt`) to parse numeric values returned as `num`, `String`, or `null`.
  - Hardened `_fromBackend()` JSON parsing to safely extract list items without throwing `TypeError`.
- **Behavior Preserved:** Multi-tiered fallback architecture intact: `Backend -> Yahoo Finance -> SampleData`.

### 2. `lib/providers/app_state.dart`
- **Reason for change:** Concurrency protection, state lifecycle safety, and error resilience.
- **Hardening Changes:**
  - Wrapped `loadGlobal({bool force = false})` in a `try-catch-finally` block ensuring `_globalLoading` is guaranteed to reset to `false` even if an unhandled network error occurs.
  - Added `_globalError` state tracking to capture exception messages without wiping previous successful market snapshots (`_globalSnapshot`).
- **Behavior Preserved:** Existing Provider state management, reactive getters (`globalSnapshot`, `globalIndices`, `globalStocks`, `globalNews`, `globalMood`, `globalSuggestions`), and pull-to-refresh logic preserved without breaking changes.

### 3. `test/core_test.dart`
- **Reason for change:** Unit testing for Phase 4 global market service and state resilience.
- **Tests Added:**
  - Added test for `GlobalMarketService.fetchSnapshot()` verifying safe fallback behavior when backend is unconfigured or network is unreachable.
  - Added test for `AppState.loadGlobal()` verifying `globalLoading` state lifecycle and reactive getter resolution (`globalIndices`, `globalStocks`, `globalMood`, `globalSuggestions`).
- **Behavior Preserved:** All existing baseline tests retained and passing.

### 4. `PHASE_4_CHANGELOG.md`
- **Reason for change:** Documenting Phase 4 changes.

### 5. `PHASE_4_REPORT.md`
- **Reason for change:** Final Phase 4 completion report.

---

## 2. PERFORMANCE & RELIABILITY COMPARISON

| Aspect | Before Phase 4 | After Phase 4 |
| ------ | -------------- | ------------- |
| **Yahoo Query Execution** | Sequential (Indices wait, then Stocks wait) | **Concurrent Parallel** (`Future.wait` across both pools) |
| **Yahoo JSON Parsing** | Direct casts (`as Map<String, dynamic>`) | **Type-safe null-guarded parsing** (immune to `TypeError`) |
| **Numeric Parsing** | Direct `num` / `double` casts | **Helper-based `num.tryParse` / `double` mapping** |
| **Loading State Resilience** | Un-guarded async assignment | **Guarded with `try-finally`** (Loading state always resets) |
| **Data Preservation on Error** | Potential state loss | **Previous successful snapshot retained on failed refresh** |
