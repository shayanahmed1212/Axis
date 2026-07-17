import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';

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
