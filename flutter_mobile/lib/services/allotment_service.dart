import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';

/// IPO allotment lookup.
///
/// Registrar portals (Link Intime, KFintech, Bigshare…) sit behind CAPTCHAs, so
/// fully automatic checks from the device are unreliable. Strategy:
///
/// 1. If a backend is configured, call `BACKEND_URL/allotment` which can run a
///    headless browser / captcha solver server-side and return a definitive
///    answer for many PANs at once.
/// 2. Otherwise open the registrar page in an in-app WebView and auto-fill the
///    PAN via JavaScript (see [prefillScript]); the user just solves the captcha
///    and taps submit. The result is then recorded manually per person.
class AllotmentService {
  AllotmentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get supportsAutoCheck => AppConfig.backendBaseUrl.isNotEmpty;

  Future<List<AllotmentResult>> checkMany(
      Ipo ipo, List<PanProfile> profiles) async {
    if (!supportsAutoCheck) {
      return profiles
          .map((p) => AllotmentResult(
                profileId: p.id,
                ipoId: ipo.id,
                outcome: AllotmentOutcome.unknown,
                checkedAt: DateTime.now(),
                note: 'Configure BACKEND_URL for automatic checks',
              ))
          .toList();
    }
    try {
      final res = await _client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/allotment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ipoId': ipo.id,
              'ipoName': ipo.name,
              'registrar': ipo.registrar,
              'pans': profiles.map((p) => p.pan).toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));
      if (res.statusCode != 200) {
        throw Exception('Allotment service returned HTTP ${res.statusCode}');
      }
      final dynamic body = jsonDecode(res.body);
      final byPan = <String, Map<String, dynamic>>{};
      if (body is Map<String, dynamic> && body['results'] is List) {
        for (final item in (body['results'] as List).whereType<Map<String, dynamic>>()) {
          final pan = (item['pan'] ?? '').toString().toUpperCase();
          if (pan.isNotEmpty) {
            byPan[pan] = item;
          }
        }
      }
      return profiles.map((p) {
        final r = byPan[p.pan.toUpperCase()];
        final status = (r?['status'] as String? ?? 'unknown').toLowerCase();
        return AllotmentResult(
          profileId: p.id,
          ipoId: ipo.id,
          outcome: switch (status) {
            'allotted' => AllotmentOutcome.allotted,
            'not_allotted' || 'notallotted' => AllotmentOutcome.notAllotted,
            'pending' => AllotmentOutcome.pending,
            _ => AllotmentOutcome.unknown,
          },
          sharesAllotted: (r?['shares'] as num?)?.toInt(),
          note: r?['message']?.toString() ?? r?['note']?.toString(),
          checkedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return profiles
          .map((p) => AllotmentResult(
                profileId: p.id,
                ipoId: ipo.id,
                outcome: AllotmentOutcome.unknown,
                checkedAt: DateTime.now(),
                note: 'Automatic check failed: ${e.toString()}',
              ))
          .toList();
    }
  }

  /// Safely generates the PAN autofill script only if the destination URL is verified.
  /// If currentUrl is untrusted or missing, returns empty string to fail closed.
  static String generateAutofillScript(String pan, {String? currentUrl}) {
    if (!isTrustedRegistrarUrl(currentUrl)) {
      return '';
    }
    return prefillScript(pan);
  }

  /// Best-effort JS that fills the first PAN-looking input on a registrar page.
  static String prefillScript(String pan) => '''
(function(){
  var p = ${jsonEncode(pan.toUpperCase())};
  var inputs = Array.from(document.querySelectorAll('input[type=text], input:not([type])'));
  var target = inputs.find(function(i){
    var s = ((i.id||'')+' '+(i.name||'')+' '+(i.placeholder||'')).toLowerCase();
    return s.indexOf('pan') !== -1;
  }) || inputs[0];
  if (target) {
    target.focus();
    target.value = p;
    target.dispatchEvent(new Event('input', {bubbles:true}));
    target.dispatchEvent(new Event('change', {bubbles:true}));
  }
  var radios = Array.from(document.querySelectorAll('input[type=radio]'));
  var panRadio = radios.find(function(r){
    var s = ((r.id||'')+' '+(r.value||'')+' '+(r.name||'')).toLowerCase();
    return s.indexOf('pan') !== -1;
  });
  if (panRadio) { panRadio.click(); }
})();
''';

  static const Set<String> trustedRegistrarDomains = {
    'linkintime.co.in',
    'kfintech.com',
    'bigshareonline.com',
    'cameoindia.com',
    'skylinerta.com',
    'maashitla.com',
    'purvashare.com',
    'bseindia.com',
    'nseindia.com',
    'alankit.com',
    'masserv.com',
  };

  /// Strict URL validator to protect PAN data from SSRF / open redirects in WebView:
  /// 1. Must use HTTPS scheme.
  /// 2. Hostname must exactly match an approved domain or an approved subdomain (e.g. `*.kfintech.com`).
  /// 3. Rejects userinfo, lookalike domains (e.g. `evil-linkintime.co.in`), and non-HTTPS schemes.
  static bool isTrustedRegistrarUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return false;
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return false;

    // Strict HTTPS required
    if (uri.scheme.toLowerCase() != 'https') return false;

    final host = uri.host.toLowerCase().trim();
    if (host.isEmpty) return false;

    // Reject raw IPv4/IPv6 addresses
    if (RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host) || host.contains(':')) {
      return false;
    }

    for (final trusted in trustedRegistrarDomains) {
      if (host == trusted || host.endsWith('.$trusted')) {
        return true;
      }
    }
    return false;
  }

  static Registrar? registrarFor(Ipo ipo) {
    final name = ipo.registrar.toLowerCase();
    for (final r in AppConfig.registrars) {
      final key = r.name.toLowerCase().split(' ').first;
      if (name.contains(key)) return r;
    }
    return ipo.registrarUrl.isNotEmpty
        ? Registrar(ipo.registrar, ipo.registrarUrl)
        : null;
  }
}
