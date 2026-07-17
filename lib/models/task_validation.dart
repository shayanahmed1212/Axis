// Lightweight validation result model returned by client-side validation
// routines. Rather than throwing/handling exceptions for every field
// check, [TaskValidation] collects all errors into a list so the UI can
// display them in bulk — used primarily by the task form validation
// pipeline.
// ignore_for_file: prefer_const_constructors

import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_validation.freezed.dart';

@freezed
abstract class TaskValidation with _$TaskValidation {
  const factory TaskValidation({
    required bool isValid,
    List<String>? errors,
  }) = _TaskValidation;

  const TaskValidation._();

  static final TaskValidation valid = TaskValidation(isValid: true, errors: []);

  static TaskValidation invalid(List<String> errors) => TaskValidation(isValid: false, errors: errors);

  String? get firstError => errors?.isNotEmpty == true ? errors![0] : null;
}
