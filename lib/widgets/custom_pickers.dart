// Standalone dialog pickers for category, date, priority, and time.
//
// Each returns its selected value via [Navigator.pop] so the caller
// (e.g. [AddTaskSheet]) can react to the choice in a `.then()` callback.
// The category picker also supports a "Create New" flow: popping
// `'__create_new__'` signals the caller to push the [CreateCategorySheet]
// and pass the newly created category's ID back into the selection.
//
// The time picker uses [ListWheelScrollView] with a magnifier effect for
// a native-iOS-style wheel experience. Hours, minutes, and AM/PM are
// separate scroll columns.
import 'package:flutter/material.dart';
import 'package:axis/theme/app_theme.dart';
import 'package:axis/models/category.dart';

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

Future<int?> showCustomPriorityPicker({
  required BuildContext context,
  int currentPriority = 5,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _CustomPriorityPickerDialog(currentPriority: currentPriority),
  );
}

class _CustomPriorityPickerDialog extends StatefulWidget {
  final int currentPriority;

  const _CustomPriorityPickerDialog({required this.currentPriority});

  @override
  State<_CustomPriorityPickerDialog> createState() => _CustomPriorityPickerDialogState();
}

class _CustomPriorityPickerDialogState extends State<_CustomPriorityPickerDialog> {
  late int _selected;

  static Color _priorityColor(int priority) {
    if (priority <= 2) return const Color(0xFF4CAF50);
    if (priority <= 4) return const Color(0xFFFFEB3B);
    if (priority <= 7) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.currentPriority;
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
              const Text(
                'Task Priority',
                style: TextStyle(
                  color: AppColors.inkMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.inkMuted, height: 1, thickness: 0.5),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(10, (index) {
                      final p = index + 1;
                      final isSelected = _selected == p;
                      final color = _priorityColor(p);
                      return GestureDetector(
                        onTap: () {
                          _selected = p;
                          setDialogState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: isSelected ? AppColors.onPrimary : color,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$p',
                                style: TextStyle(
                                  color: isSelected ? AppColors.onPrimary : AppColors.inkMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.mutedLavender, fontSize: 13),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (_) => _CustomTimePickerDialog(initialTime: initialTime),
  );
}

class _CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay? initialTime;

  const _CustomTimePickerDialog({this.initialTime});

  @override
  State<_CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<_CustomTimePickerDialog> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;
  late bool _isPM;
  late int _selectedHourIdx;
  late int _selectedMinuteIdx;
  late int _selectedAmPmIdx;

  static const _hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  static const _minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime ?? const TimeOfDay(hour: 9, minute: 0);
    _isPM = time.hour >= 12;
    _selectedHourIdx = time.hour % 12 == 0 ? 0 : time.hour % 12;
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHourIdx,
    );
    final minuteIndex = _minutes.indexOf(time.minute);
    _selectedMinuteIdx = minuteIndex >= 0 ? minuteIndex : 0;
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinuteIdx,
    );
    _selectedAmPmIdx = time.hour >= 12 ? 1 : 0;
    _ampmController = FixedExtentScrollController(
      initialItem: _selectedAmPmIdx,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  TimeOfDay _selectedTime() {
    final displayHour = _hours[_hourController.selectedItem];
    final hour = _isPM
        ? (displayHour == 12 ? 12 : displayHour + 12)
        : (displayHour == 12 ? 0 : displayHour);
    final minute = _minutes[_minuteController.selectedItem];
    return TimeOfDay(hour: hour, minute: minute);
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
              const Text(
                'Choose Time',
                style: TextStyle(
                  color: AppColors.inkMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Color(0xFF1E1E1E), height: 1, thickness: 1),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: wheelHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCard(
                      width: 60,
                      child: _WheelColumn(
                        controller: _hourController,
                        items: _hours.map((h) => h.toString().padLeft(2, '0')).toList(),
                        selectedIndex: _selectedHourIdx,
                        onChanged: (index) => setState(() => _selectedHourIdx = index),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildCard(
                      width: 60,
                      child: _WheelColumn(
                        controller: _minuteController,
                        items: _minutes.map((m) => m.toString().padLeft(2, '0')).toList(),
                        selectedIndex: _selectedMinuteIdx,
                        onChanged: (index) => setState(() => _selectedMinuteIdx = index),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      width: 70,
                      child: _WheelColumn(
                        controller: _ampmController,
                        items: const ['AM', 'PM'],
                        selectedIndex: _selectedAmPmIdx,
                        onChanged: (index) => setState(() {
                          _selectedAmPmIdx = index;
                          _isPM = index == 1;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.mutedLavender, fontSize: 13),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedTime()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const double wheelHeight = 96;

  Widget _buildCard({required double width, required Widget child}) {
    return Container(
      width: width,
      height: wheelHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF313131),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  const _WheelColumn({
    required this.controller,
    required this.items,
    required this.onChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _CustomTimePickerDialogState.wheelHeight,
      child: ListWheelScrollView(
        controller: controller,
        itemExtent: 38,
        diameterRatio: 1.5,
        useMagnifier: true,
        magnification: 1.15,
        onSelectedItemChanged: (index) => onChanged(index),
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return Align(
            alignment: Alignment.center,
            child: Text(
              items[index],
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.12),
                fontSize: isSelected ? 22 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }
}
