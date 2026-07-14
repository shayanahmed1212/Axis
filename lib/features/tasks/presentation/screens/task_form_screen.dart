// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:axis/core/theme/app_colors.dart';
import 'package:axis/core/theme/app_tokens.dart';
import 'package:axis/core/theme/app_typography.dart';
import 'package:axis/core/widgets/primary_button.dart';
import 'package:axis/core/widgets/app_text_field.dart';
import 'package:axis/core/utils/validators.dart';
import 'package:axis/core/widgets/app_snackbar.dart';
import 'package:axis/features/tasks/application/task_providers.dart';
import 'package:axis/features/tasks/application/task_controller.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';
import 'package:axis/features/tasks/presentation/widgets/priority_chip_selector.dart';
import 'package:axis/features/tasks/presentation/widgets/due_date_picker_field.dart';

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTask();
    }
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadTask() async {
    final task = await ref.read(taskDetailProvider(widget.taskId!).future);
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _priority = task.priority;
    _dueDate = task.dueDate;
    _hasChanges = false;
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: Text(
          'Discard changes?',
          style: GoogleFonts.getFont(
            AppTypography.displayFamily,
            fontSize: AppTypography.headlineSize,
            fontWeight: FontWeight(AppTypography.headlineWeight),
            letterSpacing: AppTypography.headlineLetterSpacing,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          'You have unsaved changes.',
          style: GoogleFonts.getFont(
            AppTypography.bodyFamily,
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight(AppTypography.bodyWeight),
            color: AppColors.inkMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.buttonSize,
                fontWeight: FontWeight(AppTypography.buttonWeight),
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
            ),
            child: Text(
              'Discard',
              style: GoogleFonts.getFont(
                AppTypography.bodyFamily,
                fontSize: AppTypography.buttonSize,
                fontWeight: FontWeight(AppTypography.buttonWeight),
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(taskControllerProvider);

      if (widget.taskId != null) {
        final existing = await ref.read(taskDetailProvider(widget.taskId!).future);
        await controller.updateTask(existing.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          updatedAt: DateTime.now(),
        ));
        AppSnackbar.show(context, 'Task updated', type: SnackBarType.success);
      } else {
        await controller.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );
        AppSnackbar.show(context, 'Task created', type: SnackBarType.success);
      }

      if (mounted) context.pop();
    } catch (e) {
      AppSnackbar.show(context, 'Failed to save task: $e', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          elevation: 0,
          title: Text(
            widget.taskId != null ? 'Edit Task' : 'New Task',
            style: GoogleFonts.getFont(
              AppTypography.bodyFamily,
              fontSize: AppTypography.cardTitleSize,
              fontWeight: FontWeight(AppTypography.cardTitleWeight),
              color: AppColors.ink,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) context.pop();
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Title',
                  hintText: 'What needs to be done?',
                  controller: _titleController,
                  validator: Validators.validateTaskTitle,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description',
                  hintText: 'Add details (optional)',
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 24),
                PriorityChipSelector(
                  selectedPriority: _priority,
                  onChanged: (p) {
                    setState(() {
                      _priority = p;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 24),
                DueDatePickerField(
                  selectedDate: _dueDate,
                  onDateSelected: (date) {
                    setState(() {
                      _dueDate = date;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: widget.taskId != null ? 'Update Task' : 'Create Task',
                  onPressed: _save,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
