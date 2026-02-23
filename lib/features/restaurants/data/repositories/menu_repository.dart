import 'dart:convert';
import 'dart:typed_data';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MenuRepository {
  final ApiService _apiService;

  MenuRepository(this._apiService);

  /// Get menu categories for a restaurant
  Future<List<MenuCategory>> getMenuCategories(String hotelId) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.hotelMenu(hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        List<dynamic>? categoriesList;

        if (data is List) {
          categoriesList = data;
        } else if (data is Map<String, dynamic>) {
          categoriesList = data['data'] as List<dynamic>? ?? [];
        }

        return categoriesList
                ?.map((item) =>
                    MenuCategory.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add a new menu category
  Future<bool> addMenuCategory({
    required String hotelId,
    required String name,
    required String imagePath,
  }) async {
    try {
      final response = await _apiService.invokeMultipart(
        urlPath: ApiEndpoints.menuCategories(hotelId),
        type: RequestType.post,
        fields: {'name': name},
        files: {'image': imagePath},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Update a menu category
  Future<bool> updateMenuCategory({
    required String hotelId,
    required String categoryName,
    required String newName,
    String? imagePath,
  }) async {
    try {
      final response = await _apiService.invokeMultipart(
        urlPath: ApiEndpoints.menuCategory(hotelId, Uri.encodeComponent(categoryName)),
        type: RequestType.put,
        fields: {'name': newName},
        files: imagePath != null ? {'image': imagePath} : {},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Delete a menu category
  Future<bool> deleteMenuCategory({
    required String hotelId,
    required String categoryName,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.menuCategory(hotelId, Uri.encodeComponent(categoryName)),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Add a food item to a category
  Future<bool> addFoodItem({
    required String hotelId,
    required String categoryName,
    required String title,
    required String description,
    required double price,
    required String imagePath,
    List<String>? itemType,
    List<String>? attributes,
    List<FoodItemOption>? options,
    String? sortdesc,
    String? offer,
    String? station,
    int? basePrepTimeMinutes,
    double? complexityFactor,
    int? maxPerSlot,
  }) async {
    try {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'price': price.toString(),
      };

      if (itemType != null && itemType.isNotEmpty) {
        fields['itemType'] = jsonEncode(itemType);
      }
      if (attributes != null && attributes.isNotEmpty) {
        fields['attributes'] = jsonEncode(attributes);
      }
      if (options != null && options.isNotEmpty) {
        fields['options'] = jsonEncode(options.map((e) => e.toJson()).toList());
      }
      if (sortdesc != null) fields['sortdesc'] = sortdesc;
      if (offer != null) fields['offer'] = offer;
      if (station != null) fields['station'] = station;
      if (basePrepTimeMinutes != null) {
        fields['basePrepTimeMinutes'] = basePrepTimeMinutes.toString();
      }
      if (complexityFactor != null) {
        fields['complexityFactor'] = complexityFactor.toString();
      }
      if (maxPerSlot != null) {
        fields['maxPerSlot'] = maxPerSlot.toString();
      }

      final response = await _apiService.invokeMultipart(
        urlPath: ApiEndpoints.menuCategoryItems(hotelId, Uri.encodeComponent(categoryName)),
        type: RequestType.post,
        fields: fields,
        files: {'image': imagePath},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Update a food item
  Future<bool> updateFoodItem({
    required String hotelId,
    required String foodId,
    required String title,
    required String description,
    required double price,
    String? imagePath,
    List<String>? itemType,
    List<String>? attributes,
    List<FoodItemOption>? options,
    String? sortdesc,
    String? offer,
    String? station,
    int? basePrepTimeMinutes,
    double? complexityFactor,
    int? maxPerSlot,
  }) async {
    try {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'price': price.toString(),
      };

      if (itemType != null) {
        fields['itemType'] = jsonEncode(itemType);
      }
      if (attributes != null) {
        fields['attributes'] = jsonEncode(attributes);
      }
      if (options != null) {
        fields['options'] = jsonEncode(options.map((e) => e.toJson()).toList());
      }
      if (sortdesc != null) fields['sortdesc'] = sortdesc;
      if (offer != null) fields['offer'] = offer;
      if (station != null) fields['station'] = station;
      if (basePrepTimeMinutes != null) {
        fields['basePrepTimeMinutes'] = basePrepTimeMinutes.toString();
      }
      if (complexityFactor != null) {
        fields['complexityFactor'] = complexityFactor.toString();
      }
      if (maxPerSlot != null) {
        fields['maxPerSlot'] = maxPerSlot.toString();
      }

      final response = await _apiService.invokeMultipart(
        urlPath: ApiEndpoints.foodItem(hotelId, foodId),
        type: RequestType.put,
        fields: fields,
        files: imagePath != null ? {'image': imagePath} : {},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Delete a food item
  Future<bool> deleteFoodItem({
    required String hotelId,
    required String foodId,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.foodItem(hotelId, foodId),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Get menu settings
  Future<MenuSettings> getMenuSettings(String hotelId) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.menuSettings(hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final settingsData = data['data'] as Map<String, dynamic>? ?? data;
          return MenuSettings.fromJson(settingsData);
        }
      }
      return MenuSettings();
    } catch (e) {
      return MenuSettings();
    }
  }

  /// Update menu settings
  Future<bool> updateMenuSettings({
    required String hotelId,
    required List<String> itemTypes,
    required List<String> attributes,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.menuSettings(hotelId),
        type: RequestType.put,
        params: {
          'itemTypes': itemTypes,
          'attributes': attributes,
        },
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Extract menu from image using AI
  Future<ExtractMenuResponse?> extractMenuFromImage({
    required String imageBase64,
    required String mimeType,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.extractMenuFromImage,
        type: RequestType.post,
        params: {
          'imageBase64': imageBase64,
          'mimeType': mimeType,
        },
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final responseData = data['data'] as Map<String, dynamic>? ?? data;
          return ExtractMenuResponse.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Import extracted menu to hotel
  Future<ImportMenuResponse?> importExtractedMenu({
    required String hotelId,
    required List<ExtractedCategory> categories,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.importExtractedMenu,
        type: RequestType.post,
        params: {
          'hotelId': hotelId,
          'categories': categories.map((e) => e.toJson()).toList(),
        },
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final responseData = data['data'] as Map<String, dynamic>? ?? data;
          return ImportMenuResponse.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== BYTES-BASED METHODS FOR FLUTTER WEB ====================

  /// Add a new menu category with image bytes
  Future<bool> addMenuCategoryWithBytes({
    required String hotelId,
    required String name,
    required Uint8List imageBytes,
  }) async {
    try {
      final response = await _apiService.invokeMultipartWithBytes(
        urlPath: ApiEndpoints.menuCategories(hotelId),
        type: RequestType.post,
        fields: {'name': name},
        fileBytes: {'image': imageBytes},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Update a menu category with image bytes
  Future<bool> updateMenuCategoryWithBytes({
    required String hotelId,
    required String categoryName,
    required String newName,
    Uint8List? imageBytes,
  }) async {
    try {
      final response = await _apiService.invokeMultipartWithBytes(
        urlPath: ApiEndpoints.menuCategory(hotelId, Uri.encodeComponent(categoryName)),
        type: RequestType.put,
        fields: {'name': newName},
        fileBytes: imageBytes != null ? {'image': imageBytes} : null,
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Add a food item with image bytes
  Future<bool> addFoodItemWithBytes({
    required String hotelId,
    required String categoryName,
    required String title,
    required String description,
    required double price,
    required Uint8List imageBytes,
    List<String>? itemType,
    List<String>? attributes,
    List<FoodItemOption>? options,
    String? sortdesc,
    String? offer,
    String? station,
    int? basePrepTimeMinutes,
    double? complexityFactor,
    int? maxPerSlot,
  }) async {
    try {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'price': price.toString(),
      };

      if (itemType != null && itemType.isNotEmpty) {
        fields['itemType'] = jsonEncode(itemType);
      }
      if (attributes != null && attributes.isNotEmpty) {
        fields['attributes'] = jsonEncode(attributes);
      }
      if (options != null && options.isNotEmpty) {
        fields['options'] = jsonEncode(options.map((e) => e.toJson()).toList());
      }
      if (sortdesc != null) fields['sortdesc'] = sortdesc;
      if (offer != null) fields['offer'] = offer;
      if (station != null) fields['station'] = station;
      if (basePrepTimeMinutes != null) {
        fields['basePrepTimeMinutes'] = basePrepTimeMinutes.toString();
      }
      if (complexityFactor != null) {
        fields['complexityFactor'] = complexityFactor.toString();
      }
      if (maxPerSlot != null) {
        fields['maxPerSlot'] = maxPerSlot.toString();
      }

      final response = await _apiService.invokeMultipartWithBytes(
        urlPath: ApiEndpoints.menuCategoryItems(hotelId, Uri.encodeComponent(categoryName)),
        type: RequestType.post,
        fields: fields,
        fileBytes: {'image': imageBytes},
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Update a food item with image bytes
  Future<bool> updateFoodItemWithBytes({
    required String hotelId,
    required String foodId,
    required String title,
    required String description,
    required double price,
    Uint8List? imageBytes,
    List<String>? itemType,
    List<String>? attributes,
    List<FoodItemOption>? options,
    String? sortdesc,
    String? offer,
    String? station,
    int? basePrepTimeMinutes,
    double? complexityFactor,
    int? maxPerSlot,
  }) async {
    try {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'price': price.toString(),
      };

      if (itemType != null) {
        fields['itemType'] = jsonEncode(itemType);
      }
      if (attributes != null) {
        fields['attributes'] = jsonEncode(attributes);
      }
      if (options != null) {
        fields['options'] = jsonEncode(options.map((e) => e.toJson()).toList());
      }
      if (sortdesc != null) fields['sortdesc'] = sortdesc;
      if (offer != null) fields['offer'] = offer;
      if (station != null) fields['station'] = station;
      if (basePrepTimeMinutes != null) {
        fields['basePrepTimeMinutes'] = basePrepTimeMinutes.toString();
      }
      if (complexityFactor != null) {
        fields['complexityFactor'] = complexityFactor.toString();
      }
      if (maxPerSlot != null) {
        fields['maxPerSlot'] = maxPerSlot.toString();
      }

      final response = await _apiService.invokeMultipartWithBytes(
        urlPath: ApiEndpoints.foodItem(hotelId, foodId),
        type: RequestType.put,
        fields: fields,
        fileBytes: imageBytes != null ? {'image': imageBytes} : null,
        fun: (data) => jsonDecode(data),
      );

      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }
}
