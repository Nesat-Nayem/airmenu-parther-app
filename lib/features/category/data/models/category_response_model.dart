import 'package:airmenuai_partner_app/features/category/data/models/category_model.dart';

class CategoryResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<CategoryModel>? data;
  final CategoryModel? singleData;

  CategoryResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.singleData,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle list response (GET all categories)
    if (json['data'] is List) {
      return CategoryResponseModel(
        success: json['success'] as bool,
        statusCode: json['statusCode'] as int,
        message: json['message'] as String,
        data: (json['data'] as List)
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }

    // Handle single object response (CREATE, UPDATE)
    return CategoryResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      singleData: json['data'] != null
          ? CategoryModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
