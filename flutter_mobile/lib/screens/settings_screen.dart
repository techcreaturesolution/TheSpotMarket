import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: const Color(0xFF040A07),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient liquid emerald glows
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 360,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // ------------------------------------------------------------ account
              const _Header('Account'),
              _GlassCard(
                child: (!auth.isAvailable)
                    ? const ListTile(
                        leading: Icon(Icons.cloud_off, color: Colors.white60),
                        title: Text('Firebase not configured', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        subtitle: Text('Add google-services.json / GoogleService-Info.plist to enable login.', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      )
                    : (auth.isSignedIn)
                        ? Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF042013)),
                                    ),
                                  ),
                                ),
                                title: Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                                subtitle: Text(
                                  [
                                    if (auth.user?.email != null) auth.user!.email!,
                                    if (auth.user?.phoneNumber != null) auth.user!.phoneNumber!,
                                    if (auth.user?.email != null && auth.user?.emailVerified == false) 'Email not verified',
                                  ].join(' · '),
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                                ),
                              ),
                              if (auth.user?.email != null && auth.user?.emailVerified == false)
                                ListTile(
                                  leading: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFF34D399)),
                                  title: const Text('Resend verification email', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                                  onTap: () async {
                                    await auth.user?.sendEmailVerification();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent')));
                                    }
                                  },
                                ),
                              const Divider(height: 1, color: Colors.white12),
                              ListTile(
                                leading: const Icon(Icons.logout, color: Colors.white70),
                                title: const Text('Sign out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                onTap: auth.busy ? null : auth.signOut,
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever, color: Color(0xFFEF4444)),
                                title: const Text('Delete account', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 14)),
                                onTap: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: const Color(0xFF0B1711),
                                      title: const Text('Delete account?', style: TextStyle(color: Colors.white)),
                                      content: const Text('This permanently removes your login. PAN data stays on this device.', style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok != true) return;
                                  try {
                                    await auth.deleteAccount();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.friendly(e))));
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        : ListTile(
                            leading: const Icon(Icons.login, color: Color(0xFF34D399)),
                            title: const Text('Sign in / Register', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                            subtitle: const Text('Email & password or mobile OTP', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                          ),
              ),

              // --------------------------------------------------------------- AI
              const _Header('SpotAI'),
              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF34D399), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SpotAI Intelligence',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Configured & active via environment (.env)',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF10B981).withValues(alpha: 0.20),
                          border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.45)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 13),
                            SizedBox(width: 4),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          // ------------------------------------------------------------- data
          const _Header('Data sources'),
          _GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined, color: Color(0xFF34D399)),
                  title: const Text('Backend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    AppConfig.backendBaseUrl.isEmpty
                        ? 'Not configured – using public NSE feed, RSS news & sample IPO data'
                        : AppConfig.backendBaseUrl,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.rss_feed, color: Color(0xFF34D399)),
                  title: const Text('News feeds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    AppConfig.newsFeeds.map((f) => f.name).join(', '),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------------ about
          const _Header('About'),
          const _GlassCard(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF34D399)),
              title: Text('${AppConfig.appName} 1.0.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Data may be delayed. IPO scores, sentiment and SpotAI replies are informational only and are not SEBI-registered investment advice. PAN details never leave your device unless you configure a backend.',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ],
  ),
);
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFF0C2016).withValues(alpha: 0.40),
            const Color(0xFF030D08).withValues(alpha: 0.70),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF34D399),
              ),
            ),
          ],
        ),
      );
}
