import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _CustomDatePickerDialog(initialDate: initialDate),
  );
}

class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;

  const _CustomDatePickerDialog({this.initialDate});

  @override
  State<_CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;

  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF272727),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              const Divider(color: AppColors.inkMuted, height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              _buildWeekdayRow(),
              const SizedBox(height: 8),
              _buildDayGrid(),
              const SizedBox(height: 16),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1)),
          child: const Icon(Icons.chevron_left, color: AppColors.inkMuted, size: 20),
        ),
        Column(
          children: [
            Text(
              _months[_viewMonth.month - 1],
              style: const TextStyle(
                color: AppColors.inkMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${_viewMonth.year}',
              style: const TextStyle(color: AppColors.inkMuted, fontSize: 10),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1)),
          child: const Icon(Icons.chevron_right, color: AppColors.inkMuted, size: 20),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.asMap().entries.map((e) {
        final isWeekend = e.key == 0 || e.key == 6;
        return SizedBox(
          width: 32,
          child: Text(
            e.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isWeekend ? const Color(0xFFFF4949) : AppColors.inkMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid() {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final lastDay = DateTime(_viewMonth.year, _viewMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;
    final daysInPrevMonth = DateTime(_viewMonth.year, _viewMonth.month, 0).day;

    final cells = <Widget>[];

    for (int i = firstWeekday - 1; i >= 0; i--) {
      cells.add(_DayCell(day: daysInPrevMonth - i, isOtherMonth: true));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final isSelected = i == _selectedDate.day &&
          _viewMonth.month == _selectedDate.month &&
          _viewMonth.year == _selectedDate.year;
      cells.add(_DayCell(
        day: i,
        isSelected: isSelected,
        onTap: () =>
            setState(() => _selectedDate = DateTime(_viewMonth.year, _viewMonth.month, i)),
      ));
    }

    final remaining = 42 - cells.length;
    for (int i = 1; i <= remaining; i++) {
      cells.add(_DayCell(day: i, isOtherMonth: true));
    }

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: cells,
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.mutedLavender, fontSize: 12)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedDate),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Choose Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isOtherMonth;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    this.isOtherMonth = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: GestureDetector(
        onTap: isOtherMonth ? null : onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected
                  ? AppColors.onPrimary
                  : isOtherMonth ? AppColors.inkFaint : AppColors.inkMuted,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
