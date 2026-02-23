class ServerException implements Exception {
  final message;
  ServerException([this.message]);
  @override
  String toString() {
    return "Exception: $message";
  }
}

class ForbiddenException extends ServerException {
  ForbiddenException([String? super.message]);
}

class ConflictException extends ServerException {
  ConflictException([String? super.message]);
}

class InternalServerErrorException extends ServerException {
  InternalServerErrorException([String? super.message]);
}

class ServiceUnavailableException extends ServerException {
  ServiceUnavailableException([String? super.message]);
}

class NotFoundException extends ServerException {
  NotFoundException([String? super.message]);
}

class NotConnectedException extends ServerException {
  NotConnectedException([String? super.message]);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException([String? super.message]);
}

class CacheException extends ServerException {
  CacheException([String? super.message]);
}

class ItemNotFoundException extends ServerException {
  ItemNotFoundException([String? super.message]);
}

class FetchDataException extends ServerException {
  FetchDataException([String? super.message]);
}

class BadRequestException extends ServerException {
  BadRequestException(String? super.message);
}

class InvalidInputException extends ServerException {
  InvalidInputException([String? super.message]);
}
