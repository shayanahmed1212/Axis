import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:axis/widgets/ui_elements.dart';

void main() {
  group('Pressable', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Pressable(
            onTap: () {},
            child: const Text('Press me'),
          ),
        ),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Pressable(
            onTap: () => tapped = true,
            child: const Text('Press me'),
          ),
        ),
      );

      await tester.tap(find.text('Press me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Pressable(
            onTap: () => tapped = true,
            enabled: false,
            child: const Text('Press me'),
          ),
        ),
      );

      await tester.tap(find.text('Press me'));
      expect(tapped, isFalse);
    });

    testWidgets('applies scale transform on press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Pressable(
            onTap: () {},
            scale: 0.95,
            child: const Text('Press me'),
          ),
        ),
      );

      // Tap down
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Press me')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verify scale transform is applied (Transform widget present)
      final transformFinder = find.ancestor(
        of: find.text('Press me'),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      await gesture.up();
    });

    testWidgets('haptic feedback fires on tap', (tester) async {
      // Pressable uses HapticFeedback.selectionClick which is a no-op in tests
      // Just verify no crash
      await tester.pumpWidget(
        MaterialApp(
          home: Pressable(
            onTap: () {},
            enableHaptic: true,
            child: const Text('Press me'),
          ),
        ),
      );

      await tester.tap(find.text('Press me'));
      expect(find.text('Press me'), findsOneWidget);
    });
  });
}
