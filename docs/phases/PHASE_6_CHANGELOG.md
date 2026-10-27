# PHASE 6 CHANGELOG — IPO, ALLOTMENT & REGISTRAR DATA RELIABILITY HARDENING

## 1. FILES CHANGED & REASON FOR EACH CHANGE

1. **`lib/services/ipo_service.dart`**
   - **Reason:** Hardened API endpoint JSON payload parsing to handle both standard JSON arrays (`[...]`) and wrapped maps (`{ "ipos": [...] }`), type-safe field extraction for numeric strings, double, int, and nulls, robust date string parsing with format fallback, deduplication by IPO ID and symbol via `seenIds`, and error handling returning `SampleData.ipos()` fallback without throwing exceptions or leaving loading stuck.

2. **`lib/services/allotment_service.dart`**
   - **Reason:** Hardened `checkMany` endpoint response processing to safely handle response maps, lists, string PAN conversions, and unexpected status codes/exceptions; returns `AllotmentOutcome.unknown` with diagnostic error note on failure without crashing.

3. **`lib/providers/app_state.dart`**
   - **Reason:** Wrapped `loadIpos()` in a strict `try-catch-finally` block to guarantee `_ipoLoading = false` resets under all conditions, stored `_ipoError` state for UI display, preserved existing `_ipos` data on fetch failure, and added a re-entrance check (`if (_checkingAllotment) return null;`) in `checkAllotmentsFor()` to prevent parallel duplicate allotment checks.

4. **`lib/screens/allotment_screen.dart`**
   - **Reason:** Hardened `_RegistrarWebViewState` lifecycle by adding `mounted` checks to `onPageStarted` and `onPageFinished` navigation callbacks, added `onWebResourceError` handler to reset `_loading` on WebView errors, and added an external browser button in the AppBar using `url_launcher` so users can open registrar websites directly if automated WebViews are blocked.

5. **`test/core_test.dart`**
   - **Reason:** Added Phase 6 unit test group verifying `IpoService` array & wrapped map parsing, deduplication by ID/symbol, network 500 fallback to `SampleData`, `AllotmentService.checkMany` safe exception handling, `AppState.loadIpos` lifecycle & data retention, and `AppState.checkAllotmentsFor` duplicate request prevention.

---

## 2. APPLICATION BEHAVIOR PRESERVED

- **Multi-tier Source Priority:** Kept `Backend API -> SampleData` for IPO data and `Backend API -> Registrar WebView` for allotment checks intact.
- **PAN Security Architecture:** Preserved `FlutterSecureStorage` for encrypted PAN persistence; zero plaintext PAN storage or logging added.
- **Registrar Support:** Preserved all 5 existing registrar portals (Link Intime, KFintech, Bigshare, Skyline, Cameo) and in-app prefill scripts.
- **Navigation & UI:** Preserved existing navigation routes, screens, and design layout without redesigning UI or breaking existing flows.
- **Authentication:** Left Firebase Authentication, email login, and mobile OTP flows completely untouched.

---

## 3. TESTS ADDED

- **`IpoService parses valid JSON array and deduplicates by ID/symbol`**: Verifies array JSON response parsing, numeric string conversions (`"100"` -> `100.0`), and deduplication of duplicate IPO entries.
- **`IpoService handles wrapped JSON map format { "ipos": [...] } safely`**: Verifies handling of wrapped JSON objects without throwing runtime exceptions.
- **`IpoService falls back to SampleData on network 500 error or exception`**: Verifies seamless fallback to `SampleData.ipos()` on server failure.
- **`AllotmentService.checkMany returns AllotmentOutcome.unknown safely on network error`**: Verifies graceful error handling on network disconnects.
- **`AppState loadIpos maintains loading state lifecycle and preserves IPOs`**: Verifies `ipoLoading` resets to `false` and previous IPO data is retained.
- **`AppState checkAllotmentsFor guards against duplicate parallel calls`**: Verifies re-entrance prevention when an allotment check is already in progress.

---

## 4. PERFORMANCE IMPROVEMENTS

- **Re-entrance Guarding:** Prevents duplicate concurrent network calls for allotment status checks (`checkAllotmentsFor`).
- **O(1) Deduplication:** Uses Set lookup (`seenIds`) during IPO response parsing to eliminate duplicate records efficiently.
- **WebView Controller Protection:** `mounted` checks avoid memory leaks and unmounted `setState` calls during fast back-navigation.

---

## 5. SECURITY-RELATED CHANGES

- **PAN Security Retained:** Kept `FlutterSecureStorage` as sole storage mechanism for sensitive PAN cards.
- **Zero Sensitive Data Logging:** Audited all log outputs to guarantee PAN numbers, passwords, OTPs, and authentication tokens are never printed or logged.
- **External Launcher Safety:** Ensured registrar URLs use HTTPS where supported and opened safely via `url_launcher`.
