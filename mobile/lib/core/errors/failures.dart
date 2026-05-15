class AppFailure {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const AppFailure({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => 'AppFailure(message: $message, code: $errorCode)';
}