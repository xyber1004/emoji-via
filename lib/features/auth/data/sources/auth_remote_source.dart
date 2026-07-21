import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over `supabase.auth` for linking an email to the current
/// (anonymous) account via OTP.
///
/// Uses the *email-change* flow — `updateUser` attaches the email to the
/// existing uid and triggers a code, and `verifyOTP(type: emailChange)`
/// confirms it. This preserves the anonymous uid (and its already-synced
/// streak) rather than creating a second user.
class AuthRemoteSource {
  const AuthRemoteSource(this._client);
  final SupabaseClient _client;

  /// Sends (or resends) a 6-digit code to [email] for the current account.
  Future<void> sendOtp(String email) async {
    await _client.auth.updateUser(UserAttributes(email: email));
  }

  /// Confirms the code, linking [email] to the current uid.
  Future<void> verifyOtp(String email, String code) async {
    await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.emailChange,
    );
  }
}
