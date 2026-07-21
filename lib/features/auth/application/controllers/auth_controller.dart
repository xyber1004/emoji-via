import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:emojivia/core/storage/storage_service.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/entities/send_otp_result.dart';
import '../../domain/entities/verify_otp_result.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

/// Drives the email-OTP linking state machine. Flattened state on the notifier,
/// per the app's `provider` conventions.
class AuthController extends ChangeNotifier {
  AuthController({
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required ResendOtp resendOtp,
    required StorageService storage,
    required SupabaseClient client,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _resendOtp = resendOtp,
        _storage = storage {
    // Stay in sync with external session changes (e.g. token refresh) so we
    // never desync. Subscribed once here, not in individual widgets.
    _authSub = client.auth.onAuthStateChange.listen((state) {
      final linked = state.session?.user.email != null;
      if (linked && status != AuthStatus.linked) {
        status = AuthStatus.linked;
        notifyListeners();
      }
    });
  }

  static const resendCooldown = Duration(seconds: 60);

  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;
  final StorageService _storage;
  StreamSubscription<AuthState>? _authSub;

  AuthStatus status = AuthStatus.anonymous;
  String? pendingEmail;
  String? errorMessage;
  DateTime? lastOtpSentAt;

  /// Seconds remaining before a resend is allowed (0 when ready).
  int get resendSecondsRemaining {
    final sent = lastOtpSentAt;
    if (sent == null) return 0;
    final elapsed = DateTime.now().difference(sent);
    final remaining = resendCooldown - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds + 1;
  }

  Future<void> sendOtp(String email) async {
    status = AuthStatus.sending;
    errorMessage = null;
    notifyListeners();

    final result = await _sendOtp(email);
    switch (result) {
      case SendOtpSuccess():
        pendingEmail = email.trim();
        lastOtpSentAt = DateTime.now();
        status = AuthStatus.otpSent;
      case SendOtpFailure(:final message):
        errorMessage = message;
        status = AuthStatus.anonymous;
    }
    notifyListeners();
  }

  Future<void> resendOtp() async {
    final email = pendingEmail;
    if (email == null) return;
    if (resendSecondsRemaining > 0) {
      errorMessage = 'Please wait before requesting another code.';
      notifyListeners();
      return;
    }
    errorMessage = null;
    notifyListeners();

    final result = await _resendOtp(email);
    switch (result) {
      case SendOtpSuccess():
        lastOtpSentAt = DateTime.now();
      case SendOtpFailure(:final message):
        errorMessage = message;
    }
    notifyListeners();
  }

  Future<void> verifyOtp(String code) async {
    final email = pendingEmail;
    if (email == null) return;

    status = AuthStatus.verifying;
    errorMessage = null;
    notifyListeners();

    final result = await _verifyOtp(email, code);
    switch (result) {
      case VerifyOtpSuccess():
        await _storage.setEmailLinkedAt(DateTime.now());
        status = AuthStatus.linked;
      case VerifyOtpFailure(:final message):
        errorMessage = message;
        status = AuthStatus.otpSent;
    }
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  void reset() {
    status = AuthStatus.anonymous;
    pendingEmail = null;
    errorMessage = null;
    lastOtpSentAt = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
