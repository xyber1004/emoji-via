import '../entities/send_otp_result.dart';
import '../repositories/auth_repository.dart';

/// Validates the email locally, then requests a one-time code.
class SendOtp {
  const SendOtp(this._repo);
  final AuthRepository _repo;

  // Pragmatic email shape check — the backend is the real authority.
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  Future<SendOtpResult> call(String email) {
    final trimmed = email.trim();
    if (!isValidEmail(trimmed)) {
      return Future.value(
        const SendOtpFailure("That doesn't look like a valid email."),
      );
    }
    return _repo.sendOtp(trimmed);
  }
}
