import '../entities/verify_otp_result.dart';
import '../repositories/auth_repository.dart';

/// Verifies the 6-digit code against the pending email.
class VerifyOtp {
  const VerifyOtp(this._repo);
  final AuthRepository _repo;

  Future<VerifyOtpResult> call(String email, String code) =>
      _repo.verifyOtp(email.trim(), code.trim());
}
