import 'dart:convert';

import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Loads and caches global vendor sidebar visibility flags set by admin.
class VendorNavMenuFlagsService {
  final ApiService _api = locator<ApiService>();

  Map<String, bool> _flags = _defaultFlags();
  bool _loaded = false;

  static Map<String, bool> _defaultFlags() {
    return {
      for (final item in vendorNavMenuFeatureFlags) item.vendorNavFlagKey: true,
    };
  }

  Map<String, bool> get flags => Map.unmodifiable(_flags);

  bool isEnabled(NavMenuItem item) {
    if (!vendorNavMenuFeatureFlags.contains(item)) return true;
    return _flags[item.vendorNavFlagKey] ?? true;
  }

  Future<Map<String, bool>> load({bool force = false}) async {
    if (_loaded && !force) return _flags;

    try {
      final response = await _api.invoke<Map<String, dynamic>>(
        urlPath: ApiEndpoints.appSettings,
        type: RequestType.get,
        fun: (json) => jsonDecode(json) as Map<String, dynamic>,
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>? ?? {};
        final raw = data['vendorNavMenuFlags'] as Map<String, dynamic>? ?? {};
        final merged = _defaultFlags();
        for (final item in vendorNavMenuFeatureFlags) {
          final value = raw[item.vendorNavFlagKey];
          if (value is bool) {
            merged[item.vendorNavFlagKey] = value;
          }
        }
        _flags = merged;
        _loaded = true;
      }
    } catch (_) {
      _flags = _defaultFlags();
      _loaded = true;
    }

    return _flags;
  }

  Future<bool> updateFlag(String key, bool enabled) async {
    final response = await _api.invoke<Map<String, dynamic>>(
      urlPath: ApiEndpoints.vendorNavMenuFlags,
      type: RequestType.put,
      params: {
        'flags': {key: enabled},
      },
      fun: (json) => jsonDecode(json) as Map<String, dynamic>,
    );

    if (response is! DataSuccess || response.data == null) {
      return false;
    }

    final data = response.data!['data'] as Map<String, dynamic>? ?? {};
    final raw = data['vendorNavMenuFlags'] as Map<String, dynamic>? ?? {};
    final merged = _defaultFlags();
    for (final item in vendorNavMenuFeatureFlags) {
      final value = raw[item.vendorNavFlagKey];
      if (value is bool) {
        merged[item.vendorNavFlagKey] = value;
      }
    }
    _flags = merged;
    _loaded = true;
    return true;
  }

  void invalidate() {
    _loaded = false;
  }
}
