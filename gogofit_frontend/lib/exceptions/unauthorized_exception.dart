// lib/exceptions/unauthorized_exception.dart
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized. Please log in again.']);

  @override
  String toString() {
    return 'UnauthorizedException: $message';
  }
}
