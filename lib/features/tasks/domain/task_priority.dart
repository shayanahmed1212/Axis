// Priority enum — kept for backward compatibility
// New system uses integer priority 1-10 (see Task model)
enum TaskPriority {
  low('Low', 'Low priority'),
  medium('Medium', 'Medium priority'),
  high('High', 'High priority');

  final String displayName;
  final String description;

  const TaskPriority(this.displayName, this.description);

  String get colorToken => switch (this) {
    TaskPriority.low => 'success',
    TaskPriority.medium => 'primary',
    TaskPriority.high => 'error',
  };

  // Convert integer priority (1-10) to enum
  static TaskPriority fromInt(int priority) {
    if (priority <= 3) return TaskPriority.low;
    if (priority <= 6) return TaskPriority.medium;
    return TaskPriority.high;
  }

  // Convert enum to midpoint integer
  int toInt() => switch (this) {
    TaskPriority.low => 2,
    TaskPriority.medium => 5,
    TaskPriority.high => 8,
  };
}