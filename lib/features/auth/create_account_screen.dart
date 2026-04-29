import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import 'auth_notifier.dart';
import '../../core/localization/app_strings.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isStudent = true;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final loading = context.watch<AuthNotifier>().loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0F172A) : AppTheme.surface;
    final borderColor = isDark
        ? const Color(0xFF23314A)
        : AppTheme.outline.withValues(alpha: 0.9);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark
                          ? const Color(0xFF172554)
                          : AppTheme.secondaryContainer,
                      isDark ? const Color(0xFF0F172A) : Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppElevations.soft,
                ),
                child: const Center(
                  child: Text(
                    'EduCollab',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'EduCollab',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('join_ecosystem'),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppElevations.soft,
                ),
                child: Row(
                  children: [
                    _roleButton(
                      'Student',
                      Icons.school,
                      _isStudent,
                      () => setState(() => _isStudent = true),
                    ),
                    const SizedBox(width: 6),
                    _roleButton(
                      'Teacher',
                      Icons.record_voice_over,
                      !_isStudent,
                      () => setState(() => _isStudent = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
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
                      context.tr('full_name'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.tr('enter_full_name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('email_address'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: context.tr('email_hint'),
                        prefixIcon: const Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('password'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: context.tr('password_hint'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() => _error = null);
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;
                                if (name.isEmpty ||
                                    email.isEmpty ||
                                    password.length < 6) {
                                  setState(
                                    () => _error = context.tr(
                                      'enter_required_fields',
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  await auth.signUp(
                                    email: email,
                                    password: password,
                                    fullName: name,
                                    role: _isStudent ? 'student' : 'lecturer',
                                  );
                                  if (!context.mounted) return;
                                  context.go('/verify');
                                } catch (_) {
                                  if (!context.mounted) return;
                                  setState(() {
                                    _error =
                                        'Unable to create account. Try again.';
                                  });
                                }
                              },
                        child: Text(
                          loading
                              ? context.tr('creating')
                              : context.tr('create_account'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(context.tr('already_have_account')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.surface : Colors.transparent,
            boxShadow: active ? AppElevations.soft : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
