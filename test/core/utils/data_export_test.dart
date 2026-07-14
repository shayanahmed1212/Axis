import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:axis/core/utils/data_export.dart';
import 'package:axis/features/tasks/domain/task.dart';
import 'package:axis/features/tasks/domain/task_priority.dart';

void main() {
  group('DataExport', () {
    late List<Task> sampleTasks;

    setUp(() {
      sampleTasks = [
        Task(
          id: '1',
          title: 'Buy groceries',
          description: 'Milk, eggs, bread',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime(2025, 1, 15, 10, 30),
          updatedAt: DateTime(2025, 1, 15, 10, 30),
          dueDate: DateTime(2025, 1, 20),
        ),
        Task(
          id: '2',
          title: 'Clean house',
          description: null,
          priority: TaskPriority.low,
          isCompleted: true,
          createdAt: DateTime(2025, 1, 10, 8, 0),
          updatedAt: DateTime(2025, 1, 10, 8, 0),
        ),
        Task(
          id: '3',
          title: 'Work, on "quotes"',
          description: 'A task with special chars',
          priority: TaskPriority.medium,
          isCompleted: false,
          createdAt: DateTime(2025, 1, 12, 14, 15),
          updatedAt: DateTime(2025, 1, 12, 14, 15),
          dueDate: DateTime(2025, 2, 1),
        ),
      ];
    });

    group('tasksToCsv', () {
      test('generates correct header', () {
        final csv = DataExport.tasksToCsv([]);
        expect(csv, contains('Title,Description,Priority,Due Date,Created At,Completed'));
      });

      test('generates correct number of rows', () {
        final csv = DataExport.tasksToCsv(sampleTasks);
        final lines = csv.trim().split('\n');
        expect(lines.length, 4); // header + 3 tasks
      });

      test('escapes CSV values with commas', () {
        final csv = DataExport.tasksToCsv(sampleTasks);
        // CSV escaping: double quotes become ""
        expect(csv, contains('"Work, on ""quotes"""'));
      });

      test('handles null description', () {
        final csv = DataExport.tasksToCsv(sampleTasks);
        final lines = csv.trim().split('\n');
        // Second task has null description
        expect(lines[2], contains(',Low,'));
      });

      test('marks completed tasks as Yes', () {
        final csv = DataExport.tasksToCsv(sampleTasks);
        final lines = csv.trim().split('\n');
        expect(lines[2], contains(',Yes'));
      });

      test('marks incomplete tasks as No', () {
        final csv = DataExport.tasksToCsv(sampleTasks);
        final lines = csv.trim().split('\n');
        expect(lines[1], contains(',No'));
      });
    });

    group('tasksToJson', () {
      test('generates valid JSON', () {
        final json = DataExport.tasksToJson(sampleTasks);
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('has correct number of items', () {
        final json = DataExport.tasksToJson(sampleTasks);
        final decoded = jsonDecode(json) as List;
        expect(decoded.length, 3);
      });

      test('preserves task data', () {
        final json = DataExport.tasksToJson(sampleTasks);
        final decoded = jsonDecode(json) as List;
        final first = decoded[0] as Map;
        expect(first['title'], 'Buy groceries');
        expect(first['description'], 'Milk, eggs, bread');
        expect(first['priority'], 'high');
        expect(first['isCompleted'], false);
      });

      test('handles null description as null', () {
        final json = DataExport.tasksToJson(sampleTasks);
        final decoded = jsonDecode(json) as List;
        final second = decoded[1] as Map;
        expect(second['description'], isNull);
      });

      test('formats with indentation', () {
        final json = DataExport.tasksToJson(sampleTasks);
        expect(json, contains('  "title"'));
      });
    });
  });
}
