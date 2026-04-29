import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF23314A)
        : AppTheme.outline.withValues(alpha: 0.9);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/signup'),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF111A2A)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      context.tr('verification_step'),
                      style: const TextStyle(
                        color: AppTheme.primaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppElevations.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EduCollab',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('verify_email'),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email == null
                          ? context.tr('verify_email_no_email')
                          : context.tr(
                              'verify_email_subtitle',
                              params: {'email': email},
                            ),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('verification_tip'),
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: context.tr('code_hint'),
                        prefixIcon: const Icon(Icons.shield_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF111A2A)
                            : AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF23314A)
                              : AppTheme.outline.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Text(
                        context.tr('secure_access'),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
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
                                    _error = context.tr(
                                      'invalid_or_expired_code',
                                    );
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/login'),
                        child: Text(context.tr('login')),
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
