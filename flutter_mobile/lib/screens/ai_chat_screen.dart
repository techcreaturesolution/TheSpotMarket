import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
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
    'Summarise top headlines for NSE and BSE',
    'Is it a good time to invest in bank stocks?',
  ];

  static const _capabilities = [
    ('ðŸŽ¯', 'Strategy & Guidance', 'Market trend analysis & setups'),
    ('ðŸš€', 'IPO Growth', 'Multi-factor IPO score & GMP'),
    ('ðŸ’¡', 'Market Insights', 'AI buy/sell stock signals'),
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
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.select<AppState, List<ChatMessage>>((st) => st.chat);
    final aiIsConfigured = context.select<AppState, bool>((st) => st.ai.isConfigured);
    final aiProvider = context.select<AppState, String>((st) => st.ai.provider);
    final s = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, size: 18, color: textColor),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF059669)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SpotAI Mentor',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Market & IPO Analyst',
                    style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (aiIsConfigured)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  aiProvider.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: subTextColor),
            onPressed: chat.isEmpty ? null : s.clearChat,
          ),
          IconButton(
            icon: Icon(Icons.key, color: subTextColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!aiIsConfigured)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF059669), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add a Gemini / OpenAI API key in Settings for live answers.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF065F46)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      child: const Text('Settings', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: chat.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF059669), size: 38),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'SpotAI Mentor',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'AI Stock & IPO Guidance Assistant',
                                style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Capabilities',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _capabilities.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final cap = _capabilities[i];
                              return Container(
                                width: 150,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(cap.$1, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 6),
                                    Text(
                                      cap.$2,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cap.$3,
                                      style: TextStyle(fontSize: 10, color: subTextColor),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Suggested Prompts',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 10),
                        ..._suggestions.map((q) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _send(q),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF059669)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          q,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 12, color: subTextColor),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      itemCount: chat.length + (s.chatBusy ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == chat.length) {
                          return const _Bubble(text: 'Analyzing market data...', isUser: false, typing: true);
                        }
                        final m = chat[i];
                        return _Bubble(text: m.text, isUser: m.isUser);
                      },
                    ),
            ),
            const BannerAdWidget(),
            // Bottom Input Bar matching app theme
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Write your message...',
                          hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: s.chatBusy ? null : () => _send(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat Bubble matching Light / App Theme with Green Accent for User and Mint/White for AI
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser, this.typing = false});
  final String text;
  final bool isUser;
  final bool typing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF059669), size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : null,
                color: isUser
                    ? null
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFDCFCE7),
                        width: 1,
                      ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? 'You' : 'SpotAI Mentor',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isUser ? Colors.white : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 4),
                  typing
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669)),
                            ),
                            SizedBox(width: 8),
                            Text('Analyzing live market data...', style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
                          ],
                        )
                      : SelectableText(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                  if (!isUser && !typing) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: Icon(Icons.copy, size: 14, color: subTextColor),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.thumb_up_alt_outlined, size: 14, color: subTextColor),
                        const SizedBox(width: 10),
                        Icon(Icons.refresh, size: 14, color: subTextColor),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFF059669), size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
