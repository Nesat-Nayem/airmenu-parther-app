import 'package:airmenuai_partner_app/core/models/pagination_model.dart';

/// Generic API response wrapper with optional data and pagination
class GenericResponse<T> {
  final bool? success;
  final String? message;
  final T? data;
  final PaginationModel? pagination;

  const GenericResponse({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  /// Factory constructor for creating a GenericResponse with a custom data parser
  static GenericResponse<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return GenericResponse<T>(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }

  /// Create a success response
  factory GenericResponse.success(
    T data, {
    String? message,
    PaginationModel? pagination,
  }) {
    return GenericResponse<T>(
      success: true,
      message: message,
      data: data,
      pagination: pagination,
    );
  }

  /// Create a failure response
  factory GenericResponse.failure(String message) {
    return GenericResponse<T>(
      success: false,
      message: message,
      data: null,
      pagination: null,
    );
  }
}
