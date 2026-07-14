// Priority enum used throughout the app
enum TaskPriority {
  low('Low', 'Low priority'),
  medium('Medium', 'Medium priority'),
  high('High', 'High priority');

  final String displayName;
  final String description;

  const TaskPriority(this.displayName, this.description);

  // Get the appropriate color token key for each priority
  String get colorToken => switch (this) {
    TaskPriority.low => 'success',
    TaskPriority.medium => 'primary',
    TaskPriority.high => 'error',
  };
}