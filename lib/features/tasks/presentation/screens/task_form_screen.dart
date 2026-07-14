// Task Form — create or edit task
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/utils/validators.dart';
import 'package:axis/core/utils/haptics.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isEdit = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.taskId != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEdit && !_isInitialized) {
      _loadExistingTask();
    }
  }

  void _loadExistingTask() {
    final tasksAsync = ref.read(taskListProvider);
    tasksAsync.whenData((tasks) {
      final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
      if (task != null && mounted) {
        setState(() {
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _priority = task.priority;
          _dueDate = task.dueDate;
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final controller = ref.read(taskControllerProvider);
      if (_isEdit) {
        final tasksAsync = ref.read(taskListProvider);
        tasksAsync.whenData((tasks) async {
          final existing = tasks.where((t) => t.id == widget.taskId).firstOrNull;
          if (existing != null) {
            final updated = existing.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              priority: _priority,
              dueDate: _dueDate,
            );
            await controller.updateTask(updated);
            if (mounted) context.pop();
          }
        });
      } else {
        await controller.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          _isEdit ? 'Edit Task' : 'New Task',
          style: AppTypography.display(size: 20, weight: 700, color: AppColors.ink),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  validator: Validators.validateTaskTitle,
                  style: AppTypography.body(size: 15, weight: 400, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Task title',
                    hintStyle: AppTypography.body(size: 15, weight: 400, color: AppColors.inkMuted),
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: AppTypography.body(size: 14, weight: 400, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: AppTypography.body(size: 14, weight: 400, color: AppColors.inkMuted),
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                // Priority
                Text('Priority', style: AppTypography.body(size: 13, weight: 600, color: AppColors.inkMuted)),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = p == _priority;
                    final (bg, text, label) = switch (p) {
                      TaskPriority.low => (AppColors.blockSage, AppColors.blockSageText, 'Low'),
                      TaskPriority.medium => (AppColors.accent, AppColors.accentInk, 'Medium'),
                      TaskPriority.high => (AppColors.blockCoral, AppColors.blockCoralText, 'High'),
                    };
                    return Expanded(
                      child: GestureDetector(
                        onTap: () { AppHaptics.selectionClick(); setState(() => _priority = p); },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: bg.withOpacity(isSelected ? 1.0 : 0.6),
                            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                            border: isSelected ? Border.all(color: AppColors.accent, width: 2) : null,
                          ),
                          child: Text(label, textAlign: TextAlign.center, style: AppTypography.body(size: 13, weight: 600, color: text)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Due date
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) setState(() => _dueDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.inkMuted),
                        const SizedBox(width: 10),
                        Text(
                          _dueDate != null ? '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}' : 'Set due date (optional)',
                          style: AppTypography.body(size: 14, weight: 400, color: _dueDate != null ? AppColors.ink : AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Cancel + Submit
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text('Cancel', textAlign: TextAlign.center, style: AppTypography.body(size: 14, weight: 500, color: AppColors.inkMuted)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.accentInk,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accentInk)))
                        : Text(_isEdit ? 'Save Changes' : 'Create Task', style: AppTypography.body(size: AppTypography.buttonSize, weight: AppTypography.buttonWeight, color: AppColors.accentInk)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
