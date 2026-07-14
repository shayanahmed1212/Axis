// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/app_text_field.dart';
import 'package:axis/core/utils/validators.dart';
import 'package:axis/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:axis/features/auth/presentation/widgets/password_field.dart';
import 'package:axis/features/auth/application/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(authControllerProvider).register(_emailController.text.trim(), _passwordController.text, displayName: _nameController.text.trim());
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.blockSage,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTokens.radiusXl),
                bottomRight: Radius.circular(AppTokens.radiusXl),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Axis', style: AppTypography.display(size: 32, weight: 700, color: AppColors.blockSageText)),
                const SizedBox(height: 8),
                Text('Get started.', style: AppTypography.body(size: 15, weight: 500, color: AppColors.blockSageText.withOpacity(0.7))),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    AuthErrorBanner(message: _errorMessage, onDismiss: () => setState(() => _errorMessage = null)),
                    AppTextField(label: 'Full Name', hintText: 'Your name', controller: _nameController, validator: Validators.validateName),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Email', hintText: 'you@example.com', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.validateEmail),
                    const SizedBox(height: 16),
                    PasswordField(controller: _passwordController),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Confirm Password', hintText: 'Re-enter password', controller: _confirmPasswordController, obscureText: true, validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text)),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.accentInk,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accentInk)))
                            : Text('Create account', style: AppTypography.body(size: AppTypography.buttonSize, weight: AppTypography.buttonWeight, color: AppColors.accentInk)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: AppTypography.body(size: 13, weight: 400, color: AppColors.inkMuted)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Sign in', style: AppTypography.body(size: 13, weight: 600, color: const Color(0xFFB08900))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
