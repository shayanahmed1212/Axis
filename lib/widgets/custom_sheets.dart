// Bottom-sheet forms for creating/editing tasks and categories.
//
// [AddTaskSheet] — lightweight create sheet with title, description,
// date/time, category, and priority fields. The caller passes an `onSave`
// callback that receives a fully constructed [Task]. The sheet pops
// itself after calling `onSave`, so the caller's `.then()` or callback
// handles the actual Firestore write.
//
// [TaskDetailSheet] — full detail/editor with inline tap-to-edit for
// title and description, subtask management, and delete confirmation.
// Like [AddTaskSheet], it returns data via `onSave` / `onDelete` rather
// than owning the repository write — this keeps the sheet decoupled from
// the data layer.
//
// Both sheets embed [CreateCategorySheet] as a full-screen push for
// creating a category mid-task-creation without losing the current form
// state. The new category's ID is passed back through the Navigator stack.
// ignore_for_file: unnecessary_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:axis/theme/app_theme.dart';
import 'package:axis/models/task.dart';
import 'package:axis/models/category.dart';
import 'package:axis/widgets/custom_pickers.dart';
import 'package:axis/services/category_service.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final Task? editingTask;
  final DateTime? initialDate;
  final ValueChanged<Task> onSave;

  const AddTaskSheet({
    super.key,
    this.editingTask,
    this.initialDate,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Task? editingTask,
    DateTime? initialDate,
    required ValueChanged<Task> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        editingTask: editingTask,
        initialDate: initialDate,
        onSave: onSave,
      ),
    );
  }

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
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

  List<Category> get _categories =>
      ref.watch(categoriesStreamProvider).asData?.value ?? [];

  Color? _getCategoryColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = _categories.firstWhere(
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
      context: context,
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
      categories: _categories,
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
            _showCategorySheet(context);
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

// TaskDetailSheet — Large sheet with inline editing, subtasks, delete confirmation
// ignore_for_file: prefer_const_constructors

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;
  final ValueChanged<Task> onSave;
  final VoidCallback onDelete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.onSave,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Task task,
    required ValueChanged<Task> onSave,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
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

  List<Category> get _categories =>
      ref.watch(categoriesStreamProvider).asData?.value ?? [];

  String? _getCategoryName(String? categoryId) {
    if (categoryId == null) return null;
    final cat = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.name;
  }

  Color? _getCategoryColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.backgroundColor;
  }

  Color? _getCategoryForegroundColor(String? categoryId) {
    if (categoryId == null) return null;
    final cat = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category.empty);
    return cat.name.isEmpty ? null : cat.foregroundColor;
  }

  IconData? _getCategoryIcon(String? categoryId) {
    if (categoryId == null) return null;
    final cat = _categories.firstWhere(
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
      categories: _categories,
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
    Color(0xFF8687E7),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
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
