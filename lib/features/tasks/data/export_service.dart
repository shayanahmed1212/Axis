import 'package:axis/core/utils/data_export.dart';
import 'package:axis/features/tasks/domain/task.dart';

class ExportService {
  Future<String> exportTasks(List<Task> tasks, {ExportFormat format = ExportFormat.csv}) async {
    return switch (format) {
      ExportFormat.csv => DataExport.tasksToCsv(tasks),
      ExportFormat.json => DataExport.tasksToJson(tasks),
    };
  }

  Future<String> saveExport(List<Task> tasks, {ExportFormat format = ExportFormat.csv}) async {
    final content = await exportTasks(tasks, format: format);
    final extension = format == ExportFormat.csv ? 'csv' : 'json';
    final filename = 'axis_tasks_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return DataExport.saveToFile(content, filename);
  }
}
