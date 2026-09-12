import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';

/// Login / registration with email+password or mobile OTP.
/// [allowSkip] lets users continue as guest.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.allowSkip = true});
  final bool allowSkip;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 24),
          Icon(Icons.candlestick_chart, size: 64, color: scheme.primary),
          const SizedBox(height: 8),
          Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(AppConfig.tagline, style: TextStyle(color: scheme.outline)),
          const SizedBox(height: 16),
          TabBar(controller: _tab, tabs: const [
            Tab(icon: Icon(Icons.email_outlined), text: 'Email'),
            Tab(icon: Icon(Icons.phone_android), text: 'Mobile OTP'),
          ]),
          Expanded(
            child: TabBarView(controller: _tab, children: const [_EmailForm(), _PhoneForm()]),
          ),
          if (widget.allowSkip)
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Continue as guest'),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _EmailForm extends StatefulWidget {
  const _EmailForm();

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    try {
      if (_register) {
        await auth.registerWithEmail(_name.text, _email.text, _password.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created. Verification email sent.')));
        }
      } else {
        await auth.signInWithEmail(_email.text, _password.text);
      }
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.friendly(e))));
      }
    }
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email first')));
      return;
    }
    try {
      await context.read<AuthService>().sendPasswordReset(_email.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.friendly(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthService>().busy;
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_register)
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name' : null,
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (!_register)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _forgot, child: const Text('Forgot password?')),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_register ? 'Create account' : 'Sign in'),
          ),
          TextButton(
            onPressed: () => setState(() => _register = !_register),
            child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account'),
          ),
        ],
      ),
    );
  }
}

class _PhoneForm extends StatefulWidget {
  const _PhoneForm();

  @override
  State<_PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends State<_PhoneForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController(text: '+91');
  final _otp = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _sendOtp() async {
    final auth = context.read<AuthService>();
    final phone = _phone.text.replaceAll(' ', '');
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      _toast('Enter mobile number with country code, e.g. +919876543210');
      return;
    }
    try {
      await auth.sendOtp(phone);
      if (!mounted) return;
      if (auth.isSignedIn) {
        Navigator.of(context).maybePop();
      } else {
        _toast('OTP sent to $phone');
      }
    } catch (e) {
      if (mounted) _toast(AuthService.friendly(e));
    }
  }

  Future<void> _verify() async {
    final auth = context.read<AuthService>();
    if (_otp.text.trim().length < 6) {
      _toast('Enter the 6-digit OTP');
      return;
    }
    try {
      await auth.verifyOtp(_otp.text, displayName: _name.text);
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) _toast(AuthService.friendly(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name (optional)', prefixIcon: Icon(Icons.person_outline)),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          enabled: !auth.otpSent,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: const InputDecoration(labelText: 'Mobile number', prefixIcon: Icon(Icons.phone_android), hintText: '+91 98765 43210'),
        ),
        const SizedBox(height: 12),
        if (auth.otpSent) ...[
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            decoration: const InputDecoration(labelText: 'Enter OTP', prefixIcon: Icon(Icons.sms_outlined)),
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: auth.busy ? null : _verify,
            child: auth.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Verify & sign in'),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: auth.busy ? null : _sendOtp, child: const Text('Resend OTP')),
            TextButton(onPressed: auth.resetOtp, child: const Text('Change number')),
          ]),
        ] else
          FilledButton.icon(
            onPressed: auth.busy ? null : _sendOtp,
            icon: auth.busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sms_outlined),
            label: const Text('Send OTP'),
          ),
        const SizedBox(height: 16),
        Text(
          'Standard SMS charges may apply. Firebase phone auth is free for up to 10k verifications/month.',
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
