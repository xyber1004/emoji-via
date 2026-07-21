import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import '../../application/controllers/auth_controller.dart';
import '../../domain/entities/auth_status.dart';
import '../widgets/otp_input.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Drive the resend-cooldown countdown display.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _onComplete(String code) async {
    final auth = context.read<AuthController>();
    await auth.verifyOtp(code);
    if (!mounted) return;
    if (auth.status == AuthStatus.linked) {
      // Collapse the whole save flow (this screen + email entry + the sheet)
      // back to the results screen; it reacts to the `linked` status there.
      Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.results));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final auth = context.watch<AuthController>();
    final verifying = auth.status == AuthStatus.verifying;
    final remaining = auth.resendSecondsRemaining;
    final email = auth.pendingEmail ?? '';

    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        leading: BackButton(color: ec.ink),
        backgroundColor: ec.yellow,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Mascot(mood: MascotMood.idle, size: 72),
              const SizedBox(height: 20),
              Text(
                'Check your email',
                style: AppTypography.displayS.copyWith(color: ec.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Enter the 6-digit code we sent to ',
                  style: AppTypography.body.copyWith(color: ec.inkSoft),
                  children: [
                    TextSpan(
                      text: email,
                      style: AppTypography.body.copyWith(color: ec.ink),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (auth.errorMessage != null) ...[
                Text(
                  auth.errorMessage!,
                  style: AppTypography.meta.copyWith(color: ec.bad),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              OtpInput(enabled: !verifying, onComplete: _onComplete),
              const SizedBox(height: 24),
              TextButton(
                onPressed: remaining > 0
                    ? null
                    : () => context.read<AuthController>().resendOtp(),
                child: Text(
                  remaining > 0 ? 'Resend in ${remaining}s' : 'Resend code',
                  style: (remaining > 0
                          ? AppTypography.pixelNumeralS
                          : AppTypography.meta)
                      .copyWith(color: ec.inkSoft),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Wrong email?',
                  style: AppTypography.meta.copyWith(color: ec.inkSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
