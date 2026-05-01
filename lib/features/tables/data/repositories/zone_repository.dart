import 'dart:convert';

import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import '../models/zone_model.dart';

class ZoneRepository {
  final ApiService apiService;

  ZoneRepository({required this.apiService});

  Future<List<ZoneModel>> getZones() async {
    final response = await apiService.invoke<List<ZoneModel>>(
      urlPath: '/zones',
      type: RequestType.get,
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'];
          return data.map((e) => ZoneModel.fromJson(e)).toList();
        } else {
          throw Exception(json['message'] ?? 'Failed to load zones');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data ?? [];
    } else {
      throw Exception(response.error?.message ?? 'Failed to load zones');
    }
  }

  Future<ZoneModel> createZone({required String name, String description = ''}) async {
    final response = await apiService.invoke<ZoneModel>(
      urlPath: '/zones',
      type: RequestType.post,
      params: {'name': name, 'description': description},
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return ZoneModel.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Failed to create zone');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Failed to create zone');
    }
  }

  Future<ZoneModel> updateZone({
    required String id,
    required String name,
    String description = '',
    bool isActive = true,
  }) async {
    final response = await apiService.invoke<ZoneModel>(
      urlPath: '/zones/$id',
      type: RequestType.put,
      params: {'name': name, 'description': description, 'isActive': isActive},
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return ZoneModel.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Failed to update zone');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Failed to update zone');
    }
  }

  Future<void> deleteZone(String id) async {
    final response = await apiService.invoke<bool>(
      urlPath: '/zones/$id',
      type: RequestType.delete,
      params: <String, dynamic>{},
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return true;
        } else {
          throw Exception(json['message'] ?? 'Failed to delete zone');
        }
      },
    );

    if (response is DataFailure) {
      throw Exception(response.error?.message ?? 'Failed to delete zone');
    }
  }
}
