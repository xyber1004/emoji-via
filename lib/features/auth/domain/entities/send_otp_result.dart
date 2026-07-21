/// Outcome of requesting (or resending) a one-time code.
sealed class SendOtpResult {
  const SendOtpResult();
}

class SendOtpSuccess extends SendOtpResult {
  const SendOtpSuccess();
}

/// Failure carrying a user-facing message (already mapped in the repository).
class SendOtpFailure extends SendOtpResult {
  const SendOtpFailure(this.message);
  final String message;
}
