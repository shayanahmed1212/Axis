import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/categories/data/category_repository.dart';
import 'package:axis/features/categories/domain/category.dart';

class CreateCategorySheet extends ConsumerStatefulWidget {
  final Category? editingCategory;

  const CreateCategorySheet({
    super.key,
    this.editingCategory,
  });

  @override
  ConsumerState<CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<CreateCategorySheet> {
  late final TextEditingController _nameController;
  String? _selectedIcon;
  late Color _selectedColor;
  bool _iconPickerOpen = false;

  static const _paletteColors = [
    Color(0xFF8586E7), // Soft Lavender
    Color(0xFFFF8080), // Soft Coral
    Color(0xFFFFD080), // Soft Amber
    Color(0xFF9EE7E0), // Soft Teal
    Color(0xFFB5E6A8), // Soft Sage
    Color(0xFFF0B5DD), // Soft Pink
    Color(0xFFD4A9EB), // Soft Purple
    Color(0xFFA4D5F0), // Soft Sky
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingCategory?.name ?? '');
    _selectedIcon = widget.editingCategory?.iconName;
    _selectedColor = widget.editingCategory?.color ?? _paletteColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty && _selectedIcon != null;

  Future<void> _save() async {
    if (!_isValid) return;

    final hex = _colorToHex(_selectedColor);
    final category = Category(
      id: widget.editingCategory?.id ?? '',
      name: _nameController.text.trim(),
      iconName: _selectedIcon!,
      colorHex: hex,
      userId: '',
      createdAt: widget.editingCategory?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.editingCategory != null) {
      await ref.read(categoryRepositoryProvider).updateCategory(category);
      if (mounted) Navigator.of(context).pop(category.id);
    } else {
      final created = await ref.read(categoryRepositoryProvider).createCategory(category);
      if (mounted) Navigator.of(context).pop(created.id);
    }
  }

  String _colorToHex(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    return '#${hex.substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            'Create new category',
            style: AppTypography.screenTitle(color: AppColors.ink),
          ),
        ),
        centerTitle: false,
        toolbarHeight: 48,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category name :', style: AppTypography.meta(color: Color(0xFFA2A2A2))),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: AppTypography.body(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: AppTypography.body(color: AppColors.inkMuted),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2C2C38), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2C2C38), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                counterStyle: AppTypography.meta(color: AppColors.inkMuted, size: 11),
              ),
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            Text('Category icon :', style: AppTypography.meta(color: Color(0xFFA2A2A2))),
            const SizedBox(height: 8),
            if (_selectedIcon == null || _iconPickerOpen)
              _buildIconLibrary()
            else
              _buildSelectedIcon(),

            const SizedBox(height: 24),

            Text('Category color :', style: AppTypography.meta(color: Color(0xFFA2A2A2))),
            const SizedBox(height: 8),
            _buildColorDots(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Cancel', style: AppTypography.sectionLabel(color: Color(0xFF8A8FD9))),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isValid ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.primaryDim,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(
                  widget.editingCategory != null ? 'Save' : 'Create Category',
                  style: AppTypography.buttonLabel(weight: 700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedIcon() {
    return GestureDetector(
      onTap: () => setState(() => _iconPickerOpen = true),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF272727),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Category.availableIcons.contains(_selectedIcon)
                ? _iconFromName(_selectedIcon!)
                : Icons.category_rounded,
            color: AppColors.inkMuted,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildIconLibrary() {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: Category.availableIcons.map((name) {
        final isSelected = _selectedIcon == name;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = name;
              _iconPickerOpen = false;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(
                _iconFromName(name),
                color: isSelected ? AppColors.primary : AppColors.inkMuted,
                size: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorDots() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: _paletteColors.map((color) {
        final isSelected = _selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: AppColors.onPrimary, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'work': return Icons.work_rounded;
      case 'home': return Icons.home_rounded;
      case 'shopping': return Icons.shopping_cart_rounded;
      case 'health': return Icons.favorite_rounded;
      case 'education': return Icons.school_rounded;
      case 'travel': return Icons.flight_rounded;
      case 'finance': return Icons.account_balance_rounded;
      case 'personal': return Icons.person_rounded;
      case 'fitness': return Icons.fitness_center_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'music': return Icons.music_note_rounded;
      case 'art': return Icons.palette_rounded;
      case 'tech': return Icons.developer_mode_rounded;
      case 'sport': return Icons.sports_rounded;
      case 'book': return Icons.book_rounded;
      case 'game': return Icons.videogame_asset_rounded;
      default: return Icons.category_rounded;
    }
  }
}
