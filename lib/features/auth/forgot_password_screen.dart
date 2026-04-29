import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import 'package:provider/provider.dart';
import 'auth_notifier.dart';
import '../../core/localization/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF23314A)
        : AppTheme.outline.withValues(alpha: 0.9);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF111A2A)
                      : AppTheme.surfaceLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  side: BorderSide(color: borderColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('forgot_password_title'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('forgot_password_subtitle'),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppElevations.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('email_address'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: context.tr('email_hint'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.loading
                            ? null
                            : () async {
                                final email = _controller.text.trim();
                                if (email.isEmpty) return;
                                await auth.sendPasswordReset(email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr('check_email_for_reset'),
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          auth.loading
                              ? context.tr('sending')
                              : context.tr('send_reset_link'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('reset_link_valid'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
