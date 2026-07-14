// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/primary_button.dart';
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(authControllerProvider);
      await controller.register(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _nameController.text.trim(),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Create Account',
                  style: GoogleFonts.getFont(
                    AppTypography.displayFamily,
                    fontSize: AppTypography.displaySize,
                    fontWeight: FontWeight(AppTypography.displayWeight),
                    letterSpacing: AppTypography.displayLetterSpacing,
                    color: AppColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your center.',
                  style: GoogleFonts.getFont(
                    AppTypography.bodyFamily,
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight(AppTypography.bodyWeight),
                    color: AppColors.inkMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                AuthErrorBanner(
                  message: _errorMessage,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                PasswordField(controller: _passwordController),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                ),
                const SizedBox(height: 24),
                PrimaryButton(text: 'Create Account', onPressed: _register, isLoading: _isLoading, isFullWidth: true),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.getFont(
                        AppTypography.bodyFamily,
                        fontSize: AppTypography.bodySmSize,
                        fontWeight: FontWeight(AppTypography.bodySmWeight),
                        color: AppColors.inkMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.getFont(
                          AppTypography.bodyFamily,
                          fontSize: AppTypography.bodySmSize,
                          fontWeight: FontWeight(AppTypography.headlineWeight),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
