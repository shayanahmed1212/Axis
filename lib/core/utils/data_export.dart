import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:axis/features/tasks/domain/task.dart';

enum ExportFormat { csv, json }

class DataExport {
  static String tasksToCsv(List<Task> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('Title,Description,Priority,Due Date,Created At,Completed');
    for (final task in tasks) {
      final title = _escapeCsv(task.title);
      final description = _escapeCsv(task.description ?? '');
      final priority = task.priorityDisplay;
      final dueDate = task.dueDate?.toIso8601String() ?? '';
      final createdAt = task.createdAt.toIso8601String();
      final completed = task.isCompleted ? 'Yes' : 'No';
      buffer.writeln('$title,$description,$priority,$dueDate,$createdAt,$completed');
    }
    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String tasksToJson(List<Task> tasks) {
    final jsonList = tasks.map((task) => {
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'isCompleted': task.isCompleted,
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  static Future<String> saveToFile(String content, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file.path;
  }
}
