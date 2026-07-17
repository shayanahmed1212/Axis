// Settings Screen — App color, typography, language, import
// ignore_for_file: use_null_aware_elements, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/bottom_nav_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Color _selectedAccent = AppColors.primary;
  String _selectedFont = 'Poppins';
  String _selectedLanguage = 'English';

  final List<_AccentOption> _accentOptions = [
    _AccentOption('Purple', const Color(0xFF6C63FF)),
    _AccentOption('Blue', const Color(0xFF4D96FF)),
    _AccentOption('Teal', const Color(0xFF4ECDC4)),
    _AccentOption('Pink', const Color(0xFFFF6B9D)),
    _AccentOption('Orange', const Color(0xFFFF9F43)),
    _AccentOption('Green', const Color(0xFF6BCB77)),
  ];

  final List<_FontOption> _fontOptions = [
    _FontOption('Poppins', 'Poppins'),
    _FontOption('Inter', 'Inter'),
    _FontOption('DM Sans', 'DM Sans'),
    _FontOption('Plus Jakarta Sans', 'Plus Jakarta Sans'),
  ];

  final List<_LanguageOption> _languageOptions = [
    _LanguageOption('English', 'English'),
    _LanguageOption('Spanish', 'Español'),
    _LanguageOption('French', 'Français'),
    _LanguageOption('German', 'Deutsch'),
    _LanguageOption('Japanese', '日本語'),
    _LanguageOption('Korean', '한국어'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTypography.screenTitle(color: AppColors.ink)),
        centerTitle: true,
        backgroundColor: AppColors.canvasDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTokens.pageMargin),
          children: [
            _SettingsSection(
              title: 'Settings',
              items: [
                _SettingsRow(
                  icon: Icons.palette_rounded,
                  label: 'Change app color',
                  onTap: () => _showAccentPicker(context),
                ),
                _SettingsRow(
                  icon: Icons.font_download_rounded,
                  label: 'Change app typography',
                  onTap: () => _showFontPicker(context),
                ),
                _SettingsRow(
                  icon: Icons.language_rounded,
                  label: 'Change app language',
                  onTap: () => _showLanguagePicker(context),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.xl),
            _SettingsSection(
              title: 'Import',
              items: [
                _SettingsRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'Import from Google calendar',
                  onTap: () => _showComingSoon(context, 'Google Calendar Import'),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.xxl + AppTokens.xl),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }

  void _showAccentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTokens.lg),
            Text('Choose Accent Color', style: AppTypography.sheetTitle(color: AppColors.ink)),
            const SizedBox(height: AppTokens.xl),
            Wrap(
              spacing: AppTokens.md,
              runSpacing: AppTokens.md,
              alignment: WrapAlignment.center,
              children: _accentOptions.map((option) {
                final isSelected = _selectedAccent.value == option.color.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAccent = option.color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: option.color,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(
                        color: isSelected ? AppColors.ink : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: option.color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: AppColors.ink, size: 28)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTokens.lg),
            Text('Choose Typography', style: AppTypography.sheetTitle(color: AppColors.ink)),
            const SizedBox(height: AppTokens.xl),
            ..._fontOptions.map((option) {
              final isSelected = _selectedFont == option.family;
              return ListTile(
                title: Text(
                  option.name,
                  style: GoogleFonts.getFont(option.family,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedFont = option.family);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTokens.lg),
            Text('Choose Language', style: AppTypography.sheetTitle(color: AppColors.ink)),
            const SizedBox(height: AppTokens.xl),
            ..._languageOptions.map((option) {
              final isSelected = _selectedLanguage == option.name;
              return ListTile(
                title: Text(option.name, style: AppTypography.body(color: AppColors.ink)),
                subtitle: Text(option.native, style: AppTypography.meta(color: AppColors.inkMuted)),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = option.name);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsRow> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.sm),
          child: Text(
            title,
            style: AppTypography.sectionLabel(color: AppColors.inkMuted),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(height: 1, color: AppColors.hairline),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.cardPadding, vertical: AppTokens.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.inkMuted, size: 22),
            const SizedBox(width: AppTokens.md),
            Expanded(
              child: Text(label, style: AppTypography.body(color: AppColors.ink)),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 22),
          ],
        ),
      ),
    );
  }
}



// Option data classes
class _AccentOption {
  final String name;
  final Color color;
  const _AccentOption(this.name, this.color);
}

class _FontOption {
  final String name;
  final String family;
  const _FontOption(this.name, this.family);
}

class _LanguageOption {
  final String name;
  final String native;
  const _LanguageOption(this.name, this.native);
}
