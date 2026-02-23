import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _repository;

  MenuBloc(this._repository) : super(const MenuInitial()) {
    on<LoadMenuCategories>(_onLoadMenuCategories);
    on<LoadMenuSettings>(_onLoadMenuSettings);
    on<AddMenuCategory>(_onAddMenuCategory);
    on<UpdateMenuCategory>(_onUpdateMenuCategory);
    on<DeleteMenuCategory>(_onDeleteMenuCategory);
    on<AddFoodItem>(_onAddFoodItem);
    on<UpdateFoodItem>(_onUpdateFoodItem);
    on<DeleteFoodItem>(_onDeleteFoodItem);
    on<UpdateMenuSettings>(_onUpdateMenuSettings);
    on<ExtractMenuFromImage>(_onExtractMenuFromImage);
    on<ImportExtractedMenu>(_onImportExtractedMenu);
    on<ClearExtractedMenu>(_onClearExtractedMenu);
    // Bytes-based events for Flutter Web compatibility
    on<AddMenuCategoryWithBytes>(_onAddMenuCategoryWithBytes);
    on<UpdateMenuCategoryWithBytes>(_onUpdateMenuCategoryWithBytes);
    on<AddFoodItemWithBytes>(_onAddFoodItemWithBytes);
    on<UpdateFoodItemWithBytes>(_onUpdateFoodItemWithBytes);
  }

  Future<void> _onLoadMenuCategories(
    LoadMenuCategories event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());

    try {
      final categories = await _repository.getMenuCategories(event.hotelId);
      final settings = await _repository.getMenuSettings(event.hotelId);

      emit(MenuLoaded(
        categories: categories,
        settings: settings,
      ));
    } catch (e) {
      emit(MenuError('Failed to load menu: $e'));
    }
  }

  Future<void> _onLoadMenuSettings(
    LoadMenuSettings event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      try {
        final settings = await _repository.getMenuSettings(event.hotelId);
        emit(currentState.copyWith(settings: settings));
      } catch (e) {
        emit(currentState.copyWith(errorMessage: 'Failed to load settings'));
      }
    }
  }

  Future<void> _onAddMenuCategory(
    AddMenuCategory event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isAddingCategory: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.addMenuCategory(
          hotelId: event.hotelId,
          name: event.name,
          imagePath: event.imagePath,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isAddingCategory: false,
            successMessage: 'Category added successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isAddingCategory: false,
            errorMessage: 'Failed to add category',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isAddingCategory: false,
          errorMessage: 'Error adding category: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateMenuCategory(
    UpdateMenuCategory event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isUpdatingCategory: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.updateMenuCategory(
          hotelId: event.hotelId,
          categoryName: event.categoryName,
          newName: event.newName,
          imagePath: event.imagePath,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isUpdatingCategory: false,
            successMessage: 'Category updated successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isUpdatingCategory: false,
            errorMessage: 'Failed to update category',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isUpdatingCategory: false,
          errorMessage: 'Error updating category: $e',
        ));
      }
    }
  }

  Future<void> _onDeleteMenuCategory(
    DeleteMenuCategory event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(
        isDeletingCategory: true,
        deletingCategoryName: event.categoryName,
        clearError: true,
        clearSuccess: true,
      ));

      try {
        final success = await _repository.deleteMenuCategory(
          hotelId: event.hotelId,
          categoryName: event.categoryName,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isDeletingCategory: false,
            clearDeletingCategory: true,
            successMessage: 'Category deleted successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isDeletingCategory: false,
            clearDeletingCategory: true,
            errorMessage: 'Failed to delete category',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isDeletingCategory: false,
          clearDeletingCategory: true,
          errorMessage: 'Error deleting category: $e',
        ));
      }
    }
  }

  Future<void> _onAddFoodItem(
    AddFoodItem event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isAddingItem: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.addFoodItem(
          hotelId: event.hotelId,
          categoryName: event.categoryName,
          title: event.title,
          description: event.description,
          price: event.price,
          imagePath: event.imagePath,
          itemType: event.itemType,
          attributes: event.attributes,
          options: event.options,
          sortdesc: event.sortdesc,
          offer: event.offer,
          station: event.station,
          basePrepTimeMinutes: event.basePrepTimeMinutes,
          complexityFactor: event.complexityFactor,
          maxPerSlot: event.maxPerSlot,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isAddingItem: false,
            successMessage: 'Food item added successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isAddingItem: false,
            errorMessage: 'Failed to add food item',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isAddingItem: false,
          errorMessage: 'Error adding food item: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateFoodItem(
    UpdateFoodItem event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isUpdatingItem: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.updateFoodItem(
          hotelId: event.hotelId,
          foodId: event.foodId,
          title: event.title,
          description: event.description,
          price: event.price,
          imagePath: event.imagePath,
          itemType: event.itemType,
          attributes: event.attributes,
          options: event.options,
          sortdesc: event.sortdesc,
          offer: event.offer,
          station: event.station,
          basePrepTimeMinutes: event.basePrepTimeMinutes,
          complexityFactor: event.complexityFactor,
          maxPerSlot: event.maxPerSlot,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isUpdatingItem: false,
            successMessage: 'Food item updated successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isUpdatingItem: false,
            errorMessage: 'Failed to update food item',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isUpdatingItem: false,
          errorMessage: 'Error updating food item: $e',
        ));
      }
    }
  }

  Future<void> _onDeleteFoodItem(
    DeleteFoodItem event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(
        isDeletingItem: true,
        deletingItemId: event.foodId,
        clearError: true,
        clearSuccess: true,
      ));

      try {
        final success = await _repository.deleteFoodItem(
          hotelId: event.hotelId,
          foodId: event.foodId,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isDeletingItem: false,
            clearDeletingItem: true,
            successMessage: 'Food item deleted successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isDeletingItem: false,
            clearDeletingItem: true,
            errorMessage: 'Failed to delete food item',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isDeletingItem: false,
          clearDeletingItem: true,
          errorMessage: 'Error deleting food item: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateMenuSettings(
    UpdateMenuSettings event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isUpdatingSettings: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.updateMenuSettings(
          hotelId: event.hotelId,
          itemTypes: event.itemTypes,
          attributes: event.attributes,
        );

        if (success) {
          final settings = await _repository.getMenuSettings(event.hotelId);
          emit(currentState.copyWith(
            settings: settings,
            isUpdatingSettings: false,
            successMessage: 'Menu settings saved successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isUpdatingSettings: false,
            errorMessage: 'Failed to save menu settings',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isUpdatingSettings: false,
          errorMessage: 'Error saving menu settings: $e',
        ));
      }
    }
  }

  Future<void> _onExtractMenuFromImage(
    ExtractMenuFromImage event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(
        isExtractingMenu: true,
        clearExtractedMenu: true,
        clearError: true,
        clearSuccess: true,
      ));

      try {
        final result = await _repository.extractMenuFromImage(
          imageBase64: event.imageBase64,
          mimeType: event.mimeType,
        );

        if (result != null) {
          emit(currentState.copyWith(
            isExtractingMenu: false,
            extractedMenu: result,
          ));
        } else {
          emit(currentState.copyWith(
            isExtractingMenu: false,
            errorMessage: 'Failed to extract menu from image',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isExtractingMenu: false,
          errorMessage: 'Error extracting menu: $e',
        ));
      }
    }
  }

  Future<void> _onImportExtractedMenu(
    ImportExtractedMenu event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isImportingMenu: true, clearError: true, clearSuccess: true));

      try {
        final result = await _repository.importExtractedMenu(
          hotelId: event.hotelId,
          categories: event.categories,
        );

        if (result != null) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isImportingMenu: false,
            clearExtractedMenu: true,
            successMessage: 'Menu imported successfully! Added ${result.categoriesAdded} categories and ${result.itemsAdded} items',
          ));
        } else {
          emit(currentState.copyWith(
            isImportingMenu: false,
            errorMessage: 'Failed to import menu',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isImportingMenu: false,
          errorMessage: 'Error importing menu: $e',
        ));
      }
    }
  }

  void _onClearExtractedMenu(
    ClearExtractedMenu event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(clearExtractedMenu: true));
    }
  }

  // Bytes-based event handlers for Flutter Web compatibility
  Future<void> _onAddMenuCategoryWithBytes(
    AddMenuCategoryWithBytes event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isAddingCategory: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.addMenuCategoryWithBytes(
          hotelId: event.hotelId,
          name: event.name,
          imageBytes: event.imageBytes,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isAddingCategory: false,
            successMessage: 'Category added successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isAddingCategory: false,
            errorMessage: 'Failed to add category',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isAddingCategory: false,
          errorMessage: 'Error adding category: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateMenuCategoryWithBytes(
    UpdateMenuCategoryWithBytes event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isUpdatingCategory: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.updateMenuCategoryWithBytes(
          hotelId: event.hotelId,
          categoryName: event.categoryName,
          newName: event.newName,
          imageBytes: event.imageBytes,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isUpdatingCategory: false,
            successMessage: 'Category updated successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isUpdatingCategory: false,
            errorMessage: 'Failed to update category',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isUpdatingCategory: false,
          errorMessage: 'Error updating category: $e',
        ));
      }
    }
  }

  Future<void> _onAddFoodItemWithBytes(
    AddFoodItemWithBytes event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(
        isAddingItem: true,
        addingItemToCategoryName: event.categoryName,
        clearError: true,
        clearSuccess: true,
      ));

      try {
        final success = await _repository.addFoodItemWithBytes(
          hotelId: event.hotelId,
          categoryName: event.categoryName,
          title: event.title,
          description: event.description,
          price: event.price,
          imageBytes: event.imageBytes,
          itemType: event.itemType,
          attributes: event.attributes,
          options: event.options,
          sortdesc: event.sortdesc,
          offer: event.offer,
          station: event.station,
          basePrepTimeMinutes: event.basePrepTimeMinutes,
          complexityFactor: event.complexityFactor,
          maxPerSlot: event.maxPerSlot,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isAddingItem: false,
            clearAddingItemToCategory: true,
            successMessage: 'Food item added successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isAddingItem: false,
            clearAddingItemToCategory: true,
            errorMessage: 'Failed to add food item',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isAddingItem: false,
          clearAddingItemToCategory: true,
          errorMessage: 'Error adding food item: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateFoodItemWithBytes(
    UpdateFoodItemWithBytes event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(isUpdatingItem: true, clearError: true, clearSuccess: true));

      try {
        final success = await _repository.updateFoodItemWithBytes(
          hotelId: event.hotelId,
          foodId: event.foodId,
          title: event.title,
          description: event.description,
          price: event.price,
          imageBytes: event.imageBytes,
          itemType: event.itemType,
          attributes: event.attributes,
          options: event.options,
          sortdesc: event.sortdesc,
          offer: event.offer,
          station: event.station,
          basePrepTimeMinutes: event.basePrepTimeMinutes,
          complexityFactor: event.complexityFactor,
          maxPerSlot: event.maxPerSlot,
        );

        if (success) {
          final categories = await _repository.getMenuCategories(event.hotelId);
          emit(currentState.copyWith(
            categories: categories,
            isUpdatingItem: false,
            successMessage: 'Food item updated successfully',
          ));
        } else {
          emit(currentState.copyWith(
            isUpdatingItem: false,
            errorMessage: 'Failed to update food item',
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isUpdatingItem: false,
          errorMessage: 'Error updating food item: $e',
        ));
      }
    }
  }
}
