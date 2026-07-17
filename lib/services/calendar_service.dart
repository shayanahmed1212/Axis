// Google Calendar import service — sign in with Calendar read-only scope,
// fetch upcoming events, map them to Task models, and save to Firestore.
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import 'package:axis/models/task.dart';
import 'package:axis/services/task_service.dart';

class CalendarImportService {
  final TaskRepository _taskRepository;

  CalendarImportService(this._taskRepository);

  /// Signs in with Google, fetches upcoming calendar events (past 7 days
  /// through next 30 days), maps each to a [Task], saves to Firestore,
  /// and returns the count of imported tasks.
  Future<int> importEvents() async {
    final googleSignIn = GoogleSignIn(
      scopes: [CalendarApi.calendarEventsReadonlyScope],
    );

    final account = await googleSignIn.signIn();
    if (account == null) return 0;

    final httpClient = await googleSignIn.authenticatedClient();
    if (httpClient == null) return 0;

    try {
      final calendarApi = CalendarApi(httpClient);
      final now = DateTime.now();

      final events = await calendarApi.events.list(
        'primary',
        timeMin: now.subtract(const Duration(days: 7)),
        timeMax: now.add(const Duration(days: 30)),
        singleEvents: true,
        orderBy: 'startTime',
      );

      final items = events.items ?? [];
      int imported = 0;

      for (final event in items) {
        if (event.start == null) continue;

        final task = Task(
          id: '',
          title: event.summary ?? 'Imported Event',
          description: event.description,
          isCompleted: false,
          priority: 5,
          dueDate: event.start?.dateTime ?? event.start?.date,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _taskRepository.createTask(task);
        imported++;
      }

      return imported;
    } finally {
      httpClient.close();
    }
  }
}
