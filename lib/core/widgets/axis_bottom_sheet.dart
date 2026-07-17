// AxisBottomSheet — Reusable bottom sheet wrapper for stacked sheet pattern
// surface2 background, 24px top radius, drag handle bar, title row with close button
// ignore_for_file: use_null_aware_elements, sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';

class AxisBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showDragHandle;
  final bool isDismissible;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? contentPadding;

  const AxisBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showDragHandle = true,
    this.isDismissible = true,
    this.onClose,
    this.contentPadding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool showDragHandle = true,
    bool isDismissible = true,
    VoidCallback? onClose,
    EdgeInsetsGeometry? contentPadding,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AxisBottomSheet(
        title: title,
        child: child,
        actions: actions,
        showDragHandle: showDragHandle,
        isDismissible: isDismissible,
        onClose: onClose,
        contentPadding: contentPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.sheetTopRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, -12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle) ...[
                const SizedBox(height: AppTokens.xs),
                Container(
                  width: AppTokens.sheetDragHandleWidth,
                  height: AppTokens.sheetDragHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppTokens.sm),
              ],

              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTokens.sheetPadding),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.sheetTitle(color: AppColors.ink),
                    ),
                    const Spacer(),
                    if (actions != null) ...actions!,
                    if (onClose != null || actions == null)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.ink,
                          size: 24,
                        ),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppTokens.md),

              Container(
                height: 1,
                color: AppColors.canvas,
                margin: EdgeInsets.symmetric(horizontal: AppTokens.sheetPadding),
              ),

              const SizedBox(height: AppTokens.md),

              Padding(
                padding: contentPadding ??
                    EdgeInsets.symmetric(horizontal: AppTokens.sheetPadding),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Convenience extension for showing stacked sheets
extension AxisBottomSheetExtension on BuildContext {
  Future<T?> showAxisBottomSheet<T>({
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool showDragHandle = true,
    bool isDismissible = true,
    VoidCallback? onClose,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return AxisBottomSheet.show<T>(
      context: this,
      title: title,
      child: child,
      actions: actions,
      showDragHandle: showDragHandle,
      isDismissible: isDismissible,
      onClose: onClose,
      contentPadding: contentPadding,
    );
  }
}

// Specialized sheet for confirmation dialogs
class AxisConfirmationSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AxisConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AxisConfirmationSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = confirmColor ?? AppColors.accent;

    return AxisBottomSheet(
      title: title,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.sheetPadding,
        vertical: AppTokens.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.body(color: AppColors.ink),
          ),
          const SizedBox(height: AppTokens.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: AppTokens.md),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: effectiveConfirmColor,
                    foregroundColor: AppColors.ink,
                  ),
                  onPressed: () {
                    onConfirm?.call();
                    Navigator.of(context).pop(true);
                  },
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
