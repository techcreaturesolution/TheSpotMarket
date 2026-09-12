import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _key;
  late String _provider;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _key = TextEditingController(text: s.ai.apiKey);
    _provider = s.ai.provider;
  }

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ------------------------------------------------------------ account
          const _Header('Account'),
          if (!auth.isAvailable)
            const ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Firebase not configured'),
              subtitle: Text('Add google-services.json / GoogleService-Info.plist to enable login.'),
            )
          else if (auth.isSignedIn) ...[
            ListTile(
              leading: CircleAvatar(child: Text(auth.displayName[0].toUpperCase())),
              title: Text(auth.displayName),
              subtitle: Text([
                if (auth.user?.email != null) auth.user!.email!,
                if (auth.user?.phoneNumber != null) auth.user!.phoneNumber!,
                if (auth.user?.email != null && auth.user?.emailVerified == false) 'Email not verified',
              ].join(' · ')),
            ),
            if (auth.user?.email != null && auth.user?.emailVerified == false)
              ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: const Text('Resend verification email'),
                onTap: () async {
                  await auth.user?.sendEmailVerification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent')));
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: auth.busy ? null : auth.signOut,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete account', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete account?'),
                    content: const Text('This permanently removes your login. PAN data stays on this device.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in / Register'),
              subtitle: const Text('Email & password or mobile OTP'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
            ),

          // --------------------------------------------------------------- AI
          const _Header('SpotAI'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'gemini', label: Text('Google Gemini (free tier)')),
                  ButtonSegment(value: 'openai', label: Text('OpenAI')),
                ],
                selected: {_provider},
                onSelectionChanged: (v) => setState(() => _provider = v.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _key,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API key',
                  helperText: _provider == 'gemini'
                      ? 'Get a free key at aistudio.google.com/app/apikey'
                      : 'platform.openai.com/api-keys',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: () => launchUrl(
                      Uri.parse(_provider == 'gemini'
                          ? 'https://aistudio.google.com/app/apikey'
                          : 'https://platform.openai.com/api-keys'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                FilledButton(
                  onPressed: () async {
                    await s.setAiConfig(provider: _provider, apiKey: _key.text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI settings saved')));
                    }
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    _key.clear();
                    await s.setAiConfig(provider: _provider, apiKey: '');
                  },
                  child: const Text('Clear key'),
                ),
              ]),
              const SizedBox(height: 4),
              Text('The key is stored only on this device.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            ]),
          ),

          // ---------------------------------------------------------- display
          const _Header('Appearance'),
          SwitchListTile(
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: s.darkMode,
            onChanged: s.setDarkMode,
          ),

          // ------------------------------------------------------------- data
          const _Header('Data sources'),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Backend'),
            subtitle: Text(AppConfig.backendBaseUrl.isEmpty
                ? 'Not configured – using public NSE feed, RSS news & sample IPO data'
                : AppConfig.backendBaseUrl),
          ),
          ListTile(
            leading: const Icon(Icons.rss_feed),
            title: const Text('News feeds'),
            subtitle: Text(AppConfig.newsFeeds.map((f) => f.name).join(', ')),
          ),

          // ------------------------------------------------------------ about
          const _Header('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('${AppConfig.appName} 1.0.0'),
            subtitle: Text(
              'Data may be delayed. IPO scores, sentiment and SpotAI replies are informational only and are not SEBI-registered investment advice. PAN details never leave your device unless you configure a backend.',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.primary)),
      );
}
