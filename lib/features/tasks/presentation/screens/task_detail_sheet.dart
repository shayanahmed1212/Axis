// TaskDetailSheet — Large sheet with inline editing, subtasks, delete confirmation
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/features/categories/domain/category.dart';
import 'package:axis/features/categories/presentation/screens/create_category_sheet.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/widgets/dialogs/custom_category_picker.dart';
import 'package:axis/widgets/dialogs/custom_date_picker.dart';
import 'package:axis/widgets/dialogs/custom_priority_picker.dart';
import 'package:axis/widgets/dialogs/custom_time_picker.dart';

class TaskDetailSheet extends StatefulWidget {
  final Task task;
  final List<Category> categories;
  final ValueChanged<Task> onSave;
  final VoidCallback onDelete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.categories,
    required this.onSave,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Task task,
    required List<Category> categories,
    required ValueChanged<Task> onSave,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        categories: categories,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late String _title;
  late String? _description;
  late bool _isCompleted;
  late String? _selectedCategoryId;
  late int _selectedPriority;
  late DateTime? _dueDate;
  late TimeOfDay? _dueTime;
  late List<SubTask> _subtasks;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = task.title;
    _description = task.description;
    _isCompleted = task.isCompleted;
    _selectedCategoryId = task.categoryId;
    _selectedPriority = task.priority;
    _dueDate = task.dueDate;
    _dueTime = task.dueDate != null
        ? TimeOfDay.fromDateTime(task.dueDate!)
        : null;
    _subtasks = task.subtasks.toList();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 32,
            offset: Offset(0, -12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: X close + repeat icon
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.sheetPadding),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.ink, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 20,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.repeat_rounded,
                        color: AppColors.inkMuted, size: 24),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.sm),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.sheetPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circle outline checkbox + Title + pencil
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                              () => _isCompleted = !_isCompleted),
                          child: Padding(
                            padding:
                                 const EdgeInsets.only(top: 4),
                            child: Icon(
                              _isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: _isCompleted
                                  ? AppColors.primary
                                  : AppColors.hairline,
                              size: 26,
                            ),
                          ),
                        ),
                        SizedBox(width: AppTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _title,
                                      style: AppTypography.sheetTitle(
                                        color: _isCompleted
                                            ? AppColors.inkMuted
                                            : AppColors.ink,
                                        weight: 600,
                                      ).copyWith(
                                        decoration: _isCompleted
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                        decorationColor:
                                            AppColors.inkMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppTokens.xs),
                                  GestureDetector(
                                    onTap: () =>
                                        _showTitleEdit(context),
                                    child: Icon(
                                        Icons.edit_rounded,
                                        color: AppColors.inkMuted,
                                        size: 18),
                                  ),
                                ],
                              ),
                              if (_description != null &&
                                  _description!.isNotEmpty)
                                GestureDetector(
                                  onTap: () =>
                                      _showDescriptionEdit(context),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: AppTokens.xxs),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _description!,
                                            style: AppTypography.body(
                                                color:
                                                    AppColors.inkMuted),
                                          ),
                                        ),
                                        SizedBox(
                                            width: AppTokens.xs),
                                        Icon(Icons.edit_rounded,
                                            color: AppColors.inkMuted,
                                            size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTokens.lg),

                    // Detail rows (no dividers, no icon backgrounds)
                    _DetailRow(
                      icon: Icons.timer_outlined,
                      label: 'Task Time :',
                      value: _formatDueDate(),
                      onTap: () => _showDateTimePicker(context),
                    ),
                    SizedBox(height: AppTokens.sm),
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Task Category :',
                      value: _getCategoryName(_selectedCategoryId) ??
                          'Not set',
                      badgeColor:
                          _getCategoryColor(_selectedCategoryId),
                      badgeForegroundColor:
                          _getCategoryForegroundColor(_selectedCategoryId),
                      badgeIcon:
                          _getCategoryIcon(_selectedCategoryId),
                      onTap: () => _showCategoryPicker(context),
                    ),
                    SizedBox(height: AppTokens.sm),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Task Priority :',
                      value: _selectedPriority.toString(),
                      badgeColor: _priorityColor(_selectedPriority),
                      badgeIcon: Icons.flag_rounded,
                      onTap: () => _showPriorityPicker(context),
                    ),
                    SizedBox(height: AppTokens.sm),
                    _DetailRow(
                      icon: Icons.account_tree_outlined,
                      label: 'Sub-Task :',
                      value: _subtasks.isEmpty
                          ? 'Add Sub-Task'
                          : '${_subtasks.length} subtasks',
                      onTap: () => _showSubtaskSheet(context),
                    ),
                    SizedBox(height: AppTokens.sm),

                    // Delete Task row
                    InkWell(
                      onTap: () =>
                          _showDeleteConfirmation(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppTokens.md),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: AppColors.error, size: 22),
                            SizedBox(width: AppTokens.md),
                            Text(
                              'Delete Task',
                              style: AppTypography.body(
                                  color: AppColors.error,
                                  weight: 500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppTokens.md),
                  ],
                ),
              ),
            ),

            // Bottom-anchored filled primary "Edit Task" button
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTokens.sheetPadding,
                AppTokens.sm,
                AppTokens.sheetPadding,
                AppTokens.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text('Edit Task',
                      style: AppTypography.buttonLabel()),
                ),
              ),
            ),
            SizedBox(height: bottomInset),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    final task = widget.task;
    final updatedTask = task.copyWith(
      title: _title,
      description: _description,
      isCompleted: _isCompleted,
      categoryId: _selectedCategoryId,
      priority: _selectedPriority,
      dueDate: _combineDateTime(_dueDate, _dueTime),
      reminderAt: _combineDateTime(_dueDate, _dueTime),
      subtasks: _subtasks,
      updatedAt: DateTime.now(),
    );
    widget.onSave(updatedTask);
    Navigator.of(context).pop();
  }

  String _formatDueDate() {
    if (_dueDate == null) return 'Not set';
    final date = _dueDate!;
    final time = _dueTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    String datePart;
    if (dateDay == today) {
      datePart = 'Today';
    } else if (dateDay == today.add(const Duration(days: 1))) {
      datePart = 'Tomorrow';
    } else if (dateDay ==
        today.subtract(const Duration(days: 1))) {
      datePart = 'Yesterday';
    } else {
      datePart = DateFormat('MMM d, yyyy').format(date);
    }

    if (time != null) {
      final hour12 = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour < 12 ? 'AM' : 'PM';
      final minuteStr = time.minute.toString().padLeft(2, '0');
      return '$datePart At $hour12:$minuteStr $period';
    }
    return datePart;
  }

  static DateTime? _combineDateTime(
      DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    final t = time ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
        date.year, date.month, date.day, t.hour, t.minute);
  }

  String? _getCategoryName(String? categoryId) {
    if (categoryId == null) return null;
    final cat = widget.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.name;
  }

  Color? _getCategoryColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = widget.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.backgroundColor;
  }

  Color? _getCategoryForegroundColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = widget.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.foregroundColor;
  }

  IconData? _getCategoryIcon(String? categoryId) {
    if (categoryId == null) return null;
    final cat = widget.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.iconData;
  }

  static Color _priorityColor(int priority) {
    if (priority <= 2) return const Color(0xFF4CAF50);
    if (priority <= 4) return const Color(0xFFFFEB3B);
    if (priority <= 7) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  void _showTitleEdit(BuildContext context) {
    final controller = TextEditingController(text: _title);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CompactSheet(
        title: 'Edit Title',
        onEdit: () {
          if (controller.text.trim().isNotEmpty) {
            setState(() => _title = controller.text.trim());
          }
          Navigator.pop(ctx);
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: TextField(
            controller: controller,
            style:
                AppTypography.body(color: AppColors.ink, size: 16),
            decoration: InputDecoration(
              hintText: 'Task title',
              hintStyle:
                  AppTypography.body(color: AppColors.inkMuted),
            ),
            autofocus: true,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  void _showDescriptionEdit(BuildContext context) {
    final controller = TextEditingController(text: _description ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CompactSheet(
        title: 'Edit Description',
        onEdit: () {
          setState(() {
            final trimmed = controller.text.trim();
            _description = trimmed.isNotEmpty ? trimmed : null;
          });
          Navigator.pop(ctx);
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: TextField(
            controller: controller,
            style:
                AppTypography.body(color: AppColors.ink, size: 16),
            decoration: InputDecoration(
              hintText: 'Task description',
              hintStyle:
                  AppTypography.body(color: AppColors.inkMuted),
            ),
            autofocus: true,
            maxLines: 4,
          ),
        ),
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) async {
    final date = await showCustomDatePicker(
      context: context,
      initialDate: _dueDate,
    );
    if (date == null || !mounted) return;

    final time = await showCustomTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (time == null || !mounted) return;

    setState(() {
      _dueDate = date;
      _dueTime = time;
    });
  }

  void _showCategoryPicker(BuildContext context) {
    showCustomCategoryPicker(
      context: context,
      categories: widget.categories,
      currentSelection: _selectedCategoryId,
    ).then((categoryId) {
      if (!mounted) return;
      if (categoryId == '__create_new__') {
        Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => const CreateCategorySheet(),
          ),
        ).then((createdId) {
          if (!mounted) return;
          if (createdId != null) {
            setState(() => _selectedCategoryId = createdId);
          } else {
            _showCategoryPicker(context);
          }
        });
        return;
      }
      if (categoryId != null) {
        setState(() => _selectedCategoryId = categoryId);
      }
    });
  }

  void _showPriorityPicker(BuildContext context) async {
    final result = await showCustomPriorityPicker(
      context: context,
      currentPriority: _selectedPriority,
    );
    if (result != null && mounted) {
      setState(() => _selectedPriority = result);
    }
  }

  void _showSubtaskSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF272727),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(AppTokens.lg, AppTokens.lg, AppTokens.lg, AppTokens.md),
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sub-Tasks',
                      style: AppTypography.sheetTitle(
                          color: AppColors.inkMuted, size: 14, weight: 700),
                    ),
                    const SizedBox(height: AppTokens.sm),
                    const Divider(
                        color: AppColors.inkMuted,
                        height: 1,
                        thickness: 0.5),
                    const SizedBox(height: AppTokens.sm),
                    if (_subtasks.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppTokens.lg),
                        child: Center(
                          child: Text(
                            'No subtasks yet',
                            style: AppTypography.body(
                                color: AppColors.inkMuted),
                          ),
                        ),
                      )
                    else
                      ..._subtasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subtask = entry.value;
                        return _SubtaskTile(
                          subtask: subtask,
                          onToggle: () {
                            setState(() {
                              _subtasks[index] =
                                  _subtasks[index].copyWith(
                                isCompleted: !_subtasks[index]
                                    .isCompleted,
                              );
                            });
                            setDialogState(() {});
                          },
                          onDelete: () {
                            setState(
                                () => _subtasks.removeAt(index));
                            setDialogState(() {});
                          },
                        );
                      }),
                    SizedBox(height: AppTokens.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final added =
                              await _showAddSubtaskDialog(
                                  context);
                          if (added) setDialogState(() {});
                        },
                        icon: Icon(Icons.add_rounded,
                            size: 18,
                            color: AppColors.primary),
                        label: Text('Add Sub-Task',
                            style: AppTypography.buttonLabel(
                                color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: AppColors.hairline),
                        ),
                      ),
                    ),
                    SizedBox(height: AppTokens.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 12),
                        ),
                        child: Text('Done',
                            style: AppTypography.buttonLabel(weight: 700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showAddSubtaskDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF272727),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppTokens.lg, AppTokens.lg, AppTokens.lg, AppTokens.md),
          child: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Sub-Task',
                  style: AppTypography.sheetTitle(
                      color: AppColors.inkMuted, size: 14, weight: 700),
                ),
                const SizedBox(height: AppTokens.sm),
                const Divider(
                    color: AppColors.inkMuted,
                    height: 1,
                    thickness: 0.5),
                const SizedBox(height: AppTokens.md),
                TextField(
                  controller: controller,
                  style: AppTypography.body(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Subtask title',
                    hintStyle: AppTypography.body(
                        color: AppColors.inkMuted),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF1E1E1E)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.primary),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: AppTypography.sectionLabel(
                            color: AppColors.mutedLavender),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          final newSubtask = SubTask(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            title: controller.text.trim(),
                            isCompleted: false,
                          );
                          setState(() => _subtasks = [
                            ..._subtasks,
                            newSubtask
                          ]);
                          Navigator.pop(ctx, true);
                        } else {
                          Navigator.pop(ctx, false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      child: Text('Add',
                          style: AppTypography.buttonLabel(
                              size: 13, weight: 700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((result) => result ?? false);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        title: Text('Delete Task',
            style: AppTypography.sheetTitle(color: AppColors.ink)),
        content: Text(
          'Are you sure you want to delete "$_title"?',
          style: AppTypography.body(color: AppColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    AppTypography.buttonLabel(color: AppColors.inkMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
              widget.onDelete();
            },
            child: Text('Delete', style: AppTypography.buttonLabel()),
          ),
        ],
      ),
    );
  }
}

