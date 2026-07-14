import 'app_exception_types.dart';

class AppException implements Exception {
  final AppExceptionType type;
  final String message;
  final String? details;

  const AppException({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;

  factory AppException.fromJson(Map<String, dynamic> json) {
    return AppException(
      type: AppExceptionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppExceptionType.unknown,
      ),
      message: json['message'] as String? ?? 'An error occurred',
      details: json['details'] as String?,
    );
  }

  factory AppException.unknown([String? message]) {
    return AppException(
      type: AppExceptionType.unknown,
      message: message ?? 'An unexpected error occurred',
    );
  }
}