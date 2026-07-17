import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCard(
                      width: 52,
                      child: _WheelColumn(
                        controller: _hourController,
                        items: _hours.map((h) => h.toString().padLeft(2, '0')).toList(),
                        selectedIndex: _selectedHourIdx,
                        onChanged: (index) => setState(() => _selectedHourIdx = index),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Center(
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildCard(
                      width: 52,
                      child: _WheelColumn(
                        controller: _minuteController,
                        items: _minutes.map((m) => m.toString().padLeft(2, '0')).toList(),
                        selectedIndex: _selectedMinuteIdx,
                        onChanged: (index) => setState(() => _selectedMinuteIdx = index),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildCard(
                      width: 64,
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

  static const double wheelHeight = 140;

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
        itemExtent: 46,
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
                fontSize: isSelected ? 24 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }
}
