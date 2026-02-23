import 'dart:convert';

import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import '../models/table_model.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class TableRepository {
  final ApiService apiService;

  TableRepository({required this.apiService});

  Future<String?> _getHotelId() async {
    return locator<LocalStorage>().getString(localStorageKey: 'hotelId');
  }

  Future<List<TableModel>> getTables() async {
    final hotelId = await _getHotelId();
    String url = '/qrcodes';
    if (hotelId != null) {
      url += '?hotelId=$hotelId';
    }

    final response = await apiService.invoke<List<TableModel>>(
      urlPath: url,
      type: RequestType.get,
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'];
          return data.map((e) => TableModel.fromJson(e)).toList();
        } else {
          throw Exception(json['message'] ?? 'Failed to load tables');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data ?? [];
    } else {
      throw Exception(response.error?.message ?? 'Failed to load tables');
    }
  }

  Future<TableModel> addTable(TableModel table) async {
    final hotelId = await _getHotelId();
    if (hotelId == null) throw Exception('No hotel ID found');

    final payload = table.toAddJson();
    payload['hotelId'] = hotelId;

    final response = await apiService.invoke<TableModel>(
      urlPath: '/qrcodes',
      type: RequestType.post,
      params: payload,
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return TableModel.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Failed to add table');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Failed to add table');
    }
  }

  Future<void> deleteTable(String id) async {
    final response = await apiService.invoke<bool>(
      urlPath: '/qrcodes/$id',
      type: RequestType.delete,
      params: <String, dynamic>{},
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return true;
        } else {
          throw Exception(json['message'] ?? 'Failed to delete table');
        }
      },
    );

    if (response is DataFailure) {
      throw Exception(response.error?.message ?? 'Failed to delete table');
    }
  }

  /// Get download-all URL for a hotel's QR codes
  Future<List<Map<String, String>>> getDownloadAllUrls(String hotelId) async {
    final response = await apiService.invoke<List<Map<String, String>>>(
      urlPath: '/qrcodes/download-all?hotelId=$hotelId',
      type: RequestType.get,
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          return data.map((e) => <String, String>{
            'tableNumber': (e['tableNumber'] ?? '').toString(),
            'qrCodeImage': (e['qrCodeImage'] ?? '').toString(),
          }).toList();
        } else {
          throw Exception(json['message'] ?? 'Failed to get download URLs');
        }
      },
    );

    if (response is DataSuccess<List<Map<String, String>>>) {
      return response.data ?? [];
    } else {
      throw Exception((response as DataFailure).error?.message ?? 'Failed to get download URLs');
    }
  }

  /// Fetch tables for a specific hotel (admin context)
  Future<List<TableModel>> getTablesByHotelId(String hotelId) async {
    final response = await apiService.invoke<List<TableModel>>(
      urlPath: '/qrcodes?hotelId=$hotelId',
      type: RequestType.get,
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'];
          return data.map((e) => TableModel.fromJson(e)).toList();
        } else {
          throw Exception(json['message'] ?? 'Failed to load tables');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data ?? [];
    } else {
      throw Exception(response.error?.message ?? 'Failed to load tables');
    }
  }

  /// Create a table for a specific hotel (admin context)
  Future<TableModel> addTableForHotel({
    required String hotelId,
    required String tableNumber,
    required int seatNumber,
    int capacity = 2,
  }) async {
    final response = await apiService.invoke<TableModel>(
      urlPath: '/qrcodes',
      type: RequestType.post,
      params: {
        'tableNumber': tableNumber,
        'seatNumber': seatNumber,
        'capacity': capacity,
        'hotelId': hotelId,
      },
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return TableModel.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Failed to add table');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Failed to add table');
    }
  }

  /// Update a table QR code
  Future<TableModel> updateTable({
    required String id,
    required String hotelId,
    required String tableNumber,
    required int seatNumber,
    int capacity = 2,
  }) async {
    final response = await apiService.invoke<TableModel>(
      urlPath: '/qrcodes/$id',
      type: RequestType.put,
      params: {
        'tableNumber': tableNumber,
        'seatNumber': seatNumber,
        'capacity': capacity,
        'hotelId': hotelId,
      },
      fun: (jsonString) {
        final json = jsonDecode(jsonString);
        if (json['success'] == true) {
          return TableModel.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Failed to update table');
        }
      },
    );

    if (response is DataSuccess) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Failed to update table');
    }
  }
}
