import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/categories/domain/category.dart';

Future<String?> showCustomCategoryPicker({
  required BuildContext context,
  required List<Category> categories,
  String? currentSelection,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _CustomCategoryPickerDialog(
      categories: categories,
      selectedId: currentSelection,
    ),
  );
}

class _CustomCategoryPickerDialog extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;

  const _CustomCategoryPickerDialog({
    required this.categories,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF272727),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Category',
                style: AppTypography.sectionLabel(
                    color: AppColors.inkMuted, size: 14, weight: 700),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.inkMuted, height: 1, thickness: 0.5),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  ...categories.map((cat) => _CategoryGridTile(
                        icon: cat.iconData,
                        backgroundColor: cat.backgroundColor,
                        foregroundColor: cat.foregroundColor,
                        label: cat.name,
                        isSelected: cat.id == selectedId,
                        onTap: () => Navigator.of(context).pop(cat.id),
                      )),
                  _CategoryGridTile(
                    icon: Icons.add_rounded,
                    backgroundColor: const Color(0xFF8586E7),
                    foregroundColor: const Color(0xFF1A1F36),
                    label: 'Create New',
                    isCreate: true,
                    onTap: () => Navigator.of(context).pop('__create_new__'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop('__create_new__'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Add Category', style: AppTypography.buttonLabel(weight: 700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final bool isSelected;
  final bool isCreate;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    this.isSelected = false,
    this.isCreate = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isCreate
                  ? backgroundColor.withOpacity(0.2)
                  : isSelected ? AppColors.primary : backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isCreate
                  ? foregroundColor
                  : isSelected ? AppColors.onPrimary : foregroundColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.meta(
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
              size: 11,
              weight: isSelected ? 600 : 400,
            ),
          ),
        ],
      ),
    );
  }
}
