// Category management screen — grid of category tiles with create/edit/delete.
// Uses [categoriesStreamProvider] for real-time updates so newly created
// categories appear immediately when returning from the create sheet.
// Delete is guarded by [AxisConfirmationSheet] to prevent accidental loss.
// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/widgets/axis_bottom_sheet.dart';

import 'package:axis/services/category_service.dart';
import 'package:axis/models/category.dart';
import 'package:axis/widgets/custom_sheets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.pageMargin, vertical: AppTokens.sm),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: AppColors.ink, size: 24),
                ),
                const SizedBox(width: AppTokens.md),
                Expanded(
                  child: Text(
                    'Categories',
                    style: AppTypography.screenTitle(color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceCard,
                    child: Icon(Icons.person_rounded, color: AppColors.ink, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTokens.pageMargin),
          child: Column(
            children: [
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => _CategoriesGrid(
                    categories: categories,
                    onCreate: () => _showCreateSheet(context, ref),
                    onEdit: (category) => _showEditSheet(context, ref, category),
                    onDelete: (category) => _confirmDelete(context, ref, category),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load categories',
                      style: AppTypography.body(color: AppColors.inkMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('Add Category', style: AppTypography.buttonLabel()),
                  onPressed: () => _showCreateSheet(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CreateCategorySheet()),
    );
    if (result != null) {
      ref.invalidate(categoriesStreamProvider);
    }
  }

  Future<void> _showEditSheet(BuildContext context, WidgetRef ref, Category category) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CreateCategorySheet(editingCategory: category),
      ),
    );
    if (result != null) {
      ref.invalidate(categoriesStreamProvider);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category category) async {
    final confirmed = await AxisConfirmationSheet.show(
      context: context,
      title: 'Delete Category',
      message: 'Delete "${category.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.primary,
    );

    if (confirmed) {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(category.id);
    }
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onCreate;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  const _CategoriesGrid({
    required this.categories,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = [...categories];
    items.add(Category.empty.copyWith(id: '__create_new__'));

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppTokens.sm,
        mainAxisSpacing: AppTokens.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final category = items[index];
        if (category.id == '__create_new__') {
          return _CreateNewTile(onTap: onCreate);
        }
        return _CategoryTile(
          category: category,
          onEdit: () => onEdit(category),
          onDelete: () => onDelete(category),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = category.backgroundColor;
    final fgColor = category.foregroundColor;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusSm)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.iconData, color: fgColor, size: 26),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        category.name,
                        style: AppTypography.body(weight: 500, color: fgColor, size: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: fgColor.withOpacity(0.15),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppTokens.radiusSm),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.edit_rounded, color: fgColor, size: 16),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: fgColor.withOpacity(0.2)),
                Expanded(
                  child: InkWell(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.delete_rounded, color: fgColor, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateNewTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateNewTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        padding: const EdgeInsets.all(AppTokens.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 28),
            const SizedBox(height: AppTokens.sm),
            Text(
              'Create New',
              style: AppTypography.body(
                weight: 500,
                color: AppColors.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
