import 'package:flutter/material.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/categories/domain/category.dart';
import 'package:axis/features/categories/presentation/screens/create_category_sheet.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/widgets/dialogs/custom_date_picker.dart';
import 'package:axis/widgets/dialogs/custom_time_picker.dart';
import 'package:axis/widgets/dialogs/custom_category_picker.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? editingTask;
  final List<Category> categories;
  final DateTime? initialDate;
  final ValueChanged<Task> onSave;

  const AddTaskSheet({
    super.key,
    this.editingTask,
    required this.categories,
    this.initialDate,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Task? editingTask,
    required List<Category> categories,
    DateTime? initialDate,
    required ValueChanged<Task> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        editingTask: editingTask,
        categories: categories,
        initialDate: initialDate,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategoryId;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    final task = widget.editingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedDate = task?.dueDate ?? widget.initialDate;
    _selectedTime = task?.dueDate != null
        ? TimeOfDay.fromDateTime(task!.dueDate!)
        : (widget.initialDate != null
            ? const TimeOfDay(hour: 9, minute: 0)
            : null);
    _selectedCategoryId = task?.categoryId;
    _selectedPriority = task?.priority ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF272727),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLg),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppTokens.lg,
            right: AppTokens.lg,
            top: AppTokens.lg,
            bottom: bottomInset + AppTokens.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: AppTypography.screenTitle(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Add Task',
                  hintStyle: AppTypography.screenTitle(color: AppColors.inkMuted),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppTokens.sm),

              TextField(
                controller: _descriptionController,
                style: AppTypography.body(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: AppTypography.body(color: AppColors.inkMuted),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 2,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: AppTokens.xl),

              Row(
                children: [
                  _IconButton(
                    icon: Icons.timer_outlined,
                    active: _selectedDate != null,
                    activeColor: AppColors.primary,
                    onTap: () => _showDateTimeSheet(context),
                  ),
                  const SizedBox(width: AppTokens.sm),
                  _IconButton(
                    icon: Icons.local_offer_outlined,
                    active: _selectedCategoryId != null,
                    activeColor: _getCategoryColor(_selectedCategoryId) ?? AppColors.primary,
                    onTap: () => _showCategorySheet(context),
                  ),
                  const SizedBox(width: AppTokens.sm),
                  _IconButton(
                    icon: Icons.flag_outlined,
                    active: true,
                    activeColor: _priorityColor(_selectedPriority),
                    onTap: () => _showPrioritySheet(context),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _titleController.text.trim().isNotEmpty
                        ? () {
                            final task = Task(
                              id: widget.editingTask?.id ?? '',
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim().isEmpty
                                  ? null
                                  : _descriptionController.text.trim(),
                              isCompleted: widget.editingTask?.isCompleted ?? false,
                              priority: _selectedPriority,
                              categoryId: _selectedCategoryId,
                              dueDate: _combineDateTime(_selectedDate, _selectedTime),
                              reminderAt: _combineDateTime(_selectedDate, _selectedTime),
                              subtasks: [],
                              createdAt: widget.editingTask?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            widget.onSave(task);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Icon(
                      Icons.send_outlined,
                      color: _titleController.text.trim().isNotEmpty
                          ? AppColors.primary
                          : AppColors.primaryDim,
                      size: 24,
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

  static DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    final timeOfDay = time ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  Color? _getCategoryColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = widget.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category.empty,
    );
    return cat.id.isEmpty ? null : cat.color;
  }

  static Color _priorityColor(int priority) {
    if (priority <= 2) return const Color(0xFF4CAF50);
    if (priority <= 4) return const Color(0xFFFFEB3B);
    if (priority <= 7) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  void _showDateTimeSheet(BuildContext context) async {
    final date = await showCustomDatePicker(
      context: context,
      initialDate: _selectedDate,
    );
    if (date == null || !mounted) return;

    final time = await showCustomTimePicker(
      context: context, // ignore: use_build_context_synchronously
      initialTime: _selectedTime,
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  void _showCategorySheet(BuildContext context) {
    showCustomCategoryPicker(
      context: context,
      categories: widget.categories,
      currentSelection: _selectedCategoryId,
    ).then((categoryId) {
      if (!mounted) return;
      if (categoryId == '__create_new__') {
        Navigator.of(context).push<String>( // ignore: use_build_context_synchronously
          MaterialPageRoute(
            builder: (_) => const CreateCategorySheet(),
          ),
        ).then((createdId) {
          if (!mounted) return;
          if (createdId != null) {
            setState(() => _selectedCategoryId = createdId);
          } else {
            _showCategorySheet(context); // ignore: use_build_context_synchronously
          }
        });
        return;
      }
      if (categoryId != null) {
        setState(() => _selectedCategoryId = categoryId);
      }
    });
  }

  void _showPrioritySheet(BuildContext context) {
    var selected = _selectedPriority;
    showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(10, (index) {
                          final p = index + 1;
                          final isSelected = selected == p;
                          final color = _priorityColor(p);
                          return GestureDetector(
                            onTap: () {
                              selected = p;
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
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF8A8FD9), fontSize: 13),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(selected),
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
          },
        );
      },
    ).then((result) {
      if (result != null && mounted) {
        setState(() => _selectedPriority = result);
      }
    });
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: active ? activeColor : AppColors.inkMuted,
        size: 24,
      ),
    );
  }
}
