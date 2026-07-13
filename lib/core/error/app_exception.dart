sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Please check your internet connection and try again.',
  ]);
}

class ServerException extends AppException {
  const ServerException([
    super.message =
        'Something went wrong on the server. Please try again later.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested brewery was not found.',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

class LocationException extends AppException {
  const LocationException([
    super.message = 'Unable to get your current location.',
  ]);
}
