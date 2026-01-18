class ServerException implements Exception {
  final message;
  ServerException([this.message]);
  String toString() {
    return "Exception: $message";
  }
}

class ForbiddenException extends ServerException {
  ForbiddenException([String? message]) : super(message);
}

class ConflictException extends ServerException {
  ConflictException([String? message]) : super(message);
}

class InternalServerErrorException extends ServerException {
  InternalServerErrorException([String? message]) : super(message);
}

class ServiceUnavailableException extends ServerException {
  ServiceUnavailableException([String? message]) : super(message);
}

class NotFoundException extends ServerException {
  NotFoundException([String? message]) : super(message);
}

class NotConnectedException extends ServerException {
  NotConnectedException([String? message]) : super(message);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException([String? message]) : super(message);
}

class CacheException extends ServerException {
  CacheException([String? message]) : super(message);
}

class ItemNotFoundException extends ServerException {
  ItemNotFoundException([String? message]) : super(message);
}

class FetchDataException extends ServerException {
  FetchDataException([String? message]) : super(message);
}

class BadRequestException extends ServerException {
  BadRequestException(String? message) : super(message);
}

class InvalidInputException extends ServerException {
  InvalidInputException([String? message]) : super(message);
}
