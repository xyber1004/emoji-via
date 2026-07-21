import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/send_otp_result.dart';
import '../../domain/entities/verify_otp_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._source);
  final AuthRemoteSource _source;

  @override
  Future<SendOtpResult> sendOtp(String email) async {
    try {
      await _source.sendOtp(email);
      return const SendOtpSuccess();
    } catch (e) {
      return SendOtpFailure(_mapSendError(e));
    }
  }

  @override
  Future<SendOtpResult> resendOtp(String email) => sendOtp(email);

  @override
  Future<VerifyOtpResult> verifyOtp(String email, String code) async {
    try {
      await _source.verifyOtp(email, code);
      return const VerifyOtpSuccess();
    } catch (e) {
      return VerifyOtpFailure(_mapVerifyError(e));
    }
  }

  // --- error mapping (never surface raw messages to users) -----------------

  String _mapSendError(Object e) {
    debugPrint('sendOtp error: $e');
    if (_isNetwork(e)) {
      return "Couldn't reach the server. Check your connection.";
    }
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (e.statusCode == '429' || msg.contains('rate')) {
        return "You've requested a lot of codes recently — try again in a few minutes.";
      }
      if (msg.contains('already') && msg.contains('registered')) {
        return 'That email is already linked to another account.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  String _mapVerifyError(Object e) {
    debugPrint('verifyOtp error: $e');
    if (_isNetwork(e)) {
      return "Couldn't reach the server. Check your connection.";
    }
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('expired')) {
        return "That code has expired. Tap 'Resend code' to get a new one.";
      }
      if (msg.contains('invalid') || msg.contains('token')) {
        return 'That code didn\'t match. Check your email and try again.';
      }
      if (e.statusCode == '429' || msg.contains('rate')) {
        return "You've tried a lot recently — wait a few minutes and try again.";
      }
    }
    return 'Something went wrong. Please try again.';
  }

  bool _isNetwork(Object e) {
    if (e is SocketException || e is TimeoutException) return true;
    final s = e.toString().toLowerCase();
    return s.contains('socket') ||
        s.contains('connection') ||
        s.contains('failed host lookup');
  }
}
