/// Lifecycle of the email-linking flow.
enum AuthStatus {
  /// Default — anonymous session, no email attached.
  anonymous,

  /// Waiting for the sendOtp API response.
  sending,

  /// Code has been sent; awaiting user input.
  otpSent,

  /// Waiting for the verifyOtp API response.
  verifying,

  /// Email successfully linked to the account.
  linked,
}
