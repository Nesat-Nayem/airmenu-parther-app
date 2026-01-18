import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/category/data/models/category_model.dart';
import 'package:airmenuai_partner_app/features/category/data/models/category_response_model.dart';
import 'dart:convert';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory({
    required String title,
    required String imagePath,
  });
  Future<CategoryModel> updateCategory({
    required String id,
    required String title,
    String? imagePath,
  });
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiService apiService;

  CategoryRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final result = await apiService.invoke<String>(
      urlPath: '/categories',
      fun: (response) => response,
      type: RequestType.get,
    );

    if (result is DataSuccess<String>) {
      final jsonData = json.decode(result.data!);
      final responseModel = CategoryResponseModel.fromJson(jsonData);
      return responseModel.data ?? [];
    } else if (result is DataFailure<String>) {
      throw Exception(result.error?.message ?? 'Failed to fetch categories');
    }
    throw Exception('Unknown error occurred');
  }

  @override
  Future<CategoryModel> createCategory({
    required String title,
    required String imagePath,
  }) async {
    final result = await apiService.invokeMultipart<String>(
      urlPath: '/categories',
      fun: (response) => response,
      type: RequestType.post,
      fields: {'title': title},
      files: {'image': imagePath},
    );

    if (result is DataSuccess<String>) {
      final jsonData = json.decode(result.data!);
      final responseModel = CategoryResponseModel.fromJson(jsonData);
      if (responseModel.singleData != null) {
        return responseModel.singleData!;
      }
      throw Exception('Invalid response format');
    } else if (result is DataFailure<String>) {
      throw Exception(result.error?.message ?? 'Failed to create category');
    }
    throw Exception('Unknown error occurred');
  }

  @override
  Future<CategoryModel> updateCategory({
    required String id,
    required String title,
    String? imagePath,
  }) async {
    final fields = {'title': title};
    final files = imagePath != null ? {'image': imagePath} : <String, String>{};

    final result = await apiService.invokeMultipart<String>(
      urlPath: '/categories/$id',
      fun: (response) => response,
      type: RequestType.put,
      fields: fields,
      files: files,
    );

    if (result is DataSuccess<String>) {
      final jsonData = json.decode(result.data!);
      final responseModel = CategoryResponseModel.fromJson(jsonData);
      if (responseModel.singleData != null) {
        return responseModel.singleData!;
      }
      throw Exception('Invalid response format');
    } else if (result is DataFailure<String>) {
      throw Exception(result.error?.message ?? 'Failed to update category');
    }
    throw Exception('Unknown error occurred');
  }

  @override
  Future<void> deleteCategory(String id) async {
    final result = await apiService.invoke<String>(
      urlPath: '/categories/$id',
      fun: (response) => response,
      type: RequestType.delete,
    );

    if (result is DataFailure<String>) {
      throw Exception(result.error?.message ?? 'Failed to delete category');
    }
  }
}
