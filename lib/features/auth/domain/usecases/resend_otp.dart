import '../entities/send_otp_result.dart';
import '../repositories/auth_repository.dart';

/// Re-requests a one-time code for an email already in flight.
class ResendOtp {
  const ResendOtp(this._repo);
  final AuthRepository _repo;

  Future<SendOtpResult> call(String email) => _repo.resendOtp(email.trim());
}
