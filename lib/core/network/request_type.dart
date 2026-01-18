enum RequestType { get, post, patch, delete, put }

extension RequestTypeExtension on RequestType {
  String get name {
    return toString().split('.').last.toUpperCase();
  }
}
