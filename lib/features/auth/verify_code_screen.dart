import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import 'auth_notifier.dart';
import '../../core/localization/app_strings.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final email = auth.pendingEmail;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/signup'),
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surfaceLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('verify_email'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email == null
                    ? context.tr('verify_email_no_email')
                    : context.tr(
                        'verify_email_subtitle',
                        params: {'email': email},
                      ),
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppElevations.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ),
                    if (_error != null) const SizedBox(height: 12),
                    Text(
                      context.tr('verification_code'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: context.tr('code_hint'),
                        prefixIcon: const Icon(Icons.shield_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.loading || email == null
                            ? null
                            : () async {
                                setState(() => _error = null);
                                final code = _codeController.text.trim();
                                if (code.isEmpty) {
                                  setState(
                                    () => _error = context.tr(
                                      'enter_verification_code',
                                    ),
                                  );
                                  return;
                                }
                                try {
                                    await auth.verifySignUp(code);
                                    if (!context.mounted) return;
                                    context.go('/login');
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    setState(() {
                                      _error = context.tr('invalid_or_expired_code');
                                    });
                                  }
                                },
                        child: Text(
                          auth.loading
                              ? context.tr('verifying')
                              : context.tr('confirm_code'),
                        ),
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
