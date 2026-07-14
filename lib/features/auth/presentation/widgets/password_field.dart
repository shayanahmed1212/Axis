// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/utils/validators.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordField({super.key, this.controller, this.validator});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Password',
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight(AppTypography.bodyWeight),
              color: AppColors.inkMuted,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          validator: widget.validator ?? Validators.validatePassword,
          style: GoogleFonts.getFont(
            AppTypography.bodyFamily,
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight(AppTypography.bodyWeight),
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight(AppTypography.bodyWeight),
              color: AppColors.inkSubtle,
            ),
            suffixIcon: IconButton(
              icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.inkSubtle),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            filled: true,
            fillColor: AppColors.surface1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
