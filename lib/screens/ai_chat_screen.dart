import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'settings_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    'Which open IPO looks best for listing gains?',
    'Explain today\'s market mood in simple words',
    'What is GMP and should I trust it?',
    'How does IPO allotment lottery work?',
    'Summarise the top news for NSE and BSE',
    'Is it a good time to invest in bank stocks?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final t = (text ?? _input.text).trim();
    if (t.isEmpty) return;
    _input.clear();
    await context.read<AppState>().sendChat(t);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.auto_awesome, size: 20),
          const SizedBox(width: 8),
          const Text('SpotAI'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (s.ai.isConfigured ? Colors.green : Colors.orange).withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(s.ai.isConfigured ? s.ai.provider.toUpperCase() : 'OFFLINE',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: s.chat.isEmpty ? null : s.clearChat),
          IconButton(
            icon: const Icon(Icons.key),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(children: [
        if (!s.ai.isConfigured)
          MaterialBanner(
            content: const Text('Add a free Gemini API key in Settings to unlock live AI answers with market context.'),
            leading: const Icon(Icons.info_outline),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const Text('Settings'),
              ),
            ],
          ),
        Expanded(
          child: s.chat.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.auto_awesome, size: 56, color: scheme.primary),
                    const SizedBox(height: 12),
                    const Text('Ask SpotAI anything about IPOs, NSE/BSE stocks and market news',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    ..._suggestions.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            onPressed: () => _send(q),
                            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                            child: Text(q),
                          ),
                        )),
                  ],
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: s.chat.length + (s.chatBusy ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == s.chat.length) return const _Bubble(text: '…', isUser: false, typing: true);
                    final m = s.chat[i];
                    return _Bubble(text: m.text, isUser: m.isUser);
                  },
                ),
        ),
        const BannerAdWidget(),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Ask about an IPO, stock or the market…',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: s.chatBusy ? null : _send,
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser, this.typing = false});
  final String text;
  final bool isUser;
  final bool typing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .8),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: typing
            ? const SizedBox(width: 36, height: 16, child: LinearProgressIndicator())
            : SelectableText(text,
                style: TextStyle(color: isUser ? scheme.onPrimary : scheme.onSurface, height: 1.35)),
      ),
    );
  }
}
