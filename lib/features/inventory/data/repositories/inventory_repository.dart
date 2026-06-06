import 'dart:convert';
import 'dart:typed_data';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_error.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';

class InventoryRepository {
  final ApiService _api;
  InventoryRepository(this._api);

  Future<String?> _getHotelId() async {
    final id = await locator<LocalStorage>().getString(localStorageKey: 'hotelId');
    return (id == null || id.isEmpty) ? null : id;
  }

  static String _buildQuery(Map<String, String> p) =>
      p.isEmpty ? '' : '?${p.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

  static DataFailure<T> _fail<T>(String msg) =>
      DataFailure<T>(DataError(message: msg, statusCode: 0));

  // ─── Materials ──────────────────────────────────────────────────────────────

  Future<DataState<List<InventoryItem>>> getMaterials({String? q, bool lowStock = false}) async {
    try {
      final p = <String, String>{};
      if (q != null && q.isNotEmpty) p['q'] = q;
      if (lowStock) p['lowStock'] = 'true';
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryMaterials}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch materials');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<InventoryItem>> createMaterial(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryMaterials,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(InventoryItem.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to create material');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<InventoryItem>> updateMaterial(String id, Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryMaterial(id),
        type: RequestType.put,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(InventoryItem.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to update material');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> deleteMaterial(String id) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryMaterial(id),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return _fail('Failed to delete material');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<DataState<List<InventoryTransaction>>> getTransactions({
    String? materialId,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final p = <String, String>{};
      if (materialId != null) p['materialId'] = materialId;
      if (type != null) p['type'] = type;
      if (startDate != null) p['startDate'] = startDate;
      if (endDate != null) p['endDate'] = endDate;
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryTransactions}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => InventoryTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch transactions');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> createTransaction(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryTransactions,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return DataFailure<bool>(
        (res as DataFailure).error ?? DataError(message: 'Failed to create transaction', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<InventoryTransaction>> updateTransaction(String id, Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryTransaction(id),
        type: RequestType.put,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(InventoryTransaction.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<InventoryTransaction>(
        (res as DataFailure).error ?? DataError(message: 'Failed to update transaction', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Recipes ───────────────────────────────────────────────────────────────

  Future<DataState<List<RecipeModel>>> getRecipes({String? menuItemId}) async {
    try {
      final p = <String, String>{'details': 'true'};
      if (menuItemId != null) p['menuItemId'] = menuItemId;
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryRecipes}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch recipes');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<RecipeModel>> createRecipe(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryRecipes,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(RecipeModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to create recipe');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<RecipeModel>> updateRecipe(String id, Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryRecipe(id),
        type: RequestType.put,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(RecipeModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to update recipe');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> deleteRecipe(String id) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryRecipe(id),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return _fail('Failed to delete recipe');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  Future<DataState<InventoryAnalytics>> getOverviewReport({
    String? startDate,
    String? endDate,
    String groupBy = 'day',
  }) async {
    try {
      final p = <String, String>{'groupBy': groupBy};
      if (startDate != null) p['startDate'] = startDate;
      if (endDate != null) p['endDate'] = endDate;
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryReportOverview}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final d = res.data['data'] as Map<String, dynamic>? ?? {};
        final series = (d['series'] as List? ?? [])
            .map((e) => OverviewSeriesPoint.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(InventoryAnalytics.fromSeries(series));
      }
      return _fail('Failed to fetch report');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<List<InventoryItem>>> getStockSummary() async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryReportStockSummary,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch stock summary');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Vendors ───────────────────────────────────────────────────────────────

  Future<DataState<List<VendorModel>>> getVendors() async {
    try {
      final hotelId = await _getHotelId();
      final q = hotelId != null ? _buildQuery({'hotelId': hotelId}) : '';
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryVendors}$q',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return DataFailure<List<VendorModel>>(
        (res as DataFailure).error ?? DataError(message: 'Failed to fetch vendors', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<VendorModel>> createVendor(Map<String, dynamic> params) async {
    try {
      final hotelId = await _getHotelId();
      final body = {...params, if (hotelId != null && !params.containsKey('hotelId')) 'hotelId': hotelId};
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendors,
        type: RequestType.post,
        params: body,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(VendorModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<VendorModel>(
        (res as DataFailure).error ?? DataError(message: 'Failed to create vendor', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<VendorModel>> updateVendor(String id, Map<String, dynamic> params) async {
    try {
      final hotelId = await _getHotelId();
      final body = {...params, if (hotelId != null && !params.containsKey('hotelId')) 'hotelId': hotelId};
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendor(id),
        type: RequestType.put,
        params: body,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(VendorModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<VendorModel>(
        (res as DataFailure).error ?? DataError(message: 'Failed to update vendor', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> deleteVendor(String id) async {
    try {
      final hotelId = await _getHotelId();
      final q = hotelId != null ? _buildQuery({'hotelId': hotelId}) : '';
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryVendor(id)}$q',
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return DataFailure<bool>(
        (res as DataFailure).error ?? DataError(message: 'Failed to delete vendor', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Purchase Orders ───────────────────────────────────────────────────────

  Future<DataState<List<PurchaseOrder>>> getPurchaseOrders({String? status}) async {
    try {
      final hotelId = await _getHotelId();
      final p = <String, String>{};
      if (hotelId != null) p['hotelId'] = hotelId;
      if (status != null) p['status'] = status;
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryPurchaseOrders}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return DataFailure<List<PurchaseOrder>>(
        (res as DataFailure).error ?? DataError(message: 'Failed to fetch purchase orders', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<PurchaseOrder>> createPurchaseOrder(Map<String, dynamic> params) async {
    try {
      final hotelId = await _getHotelId();
      final body = {...params, if (hotelId != null && !params.containsKey('hotelId')) 'hotelId': hotelId};
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryPurchaseOrders,
        type: RequestType.post,
        params: body,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(PurchaseOrder.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<PurchaseOrder>(
        (res as DataFailure).error ?? DataError(message: 'Failed to create purchase order', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<PurchaseOrder>> updatePurchaseOrderStatus(String id, String status) async {
    try {
      final hotelId = await _getHotelId();
      final body = {'status': status, if (hotelId != null) 'hotelId': hotelId};
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryPurchaseOrderStatus(id),
        type: RequestType.put,
        params: body,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(PurchaseOrder.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<PurchaseOrder>(
        (res as DataFailure).error ?? DataError(message: 'Failed to update purchase order', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<PurchaseOrder>> receivePurchaseOrder(String id, Map<String, dynamic> params) async {
    try {
      final hotelId = await _getHotelId();
      final body = {...params, if (hotelId != null && !params.containsKey('hotelId')) 'hotelId': hotelId};
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryPurchaseOrderReceive(id),
        type: RequestType.put,
        params: body,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(PurchaseOrder.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return DataFailure<PurchaseOrder>(
        (res as DataFailure).error ?? DataError(message: 'Failed to receive purchase order', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<List<StockBatch>>> getStockBatches({String? materialId}) async {
    try {
      final hotelId = await _getHotelId();
      final p = <String, String>{};
      if (hotelId != null) p['hotelId'] = hotelId;
      if (materialId != null) p['materialId'] = materialId;
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryStockBatches}${_buildQuery(p)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => StockBatch.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return DataFailure<List<StockBatch>>(
        (res as DataFailure).error ?? DataError(message: 'Failed to fetch stock batches', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<String>> uploadFile({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    try {
      if (filePath == null && bytes == null) {
        return _fail('No file selected');
      }
      final dynamic res;
      if (bytes != null) {
        res = await _api.invokeMultipartWithBytes(
          urlPath: '/uploads/single',
          type: RequestType.post,
          fields: const {},
          fileBytes: {'image': Uint8List.fromList(bytes)},
          fun: (data) => jsonDecode(data),
        );
      } else {
        res = await _api.invokeMultipart(
          urlPath: '/uploads/single',
          type: RequestType.post,
          fields: const {},
          files: {'image': filePath!},
          fun: (data) => jsonDecode(data),
        );
      }
      if (res is DataSuccess) {
        final url = (res.data['data']?['url'] ?? '').toString();
        if (url.isEmpty) return _fail('Upload failed');
        return DataSuccess(url);
      }
      return DataFailure<String>(
        (res as DataFailure).error ?? DataError(message: 'Upload failed', statusCode: 0),
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Locations ─────────────────────────────────────────────────────────────

  Future<DataState<List<LocationModel>>> getLocations() async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryLocations,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch locations');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<LocationModel>> createLocation(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryLocations,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(LocationModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to create location');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<LocationModel>> updateLocation(String id, Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryLocation(id),
        type: RequestType.put,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(LocationModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to update location');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> deleteLocation(String id) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryLocation(id),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return _fail('Failed to delete location');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Transfers ─────────────────────────────────────────────────────────────

  Future<DataState<List<StockTransferModel>>> getTransfers() async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryTransfers,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => StockTransferModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch transfers');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<StockTransferModel>> createTransfer(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryTransfers,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(StockTransferModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to create transfer');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<StockTransferModel>> updateTransferStatus(String id, String status) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryTransferStatus(id),
        type: RequestType.put,
        params: {'status': status},
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(StockTransferModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to update transfer status');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Price Comparison ──────────────────────────────────────────────────────

  Future<DataState<List<PriceComparisonItem>>> getPriceComparisonSummary() async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryPriceComparison,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final d = res.data['data'] as Map<String, dynamic>? ?? {};
        final list = (d['items'] as List? ?? [])
            .map((e) => PriceComparisonItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch price comparison summary');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<PriceComparisonDetail>> getPriceComparisonForMaterial(String materialId) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryPriceComparisonItem(materialId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(PriceComparisonDetail.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to fetch price comparison detail');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Forecasting ───────────────────────────────────────────────────────────

  Future<DataState<ForecastingData>> getForecasting({int days = 7}) async {
    try {
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryForecasting}?days=$days',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(ForecastingData.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to fetch forecasting data');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Export ────────────────────────────────────────────────────────────────

  Future<DataState<Uint8List>> exportData(List<String> types, String format) async {
    try {
      final hotelId = await _getHotelId();
      final p = <String, String>{
        'types': types.join(','),
        'format': format,
      };
      if (hotelId != null) p['hotelId'] = hotelId;
      return await _api.invokeBytes(
        urlPath: '${ApiEndpoints.inventoryExport}${_buildQuery(p)}',
      );
    } catch (e) {
      return _fail(e.toString());
    }
  }
}
