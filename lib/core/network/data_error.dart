class DataError {
  DataError({
    this.message,
    this.statusCode,
  });
  final String? message;
  final int? statusCode;

  factory DataError.fromJson(Map<String, dynamic> json) => DataError(
        message: json["message"] ?? '',
        statusCode: json["statusCode"] ?? "",
      );
}
