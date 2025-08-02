// lib/services/api_exception.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class AuthException extends ApiException {
  AuthException(String message) : super(message, statusCode: 401);
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) 
    : super(message, statusCode: statusCode);
}
