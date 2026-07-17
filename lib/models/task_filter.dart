// Drives the task list filter on [HomeScreen] and [CalendarScreen].
/// The raw enum value is held in a Riverpod [StateProvider] so both screens
/// stay in sync when the filter changes. The Firestore query in
/// [TaskRepository.watchTasks] adds a `.where('is_completed', …)` clause
/// for [active] and [completed] variants.
enum TaskFilter { all, active, completed }
