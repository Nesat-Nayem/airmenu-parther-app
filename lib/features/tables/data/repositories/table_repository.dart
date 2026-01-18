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
}
