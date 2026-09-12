import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication (free Spark plan): email/password + phone OTP.
/// When Firebase is not configured (no google-services.json), [isAvailable]
/// is false and the app runs in guest mode.
class AuthService extends ChangeNotifier {
  AuthService({FirebaseAuth? auth, required this.isAvailable})
      : _auth = isAvailable ? (auth ?? FirebaseAuth.instance) : null {
    _auth?.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
    _user = _auth?.currentUser;
  }

  final FirebaseAuth? _auth;
  final bool isAvailable;
  User? _user;
  String? _verificationId;
  int? _resendToken;
  bool _busy = false;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get busy => _busy;
  bool get otpSent => _verificationId != null;

  String get displayName =>
      _user?.displayName?.trim().isNotEmpty == true
          ? _user!.displayName!
          : (_user?.email ?? _user?.phoneNumber ?? 'Guest');

  Future<T> _run<T>(Future<T> Function() fn) async {
    _busy = true;
    notifyListeners();
    try {
      return await fn();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  static String friendly(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Incorrect email or password.',
        'email-already-in-use' => 'An account already exists for this email.',
        'weak-password' => 'Password should be at least 6 characters.',
        'invalid-phone-number' => 'Enter a valid mobile number with country code (+91…).',
        'invalid-verification-code' => 'Incorrect OTP. Please try again.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => e.message ?? 'Authentication failed (${e.code}).',
      };
    }
    return e.toString();
  }

  Future<void> registerWithEmail(String name, String email, String password) =>
      _run(() async {
        final cred = await _auth!.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        await cred.user?.updateDisplayName(name.trim());
        await cred.user?.sendEmailVerification();
        await cred.user?.reload();
        _user = _auth.currentUser;
      });

  Future<void> signInWithEmail(String email, String password) => _run(() =>
      _auth!.signInWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> sendPasswordReset(String email) =>
      _run(() => _auth!.sendPasswordResetEmail(email: email.trim()));

  /// Sends an OTP. Completes when the code is sent (or auto-verified on
  /// Android). Throws on failure.
  Future<void> sendOtp(String phone) => _run(() async {
        final done = Completer<void>();
        await _auth!.verifyPhoneNumber(
          phoneNumber: phone.trim(),
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (cred) async {
            await _auth.signInWithCredential(cred);
            _verificationId = null;
            if (!done.isCompleted) done.complete();
          },
          verificationFailed: (e) {
            if (!done.isCompleted) done.completeError(e);
          },
          codeSent: (id, token) {
            _verificationId = id;
            _resendToken = token;
            if (!done.isCompleted) done.complete();
          },
          codeAutoRetrievalTimeout: (id) => _verificationId ??= id,
        );
        return done.future;
      });

  Future<void> verifyOtp(String code, {String? displayName}) => _run(() async {
        final id = _verificationId;
        if (id == null) throw StateError('Request an OTP first.');
        final cred = PhoneAuthProvider.credential(
            verificationId: id, smsCode: code.trim());
        final result = await _auth!.signInWithCredential(cred);
        if (displayName != null && displayName.trim().isNotEmpty) {
          await result.user?.updateDisplayName(displayName.trim());
        }
        _verificationId = null;
      });

  void resetOtp() {
    _verificationId = null;
    notifyListeners();
  }

  Future<void> signOut() => _run(() => _auth!.signOut());

  Future<void> deleteAccount() => _run(() async => _auth!.currentUser?.delete());
}
