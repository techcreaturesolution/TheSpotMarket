# PHASE 7 CHANGELOG — NEWS & CONTENT DATA RELIABILITY

## 1. FILES CHANGED & EXACT CHANGES

1. **`lib/services/news_service.dart`**
   - **Parser Hardening:** Added Atom `<entry>` XML structure support alongside RSS 2.0 `<item>` tags. Added multi-tag attribute extraction (`link` text, `href` attribute, `guid`, `id`). Expanded `_stripHtml` entity decoding to support `&lt;`, `&gt;`, `&apos;`, `&#8217;`, `&#8220;`, `&#8221;`, `&#8211;`, `&#8212;`, `&mdash;`, `&ndash;`.
   - **Date Parsing Hardening:** Expanded `_parseDate` to inspect `pubDate`, `dc:date`, `published`, `updated`, and `date` tags, and added timezone token handling for EST, EDT, PST, PDT, CST, CDT alongside GMT, UTC, IST.
   - **Canonical Deduplication:** Updated `fetchFeeds` deduplication hierarchy to prioritize canonical article URL/link (`a.link.trim()`), falling back to `a.source + a.title` if link is absent.
   - **Feed-Level Isolation:** Bounded per-feed timeout to 10 seconds; wrapped feed HTTP calls in `try-catch` to return `const []` on 403, 404, 500, or network timeouts, allowing surviving feeds to render.

2. **`lib/providers/app_state.dart`**
   - **Lifecycle & Lifecycle State:** Hardened `loadNews({bool force = false})` with a `try-catch-finally` block to guarantee `_newsLoading = false` resets.
   - **Previous Data Preservation:** Preserves existing successful `_newsResult` data when a refresh attempt yields an empty result or throws an exception.
   - **Error State Exposure:** Added `_newsError` getter and state property.

3. **`test/core_test.dart`**
   - **Test Suite Expansion:** Added 9 unit test cases in group `Phase 7 — News & Content Data Reliability & Performance Hardening` covering RSS 2.0, Atom XML, HTML entity decoding, malformed XML, date fallback, feed failure isolation, canonical link deduplication, all-feed failure fallback, and `AppState.loadNews` lifecycle & re-entrance protection.

4. **`PHASE_7_CHANGELOG.md`**
   - Documentation of all Phase 7 changes, preserved behaviors, and audit results.

5. **`PHASE_7_REPORT.md`**
   - Authoritative report detailing Phase 7 implementation, error handling, parsing, deduplication, test results, and final status.

---

## 2. RSS FEED CHANGES
- Retained all 7 Indian feeds in `AppConfig.newsFeeds` and all 6 Global feeds in `AppConfig.globalNewsFeeds`.
- Individual broken feeds (e.g. 403 / 404 returns) are now completely isolated by `_fetchFeed` and return `[]` cleanly without failing the overall news aggregator or triggering whole-page fallbacks when live feeds succeed.

---

## 3. PARSER CHANGES
- Support for `<entry>` tags (Atom) alongside `<item>` tags (RSS 2.0).
- Support for `summary` and `content` tags when `description` is absent.
- Support for `href` attribute on `<link>` tags.
- Support for `pubDate`, `dc:date`, `published`, `updated`, `date` tags.
- Comprehensive HTML entity stripping and unescaping.

---

## 4. ERROR-HANDLING CHANGES
- Feed isolation: Failure in one RSS publisher feed (403, 404, 500, timeout, malformed XML) returns `const []` without throwing exceptions or stopping other feeds.
- All-feed failure: If all feeds return `[]`, falls back to `SampleData.news` / `SampleData.globalNews` with `isLive: false`.
- Provider safety: `AppState.loadNews` wrapped in `try-catch-finally`.

---

## 5. DUPLICATE HANDLING
- Deduplication key hierarchy:
  1. `a.link.trim().toLowerCase()` (Canonical URL)
  2. `a.source.toLowerCase() + '|' + a.title.toLowerCase()` (Title + Source fallback)

---

## 6. CONCURRENCY CHANGES
- `fetchFeeds` executes per-feed requests concurrently using `Future.wait(feeds.map(_fetchFeed), eagerError: false)`.

---

## 7. PROVIDER / APPSTATE CHANGES
- Added `_newsError` state property.
- Enforced re-entrance guard `if (_newsLoading && !force) return;`.
- Preserves previous successful `_newsResult` on refresh error.

---

## 8. INTENTIONALLY LEFT UNCHANGED
- Existing UI layouts and widgets (`NewsScreen`, `_NewsCard`, `_CategoryChip`).
- Existing `NewsArticle` model structure.
- Authentication, Firebase configuration, PAN secure storage, Indian Market (NSE), Global Market (Yahoo), IPO, Allotment, SpotAI, and AdMob services.
