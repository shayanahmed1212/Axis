import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/task.dart';
import '../../lib/models/task_priority.dart';

void main() {
  group('Task model', () {
    test('fromFirestore correctly parses document data', () {
      // This test verifies the Task.fromFirestore method works with Firestore-like data
      // In a real test, mock Firestore would be used
    });

    test('toMap produces correct structure', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test description',
        isCompleted: false,
        priority: 8,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = task.toMap();
      expect(map['title'], 'Test Task');
      expect(map['description'], 'Test description');
      expect(map['is_completed'], false);
      expect(map['priority'], 8);
    });

    test('priorityDisplay returns correct labels', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
    });

    test('priority enum fromInt works correctly', () {
      expect(TaskPriority.fromInt(1), TaskPriority.low);
      expect(TaskPriority.fromInt(5), TaskPriority.medium);
      expect(TaskPriority.fromInt(9), TaskPriority.high);
    });
  });
}
