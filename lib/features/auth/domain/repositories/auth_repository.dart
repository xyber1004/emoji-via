import '../entities/send_otp_result.dart';
import '../entities/verify_otp_result.dart';

/// Contract for email-OTP account linking. Implementations map backend errors
/// to user-facing messages before returning — callers never see raw exceptions.
abstract class AuthRepository {
  Future<SendOtpResult> sendOtp(String email);
  Future<VerifyOtpResult> verifyOtp(String email, String code);
  Future<SendOtpResult> resendOtp(String email);
}
