// Forgot Password — blockPeach hero per spec section 5.4
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
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
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // blockPeach hero panel
                Container(
                  padding: const EdgeInsets.all(AppTokens.xl),
                  decoration: BoxDecoration(
                    color: AppColors.blockPeach,
                    borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 56,
                        color: AppColors.blockPeachText,
                      ),
                      const SizedBox(height: AppTokens.md),
                      Text(
                        'Reset Password',
                        style: GoogleFonts.sora(
                          fontSize: AppTypography.screenTitleSize,
                          fontWeight: FontWeight(AppTypography.screenTitleWeight),
                          letterSpacing: AppTypography.screenTitleTracking,
                          color: AppColors.blockPeachText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.xs),
                      Text(
                        "Enter your email and we'll send you a reset link",
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight(AppTypography.bodyWeight),
                          color: AppColors.blockPeachText.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTokens.xl),

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

                const SizedBox(height: AppTokens.lg),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.accentInk,
                      disabledBackgroundColor: AppColors.accent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentInk),
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: GoogleFonts.inter(
                              fontSize: AppTypography.buttonSize,
                              fontWeight: FontWeight(AppTypography.buttonWeight),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppTokens.md),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Login',
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.buttonSize,
                      fontWeight: FontWeight(AppTypography.buttonWeight),
                      color: Color(0xFFB08900),
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
