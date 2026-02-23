import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuCategory> categories;
  final MenuSettings settings;
  final bool isAddingCategory;
  final bool isUpdatingCategory;
  final bool isDeletingCategory;
  final String? deletingCategoryName;
  final bool isAddingItem;
  final String? addingItemToCategoryName;
  final bool isUpdatingItem;
  final bool isDeletingItem;
  final String? deletingItemId;
  final bool isUpdatingSettings;
  final bool isExtractingMenu;
  final bool isImportingMenu;
  final ExtractMenuResponse? extractedMenu;
  final String? errorMessage;
  final String? successMessage;

  const MenuLoaded({
    required this.categories,
    required this.settings,
    this.isAddingCategory = false,
    this.isUpdatingCategory = false,
    this.isDeletingCategory = false,
    this.deletingCategoryName,
    this.isAddingItem = false,
    this.addingItemToCategoryName,
    this.isUpdatingItem = false,
    this.isDeletingItem = false,
    this.deletingItemId,
    this.isUpdatingSettings = false,
    this.isExtractingMenu = false,
    this.isImportingMenu = false,
    this.extractedMenu,
    this.errorMessage,
    this.successMessage,
  });

  MenuLoaded copyWith({
    List<MenuCategory>? categories,
    MenuSettings? settings,
    bool? isAddingCategory,
    bool? isUpdatingCategory,
    bool? isDeletingCategory,
    String? deletingCategoryName,
    bool? isAddingItem,
    String? addingItemToCategoryName,
    bool? isUpdatingItem,
    bool? isDeletingItem,
    String? deletingItemId,
    bool? isUpdatingSettings,
    bool? isExtractingMenu,
    bool? isImportingMenu,
    ExtractMenuResponse? extractedMenu,
    String? errorMessage,
    String? successMessage,
    bool clearExtractedMenu = false,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearDeletingCategory = false,
    bool clearAddingItemToCategory = false,
    bool clearDeletingItem = false,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      settings: settings ?? this.settings,
      isAddingCategory: isAddingCategory ?? this.isAddingCategory,
      isUpdatingCategory: isUpdatingCategory ?? this.isUpdatingCategory,
      isDeletingCategory: isDeletingCategory ?? this.isDeletingCategory,
      deletingCategoryName: clearDeletingCategory ? null : (deletingCategoryName ?? this.deletingCategoryName),
      isAddingItem: isAddingItem ?? this.isAddingItem,
      addingItemToCategoryName: clearAddingItemToCategory ? null : (addingItemToCategoryName ?? this.addingItemToCategoryName),
      isUpdatingItem: isUpdatingItem ?? this.isUpdatingItem,
      isDeletingItem: isDeletingItem ?? this.isDeletingItem,
      deletingItemId: clearDeletingItem ? null : (deletingItemId ?? this.deletingItemId),
      isUpdatingSettings: isUpdatingSettings ?? this.isUpdatingSettings,
      isExtractingMenu: isExtractingMenu ?? this.isExtractingMenu,
      isImportingMenu: isImportingMenu ?? this.isImportingMenu,
      extractedMenu: clearExtractedMenu ? null : (extractedMenu ?? this.extractedMenu),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        categories,
        settings,
        isAddingCategory,
        isUpdatingCategory,
        isDeletingCategory,
        deletingCategoryName,
        isAddingItem,
        addingItemToCategoryName,
        isUpdatingItem,
        isDeletingItem,
        deletingItemId,
        isUpdatingSettings,
        isExtractingMenu,
        isImportingMenu,
        extractedMenu,
        errorMessage,
        successMessage,
      ];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
