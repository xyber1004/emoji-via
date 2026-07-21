import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import '../../application/controllers/auth_controller.dart';
import '../../domain/entities/auth_status.dart';
import '../widgets/email_field.dart';
import 'otp_verify_screen.dart';

class EmailEntryScreen extends StatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  State<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    auth.clearError();
    await auth.sendOtp(_controller.text);
    if (!mounted) return;
    if (auth.status == AuthStatus.otpSent) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OtpVerifyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final auth = context.watch<AuthController>();
    final sending = auth.status == AuthStatus.sending;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your email?",
                style: AppTypography.displayS.copyWith(color: ec.ink),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll send you a code to save your streak.",
                style: AppTypography.body.copyWith(color: ec.inkSoft),
              ),
              const SizedBox(height: 24),
              EmailField(
                controller: _controller,
                enabled: !sending,
                errorText: auth.errorMessage,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: sending ? 'Sending…' : 'Send code',
                  disabled: sending,
                  onTap: _submit,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: 'Cancel',
                  variant: ChunkyButtonVariant.ghost,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
