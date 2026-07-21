/// Outcome of verifying a one-time code.
sealed class VerifyOtpResult {
  const VerifyOtpResult();
}

class VerifyOtpSuccess extends VerifyOtpResult {
  const VerifyOtpSuccess();
}

/// Failure carrying a user-facing message (already mapped in the repository).
class VerifyOtpFailure extends VerifyOtpResult {
  const VerifyOtpFailure(this.message);
  final String message;
}
