// App constants for strings, routes, and other non-trivial values
class AppStrings {
  // Auth screen strings
  static const String welcomeBack = 'Welcome Back';
  static const String signInToYourAccount = 'Sign in to your account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String signIn = 'Sign In';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';

  // Register screen strings
  static const String createAccount = 'Create Account';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Task dashboard strings
  static const String myTasks = 'My Tasks';
  static const String addTask = 'Add Task';
  static const String all = 'All';
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String noTasksYet = 'No tasks yet';
  static const String noTasksMessage = 'Add your first task to get started';
  static const String noActiveTasks = 'No active tasks';
  static const String noCompletedTasks = 'No completed tasks';

  // Task form strings
  static const String editTask = 'Edit Task';
  static const String newTask = 'New Task';
  static const String title = 'Title';
  static const String enterTitle = 'Enter task title';
  static const String description = 'Description';
  static const String enterDescription = 'Enter task description (optional)';
  static const String dueDate = 'Due Date';
  static const String priority = 'Priority';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String selectPriority = 'Select priority';
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  // Empty states
  static const String emptyStateTitle = 'All clear!';
  static const String emptyStateMessage = 'You\'ve completed all your tasks';
  static const String swipeToDelete = 'Swipe left to delete';

  // Error states
  static const String errorTitle = 'Something went wrong';
  static const String retry = 'Retry';
  static const String networkError = 'Network error. Please check your connection.';

  // Success states
  static const String taskSaved = 'Task saved successfully';
  static const String taskDeleted = 'Task deleted';
  static const String undo = 'Undo';
  static const String passwordResetSent = 'Password reset link sent to your email';

  // Validation errors
  static const String errorRequiredField = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters';
  static const String errorPasswordsDontMatch = 'Passwords do not match';
  static const String errorTitleTooShort = 'Title must be at least 2 characters';

  // Auth error messages
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorEmailAlreadyInUse = 'This email is already in use';
  static const String errorWeakPassword = 'Password is too weak';
  static const String errorUserDisabled = 'Your account has been disabled';
  static const String errorTooManyRequests = 'Too many attempts. Please try again later';

  // Profile screen
  static const String profile = 'Profile';
  static const String emailLabel = 'Email';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String cancelAction = 'Cancel';
  static const String logoutAction = 'Logout';
}