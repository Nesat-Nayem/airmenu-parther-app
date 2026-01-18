import 'dart:convert';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/features/landmark/domain/repositories/i_landmark_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ILandmarkRepository)
class LandmarkRepository implements ILandmarkRepository {
  final ApiService _apiService;

  LandmarkRepository(this._apiService);

  @override
  Future<MallsListResponse> getMalls({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    // Build query string manually since ApiService doesn't handle params for GET
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final urlPath = '/malls?$queryString';

    final result = await _apiService.invoke<MallsListResponse>(
      urlPath: urlPath,
      type: RequestType.get,
      fun: (json) {
        // ApiService passes the response body string
        final map = jsonDecode(json) as Map<String, dynamic>;
        return MallsListResponse.fromJson(map);
      },
    );

    if (result is DataSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error?.message ?? 'Failed to load malls');
    }
  }

  @override
  Future<MallModel> getMallById(String id) async {
    final result = await _apiService.invoke<MallModel>(
      urlPath: '/malls/$id',
      type: RequestType.get,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final data = map['data'] as Map<String, dynamic>;
        return MallModel.fromJson(data);
      },
    );

    if (result is DataSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error?.message ?? 'Failed to load mall');
    }
  }

  @override
  Future<MallModel> createMall(
    CreateMallRequest request, {
    String? imagePath,
  }) async {
    final fields = <String, String>{'name': request.name};

    if (request.description != null) {
      fields['description'] = request.description!;
    }

    if (request.location != null) {
      fields['location'] = request.location!;
    }

    // Add coordinates as GeoJSON
    if (request.latitude != null && request.longitude != null) {
      fields['coordinates[type]'] = 'Point';
      fields['coordinates[coordinates][0]'] = request.longitude.toString();
      fields['coordinates[coordinates][1]'] = request.latitude.toString();
      if (request.address != null) {
        fields['coordinates[address]'] = request.address!;
      }
    }

    final files = <String, String>{};
    if (imagePath != null && imagePath.isNotEmpty) {
      files['mainImage'] = imagePath;
    }

    // Use invokeMultipart if implies image upload
    if (files.isNotEmpty) {
      final result = await _apiService.invokeMultipart<MallModel>(
        urlPath: '/malls',
        type: RequestType.post,
        fields: fields,
        files: files,
        fun: (json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          final data = map['data'] as Map<String, dynamic>;
          return MallModel.fromJson(data);
        },
      );

      if (result is DataSuccess) {
        return result.data!;
      } else {
        throw Exception(result.error?.message ?? 'Failed to create mall');
      }
    } else {
      // Normal POST if no image (though schema supports it)
      // ApiService invoke takes 'params' as dynamic, checks if POST -> jsonEncode(params)
      // I need to map my flat fields to nested object if sending JSON?
      // Or just send flat and hope backend parses?
      // Backend expects JSON for CreateMall logic?
      // The backend uses `upload.single('mainImage')`. This implies it ALWAYS expects multipart/form-data for this endpoint?
      // Usually passing multipart without file works as "fields only".
      // Let's stick to invokeMultipart for consistency with the backend route definition
      // which has `upload.single`.

      final result = await _apiService.invokeMultipart<MallModel>(
        urlPath: '/malls',
        type: RequestType.post,
        fields: fields,
        files: {}, // Empty files
        fun: (json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          final data = map['data'] as Map<String, dynamic>;
          return MallModel.fromJson(data);
        },
      );

      if (result is DataSuccess) {
        return result.data!;
      } else {
        throw Exception(result.error?.message ?? 'Failed to create mall');
      }
    }
  }

  @override
  Future<MallModel> updateMall(
    String id,
    UpdateMallRequest request, {
    String? imagePath,
  }) async {
    final fields = <String, String>{};

    if (request.name != null) {
      fields['name'] = request.name!;
    }
    if (request.description != null) {
      fields['description'] = request.description!;
    }
    if (request.location != null) {
      fields['location'] = request.location!;
    }

    if (request.latitude != null && request.longitude != null) {
      fields['coordinates[type]'] = 'Point';
      fields['coordinates[coordinates][0]'] = request.longitude.toString();
      fields['coordinates[coordinates][1]'] = request.latitude.toString();
      if (request.address != null) {
        fields['coordinates[address]'] = request.address!;
      }
    }

    final files = <String, String>{};
    if (imagePath != null && imagePath.isNotEmpty) {
      files['mainImage'] = imagePath;
    }

    final result = await _apiService.invokeMultipart<MallModel>(
      urlPath: '/malls/$id',
      type: RequestType.put,
      fields: fields,
      files: files,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final data = map['data'] as Map<String, dynamic>;
        return MallModel.fromJson(data);
      },
    );

    if (result is DataSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error?.message ?? 'Failed to update mall');
    }
  }

  @override
  Future<void> deleteMall(String id) async {
    final result = await _apiService.invoke<void>(
      urlPath: '/malls/$id',
      type: RequestType.delete,
      fun: (json) {}, // No return data needed
    );

    if (result is DataFailure) {
      throw Exception(result.error?.message ?? 'Failed to delete mall');
    }
  }
}
