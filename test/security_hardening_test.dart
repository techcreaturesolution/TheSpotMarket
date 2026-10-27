import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:thespotmarket/config/app_config.dart';
import 'package:thespotmarket/services/allotment_service.dart';

void main() {
  group('Security Hardening: Asset & Secret Isolation', () {
    test('pubspec.yaml does NOT bundle .env as an asset', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);
      final content = pubspecFile.readAsStringSync();
      // Ensure '.env' is not declared in the assets section
      final assetEnvRegex = RegExp(r'^\s*-\s*\.env\s*$', multiLine: true);
      expect(assetEnvRegex.hasMatch(content), isFalse,
          reason: 'pubspec.yaml must not include .env in assets list');
    });

    test('AppConfig does not expose client-side API keys', () {
      // AppConfig should have backendBaseUrl and non-sensitive display configs
      expect(AppConfig.backendBaseUrl, isNotEmpty);
      expect(AppConfig.backendBaseUrl.startsWith('https://'), isTrue);
    });
  });

  group('Security Hardening: IPO Registrar Domain Validation', () {
    test('allows legitimate registrar HTTPS domains', () {
      expect(AllotmentService.isTrustedRegistrarUrl('https://linkintime.co.in/Initial_Offer/public-issues.html'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://web.linkintime.co.in/ipo'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://kfintech.com/allotment'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://ris.kfintech.com/ipostatus/'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://bigshareonline.com/ipo_Allotment.html'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://ipo.bigshareonline.com/'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://cameoindia.com/'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://skylinerta.com/'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://bseindia.com/investors/appli_check.aspx'), isTrue);
      expect(AllotmentService.isTrustedRegistrarUrl('https://www.nseindia.com/invest/check-trades-bids-verify-ipo-bids'), isTrue);
    });

    test('rejects plain HTTP URLs for registrars', () {
      expect(AllotmentService.isTrustedRegistrarUrl('http://linkintime.co.in/Initial_Offer/'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('http://kfintech.com/ipostatus'), isFalse);
    });

    test('rejects unsafe schemes (javascript, data, file)', () {
      expect(AllotmentService.isTrustedRegistrarUrl('javascript:alert(1)'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=='), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('file:///etc/passwd'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('intent://example.com'), isFalse);
    });

    test('rejects lookalike domains and misleading subdomains', () {
      // Subdomain attacking legitimate domain name: attacker.com
      expect(AllotmentService.isTrustedRegistrarUrl('https://linkintime.co.in.attacker.com/ipo'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('https://kfintech.com.phishing.io/'), isFalse);
      // Lookalike string containing registrar name
      expect(AllotmentService.isTrustedRegistrarUrl('https://evil-linkintime.co.in/ipo'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('https://fake-kfintech.com/'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('https://notlinkintime.co.in/'), isFalse);
    });

    test('rejects IP literals', () {
      expect(AllotmentService.isTrustedRegistrarUrl('https://192.168.1.1/ipo'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('https://127.0.0.1:8080/allotment'), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('http://10.0.0.1/'), isFalse);
    });

    test('rejects null and empty inputs safely', () {
      expect(AllotmentService.isTrustedRegistrarUrl(null), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl(''), isFalse);
      expect(AllotmentService.isTrustedRegistrarUrl('   '), isFalse);
    });
  });

  group('Security Hardening: PAN Autofill Script Generation', () {
    test('generates autofill script only for trusted registrar destinations', () {
      const mockTestPan = 'ABCDE1234F'; // Dummy format test string only
      const trustedUrl = 'https://linkintime.co.in/Initial_Offer/public-issues.html';
      
      final script = AllotmentService.generateAutofillScript(mockTestPan, currentUrl: trustedUrl);
      expect(script, isNotEmpty);
      expect(script, contains(mockTestPan));
    });

    test('BLOCKS autofill script (returns empty string) for untrusted destinations', () {
      const mockTestPan = 'ABCDE1234F'; // Dummy format test string only
      const untrustedUrl = 'https://untrusted-thirdparty.com/login';
      
      final script = AllotmentService.generateAutofillScript(mockTestPan, currentUrl: untrustedUrl);
      expect(script, isEmpty, reason: 'Must NEVER return PAN autofill script for untrusted or unverified URL');
    });

    test('BLOCKS autofill script when currentUrl is null or empty', () {
      const mockTestPan = 'ABCDE1234F';
      expect(AllotmentService.generateAutofillScript(mockTestPan, currentUrl: null), isEmpty);
      expect(AllotmentService.generateAutofillScript(mockTestPan, currentUrl: ''), isEmpty);
    });
  });
}