// Compact sheet wrapper for inline edit sheets
class _CompactSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onEdit;
  const _CompactSheet({
    required this.title,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.sheetPadding),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.ink, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 20,
                  ),
                  SizedBox(width: AppTokens.xs),
                  Text(title,
                      style: AppTypography.sheetTitle(
                          color: AppColors.ink)),
                  Spacer(),
                  TextButton(
                    onPressed: onEdit,
                    child: Text('Edit',
                        style: AppTypography.buttonLabel(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.md),
            Divider(color: AppColors.hairline, height: 1),
            SizedBox(height: AppTokens.md),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.sheetPadding),
              child: child,
            ),
            SizedBox(height: AppTokens.lg),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? badgeColor;
  final Color? badgeForegroundColor;
  final IconData? badgeIcon;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badgeColor,
    this.badgeForegroundColor,
    this.badgeIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.inkMuted, size: 22),
            SizedBox(width: AppTokens.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                    color: AppColors.ink, weight: 400),
              ),
            ),
            SizedBox(width: AppTokens.sm),
            _ValuePill(
              value: value,
              badgeColor: badgeColor,
              foregroundColor: badgeForegroundColor,
              icon: badgeIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  final String value;
  final Color? badgeColor;
  final Color? foregroundColor;
  final IconData? icon;

  const _ValuePill({
    required this.value,
    this.badgeColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (badgeColor != null) {
      final fg = foregroundColor ?? badgeColor!;
      // Category badge with icon + text
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppTokens.sm, vertical: AppTokens.xxs),
        decoration: BoxDecoration(
          color: foregroundColor != null ? badgeColor : badgeColor!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppTypography.meta(
                  color: fg, weight: 500),
            ),
          ],
        ),
      );
    }
    // Default chip
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppTokens.sm, vertical: AppTokens.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardAlt,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        value,
        style: AppTypography.meta(
            color: AppColors.inkMuted, weight: 500),
      ),
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskTile({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.xs),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: subtask.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.primary
                      : AppColors.hairline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: subtask.isCompleted
                  ? Icon(Icons.check_rounded,
                      size: 14, color: AppColors.onPrimary)
                  : null,
            ),
          ),
          SizedBox(width: AppTokens.sm),
          Expanded(
            child: Text(
              subtask.title,
              style: AppTypography.body(
                color: subtask.isCompleted
                    ? AppColors.inkMuted
                    : AppColors.ink,
              ).copyWith(
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          SizedBox(width: AppTokens.sm),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded,
                color: AppColors.inkFaint, size: 18),
          ),
        ],
      ),
    );
  }
}
