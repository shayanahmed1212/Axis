// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

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
            style: AppTypography.meta(color: AppColors.ink),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          validator: widget.validator,
          style: AppTypography.body(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: AppTypography.body(color: AppColors.inkMuted),
            suffixIcon: IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.ink,
                size: 20,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          ),
        ),
      ],
    );
  }
}
