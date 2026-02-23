import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuCategories extends MenuEvent {
  final String hotelId;

  const LoadMenuCategories(this.hotelId);

  @override
  List<Object?> get props => [hotelId];
}

class LoadMenuSettings extends MenuEvent {
  final String hotelId;

  const LoadMenuSettings(this.hotelId);

  @override
  List<Object?> get props => [hotelId];
}

class AddMenuCategory extends MenuEvent {
  final String hotelId;
  final String name;
  final String imagePath;

  const AddMenuCategory({
    required this.hotelId,
    required this.name,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [hotelId, name, imagePath];
}

class UpdateMenuCategory extends MenuEvent {
  final String hotelId;
  final String categoryName;
  final String newName;
  final String? imagePath;

  const UpdateMenuCategory({
    required this.hotelId,
    required this.categoryName,
    required this.newName,
    this.imagePath,
  });

  @override
  List<Object?> get props => [hotelId, categoryName, newName, imagePath];
}

class DeleteMenuCategory extends MenuEvent {
  final String hotelId;
  final String categoryName;

  const DeleteMenuCategory({
    required this.hotelId,
    required this.categoryName,
  });

  @override
  List<Object?> get props => [hotelId, categoryName];
}

class AddFoodItem extends MenuEvent {
  final String hotelId;
  final String categoryName;
  final String title;
  final String description;
  final double price;
  final String imagePath;
  final List<String>? itemType;
  final List<String>? attributes;
  final List<FoodItemOption>? options;
  final String? sortdesc;
  final String? offer;
  final String? station;
  final int? basePrepTimeMinutes;
  final double? complexityFactor;
  final int? maxPerSlot;

  const AddFoodItem({
    required this.hotelId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
    this.itemType,
    this.attributes,
    this.options,
    this.sortdesc,
    this.offer,
    this.station,
    this.basePrepTimeMinutes,
    this.complexityFactor,
    this.maxPerSlot,
  });

  @override
  List<Object?> get props => [
        hotelId,
        categoryName,
        title,
        description,
        price,
        imagePath,
        itemType,
        attributes,
        options,
        sortdesc,
        offer,
        station,
        basePrepTimeMinutes,
        complexityFactor,
        maxPerSlot,
      ];
}

class UpdateFoodItem extends MenuEvent {
  final String hotelId;
  final String foodId;
  final String title;
  final String description;
  final double price;
  final String? imagePath;
  final List<String>? itemType;
  final List<String>? attributes;
  final List<FoodItemOption>? options;
  final String? sortdesc;
  final String? offer;
  final String? station;
  final int? basePrepTimeMinutes;
  final double? complexityFactor;
  final int? maxPerSlot;

  const UpdateFoodItem({
    required this.hotelId,
    required this.foodId,
    required this.title,
    required this.description,
    required this.price,
    this.imagePath,
    this.itemType,
    this.attributes,
    this.options,
    this.sortdesc,
    this.offer,
    this.station,
    this.basePrepTimeMinutes,
    this.complexityFactor,
    this.maxPerSlot,
  });

  @override
  List<Object?> get props => [
        hotelId,
        foodId,
        title,
        description,
        price,
        imagePath,
        itemType,
        attributes,
        options,
        sortdesc,
        offer,
        station,
        basePrepTimeMinutes,
        complexityFactor,
        maxPerSlot,
      ];
}

class DeleteFoodItem extends MenuEvent {
  final String hotelId;
  final String foodId;

  const DeleteFoodItem({
    required this.hotelId,
    required this.foodId,
  });

  @override
  List<Object?> get props => [hotelId, foodId];
}

class UpdateMenuSettings extends MenuEvent {
  final String hotelId;
  final List<String> itemTypes;
  final List<String> attributes;

  const UpdateMenuSettings({
    required this.hotelId,
    required this.itemTypes,
    required this.attributes,
  });

  @override
  List<Object?> get props => [hotelId, itemTypes, attributes];
}

class ExtractMenuFromImage extends MenuEvent {
  final String imageBase64;
  final String mimeType;

  const ExtractMenuFromImage({
    required this.imageBase64,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [imageBase64, mimeType];
}

class ImportExtractedMenu extends MenuEvent {
  final String hotelId;
  final List<ExtractedCategory> categories;

  const ImportExtractedMenu({
    required this.hotelId,
    required this.categories,
  });

  @override
  List<Object?> get props => [hotelId, categories];
}

class ClearExtractedMenu extends MenuEvent {
  const ClearExtractedMenu();
}

// Bytes-based events for Flutter Web compatibility
class AddMenuCategoryWithBytes extends MenuEvent {
  final String hotelId;
  final String name;
  final Uint8List imageBytes;

  const AddMenuCategoryWithBytes({
    required this.hotelId,
    required this.name,
    required this.imageBytes,
  });

  @override
  List<Object?> get props => [hotelId, name, imageBytes];
}

class UpdateMenuCategoryWithBytes extends MenuEvent {
  final String hotelId;
  final String categoryName;
  final String newName;
  final Uint8List? imageBytes;

  const UpdateMenuCategoryWithBytes({
    required this.hotelId,
    required this.categoryName,
    required this.newName,
    this.imageBytes,
  });

  @override
  List<Object?> get props => [hotelId, categoryName, newName, imageBytes];
}

class AddFoodItemWithBytes extends MenuEvent {
  final String hotelId;
  final String categoryName;
  final String title;
  final String description;
  final double price;
  final Uint8List imageBytes;
  final List<String>? itemType;
  final List<String>? attributes;
  final List<FoodItemOption>? options;
  final String? sortdesc;
  final String? offer;
  final String? station;
  final int? basePrepTimeMinutes;
  final double? complexityFactor;
  final int? maxPerSlot;

  const AddFoodItemWithBytes({
    required this.hotelId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.price,
    required this.imageBytes,
    this.itemType,
    this.attributes,
    this.options,
    this.sortdesc,
    this.offer,
    this.station,
    this.basePrepTimeMinutes,
    this.complexityFactor,
    this.maxPerSlot,
  });

  @override
  List<Object?> get props => [
        hotelId,
        categoryName,
        title,
        description,
        price,
        imageBytes,
        itemType,
        attributes,
        options,
        sortdesc,
        offer,
        station,
        basePrepTimeMinutes,
        complexityFactor,
        maxPerSlot,
      ];
}

class UpdateFoodItemWithBytes extends MenuEvent {
  final String hotelId;
  final String foodId;
  final String title;
  final String description;
  final double price;
  final Uint8List? imageBytes;
  final List<String>? itemType;
  final List<String>? attributes;
  final List<FoodItemOption>? options;
  final String? sortdesc;
  final String? offer;
  final String? station;
  final int? basePrepTimeMinutes;
  final double? complexityFactor;
  final int? maxPerSlot;

  const UpdateFoodItemWithBytes({
    required this.hotelId,
    required this.foodId,
    required this.title,
    required this.description,
    required this.price,
    this.imageBytes,
    this.itemType,
    this.attributes,
    this.options,
    this.sortdesc,
    this.offer,
    this.station,
    this.basePrepTimeMinutes,
    this.complexityFactor,
    this.maxPerSlot,
  });

  @override
  List<Object?> get props => [
        hotelId,
        foodId,
        title,
        description,
        price,
        imageBytes,
        itemType,
        attributes,
        options,
        sortdesc,
        offer,
        station,
        basePrepTimeMinutes,
        complexityFactor,
        maxPerSlot,
      ];
}
