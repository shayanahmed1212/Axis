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
import 'package:axis/core/widgets/app_snackbar.dart';
import 'package:axis/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:axis/features/auth/application/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(authControllerProvider);
      await controller.resetPassword(_emailController.text.trim());
      if (mounted) {
        AppSnackbar.show(context, 'Password reset link sent to your email', type: SnackBarType.success);
        context.go('/login');
      }
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
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Reset Password',
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
                  "Enter your email and we'll send you a reset link",
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
                const SizedBox(height: 24),
                PrimaryButton(text: 'Send Reset Link', onPressed: _resetPassword, isLoading: _isLoading, isFullWidth: true),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Login',
                    style: GoogleFonts.getFont(
                      AppTypography.bodyFamily,
                      fontSize: AppTypography.buttonSize,
                      fontWeight: FontWeight(AppTypography.buttonWeight),
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
