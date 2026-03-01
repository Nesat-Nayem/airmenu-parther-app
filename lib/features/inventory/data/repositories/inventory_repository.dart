import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_error.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';

class InventoryRepository {
  final ApiService _api;
  InventoryRepository(this._api);

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
      return _fail('Failed to create transaction');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  // ─── Recipes ───────────────────────────────────────────────────────────────

  Future<DataState<List<RecipeModel>>> getRecipes({String? menuItemId}) async {
    try {
      final p = menuItemId != null ? {'menuItemId': menuItemId} : <String, String>{};
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
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendors,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        final list = (res.data['data'] as List? ?? [])
            .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DataSuccess(list);
      }
      return _fail('Failed to fetch vendors');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<VendorModel>> createVendor(Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendors,
        type: RequestType.post,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(VendorModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to create vendor');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<VendorModel>> updateVendor(String id, Map<String, dynamic> params) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendor(id),
        type: RequestType.put,
        params: params,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(VendorModel.fromJson(res.data['data'] as Map<String, dynamic>));
      }
      return _fail('Failed to update vendor');
    } catch (e) {
      return _fail(e.toString());
    }
  }

  Future<DataState<bool>> deleteVendor(String id) async {
    try {
      final res = await _api.invoke(
        urlPath: ApiEndpoints.inventoryVendor(id),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) return const DataSuccess(true);
      return _fail('Failed to delete vendor');
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

  Future<DataState<Map<String, dynamic>>> exportData(List<String> types) async {
    try {
      final q = types.join(',');
      final res = await _api.invoke(
        urlPath: '${ApiEndpoints.inventoryExport}?types=${Uri.encodeComponent(q)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (res is DataSuccess) {
        return DataSuccess(res.data['data'] as Map<String, dynamic>? ?? {});
      }
      return _fail('Failed to export data');
    } catch (e) {
      return _fail(e.toString());
    }
  }
}
