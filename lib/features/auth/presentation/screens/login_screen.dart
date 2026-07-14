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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(authControllerProvider);
      await controller.signIn(_emailController.text.trim(), _passwordController.text);
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
                  'Welcome Back',
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
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.getFont(
                        AppTypography.bodyFamily,
                        fontSize: AppTypography.bodySmSize,
                        fontWeight: FontWeight(AppTypography.buttonWeight),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(text: 'Sign In', onPressed: _login, isLoading: _isLoading, isFullWidth: true),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.getFont(
                        AppTypography.bodyFamily,
                        fontSize: AppTypography.bodySmSize,
                        fontWeight: FontWeight(AppTypography.bodySmWeight),
                        color: AppColors.inkMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
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
