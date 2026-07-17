// Email/password login with an optional biometric prompt after successful
// sign-in. Uses [authControllerProvider] for the actual Firebase call and
// [LocalAuthentication] for device-level fingerprint / face unlock.
// Social sign-in buttons are stubs — shown to communicate the intended
// feature set but throw "coming soon" snackbars.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/widgets/ui_elements.dart';
import 'package:axis/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showBiometricPrompt();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: AppTypography.body(color: AppColors.ink)),
            backgroundColor: AppColors.surfaceCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showBiometricPrompt() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate || !mounted) {
        if (mounted) context.go('/');
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use biometrics to sign in to Axis',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (mounted) {
        if (authenticated) {
          context.go('/');
        } else {
          context.go('/');
        }
      }
    } catch (_) {
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      appBar: AppBar(
        backgroundColor: AppColors.canvasDark,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/splash'),
        ),
        title: Text(
          'Login',
          style: AppTypography.screenTitle(weight: 600, size: 24, color: AppColors.ink),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.pageMargin),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  AppTokens.pageMargin * 2,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTokens.xl),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppTokens.md),

                        // Password field
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.ink,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppTokens.xs),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: Pressable(
                            onTap: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.meta(
                                color: AppColors.primary,
                                weight: 600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTokens.xl),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithEmail,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.onPrimary,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text('Login', style: AppTypography.buttonLabel()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.xl),

                  // "or" divider with hairline
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.hairline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTokens.md),
                        child: Text(
                          'or',
                          style: AppTypography.meta(color: AppColors.inkMuted),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.hairline)),
                    ],
                  ),

                  const SizedBox(height: AppTokens.lg),

                  // Login with Google
                  _SocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Login with Google',
                    onTap: () => _showComingSoon('Google Sign-In'),
                  ),

                  const SizedBox(height: AppTokens.md),

                  // Login with Apple
                  _SocialButton(
                    icon: Icons.apple,
                    label: 'Login with Apple',
                    onTap: () => _showComingSoon('Apple Sign-In'),
                  ),

                  const Spacer(flex: 1),

                  // Switch to register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTypography.body(color: AppColors.inkMuted),
                      ),
                      Pressable(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Register',
                          style: AppTypography.body(
                            color: AppColors.primary,
                            weight: 600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTokens.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon', style: AppTypography.body(color: AppColors.ink)),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: AppColors.ink),
      label: Text(label, style: AppTypography.buttonLabel(color: AppColors.ink)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.hairline, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),
    );
  }
}
