import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thespotmarket/config/app_config.dart';
import 'package:thespotmarket/models/models.dart';
import 'package:thespotmarket/services/ai_service.dart';

void main() {
  group('AiService Security & Backend Proxy Tests', () {
    test('isConfigured is true whenever backendBaseUrl is present', () {
      final old = AppConfig.backendBaseUrl;
      try {
        AppConfig.backendBaseUrl = 'https://thespotmarket-1.onrender.com';
        final ai = AiService();
        expect(ai.isConfigured, isTrue);

        AppConfig.backendBaseUrl = '';
        expect(ai.isConfigured, isFalse);
      } finally {
        AppConfig.backendBaseUrl = old;
      }
    });

    test('backend proxy 200 response is successfully parsed and returned', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/api/ai/chat'));
        expect(request.headers['content-type'], contains('application/json'));
        
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['messages'], isNotEmpty);

        return http.Response(
          jsonEncode({
            'success': true,
            'reply': 'Proxy answered successfully. Not SEBI-registered investment advice.',
          }),
          200,
        );
      });

      final ai = AiService(client: mockClient);
      final history = [
        ChatMessage(role: 'user', text: 'Tell me about NIFTY', at: DateTime.now())
      ];

      final reply = await ai.chat(history);
      expect(reply, contains('Proxy answered successfully'));
    });

    test('backend failure falls back to safe local heuristic without calling external providers', () async {
      bool calledExternalProvider = false;
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('openai') || request.url.host.contains('googleapis')) {
          calledExternalProvider = true;
          return http.Response('Forbidden', 403);
        }
        // Backend returns 502 Bad Gateway
        return http.Response(jsonEncode({'message': 'Upstream failure'}), 502);
      });

      final ai = AiService(client: mockClient);
      final history = [
        ChatMessage(role: 'user', text: 'What is GMP and should I trust it?', at: DateTime.now())
      ];

      final reply = await ai.chat(history);
      expect(reply, contains('Grey Market Premium'));
      expect(calledExternalProvider, isFalse, reason: 'Must NEVER call OpenAI/Gemini directly from client');
    });

    test('offline heuristic replies safely when backend is empty or unreachable', () async {
      final oldUrl = AppConfig.backendBaseUrl;
      AppConfig.backendBaseUrl = '';
      try {
        final ai = AiService();
        final history = [
          ChatMessage(role: 'user', text: 'What is PE ratio?', at: DateTime.now())
        ];

        final reply = await ai.chat(history);
        expect(reply, contains('SpotAI is currently running in offline mode'));
        expect(reply, contains('Not SEBI-registered investment advice'));
      } finally {
        AppConfig.backendBaseUrl = oldUrl;
      }
    });
  });
}
