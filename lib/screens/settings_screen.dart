// Settings screen — pickers for accent colour, font family, and language
// each backed by a SharedPreferences provider. "Import from Google Calendar"
// authenticates with Calendar read-only scope, fetches events, saves them
// as tasks, and shows a success badge with the import count.
// ignore_for_file: use_null_aware_elements, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/widgets/bottom_nav_bar.dart';
import 'package:axis/widgets/axis_bottom_sheet.dart';
import 'package:axis/services/settings_providers.dart';
import 'package:axis/services/calendar_service.dart';
import 'package:axis/services/task_service.dart';
import 'package:axis/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isImporting = false;

  static const _accentOptions = [
    ('Purple', Color(0xFF8687E7)),
    ('Blue', Color(0xFF4D96FF)),
    ('Teal', Color(0xFF4ECDC4)),
    ('Pink', Color(0xFFFF6B9D)),
    ('Orange', Color(0xFFFF9F43)),
    ('Green', Color(0xFF6BCB77)),
  ];

  static const _fontOptions = [
    'Poppins',
    'Inter',
    'DM Sans',
    'Plus Jakarta Sans',
  ];

  static const _languageOptions = [
    ('English', 'en'),
    ('Urdu', 'ur'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(ref.watch(localeCodeProvider));
    final accentColor = accentColorFromName(ref.watch(accentColorProvider));
    final currentFont = ref.watch(typographyProvider);
    final currentLocale = ref.watch(localeCodeProvider);
    final localeLabel = _languageOptions.firstWhere(
      (o) => o.$2 == currentLocale, orElse: () => _languageOptions[0]).$1;

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.settings, style: AppTypography.screenTitle(color: AppColors.ink)),
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
              title: l.settings,
              items: [
                _SettingsRow(
                  icon: Icons.palette_rounded,
                  label: l.changeAppColor,
                  trailing: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () => _showAccentPicker(context),
                ),
                _SettingsRow(
                  icon: Icons.font_download_rounded,
                  label: l.changeAppTypography,
                  trailing: Text(currentFont, style: AppTypography.meta(color: AppColors.inkMuted)),
                  onTap: () => _showFontPicker(context),
                ),
                _SettingsRow(
                  icon: Icons.language_rounded,
                  label: l.changeAppLanguage,
                  trailing: Text(localeLabel, style: AppTypography.meta(color: AppColors.inkMuted)),
                  onTap: () => _showLanguagePicker(context),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.xl),
            _SettingsSection(
              title: l.import,
              items: [
                _SettingsRow(
                  icon: Icons.calendar_month_rounded,
                  label: l.importFromGoogleCalendar,
                  trailing: _isImporting
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accentColor,
                          ),
                        )
                      : null,
                  onTap: _isImporting ? null : () => _importFromCalendar(),
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
    final current = ref.read(accentColorProvider);
    AxisBottomSheet.show(
      context: context,
      title: AppLocalizations.of(ref.read(localeCodeProvider)).chooseAccentColor,
      child: Wrap(
        spacing: AppTokens.md,
        runSpacing: AppTokens.md,
        alignment: WrapAlignment.center,
        children: _accentOptions.map((option) {
          final isSelected = option.$1 == current;
          return GestureDetector(
            onTap: () {
              ref.read(accentColorProvider.notifier).set(option.$1);
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: option.$2,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(
                  color: isSelected ? AppColors.ink : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: option.$2.withOpacity(0.4),
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
    );
  }

  void _showFontPicker(BuildContext context) {
    final current = ref.read(typographyProvider);
    AxisBottomSheet.show(
      context: context,
      title: AppLocalizations.of(ref.read(localeCodeProvider)).chooseTypography,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _fontOptions.map((family) {
          final isSelected = family == current;
          return ListTile(
            title: Text(
              family,
              style: GoogleFonts.getFont(family,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(typographyProvider.notifier).set(family);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = ref.read(localeCodeProvider);
    AxisBottomSheet.show(
      context: context,
      title: AppLocalizations.of(ref.read(localeCodeProvider)).chooseLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _languageOptions.map((option) {
          final isSelected = option.$2 == current;
          return ListTile(
            title: Text(option.$1, style: AppTypography.body(color: AppColors.ink)),
            subtitle: Text(option.$2 == 'ur' ? 'اردو' : 'English',
                style: AppTypography.meta(color: AppColors.inkMuted)),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(localeCodeProvider.notifier).set(option.$2);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _importFromCalendar() async {
    setState(() => _isImporting = true);
    try {
      final repository = ref.read(taskRepositoryProvider);
      final service = CalendarImportService(repository);
      final count = await service.importEvents();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? '$count events imported from Google Calendar'
                : 'No new events found',
            style: AppTypography.body(color: AppColors.ink),
          ),
          backgroundColor: AppColors.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Import failed: ${e.toString()}',
            style: AppTypography.body(color: AppColors.ink),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
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
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
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
            if (trailing != null) ...[
              const SizedBox(width: AppTokens.sm),
              trailing!,
            ],
            Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
