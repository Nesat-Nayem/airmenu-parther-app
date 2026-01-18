import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/create_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/update_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_event.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<RefreshCategoriesEvent>(_onRefreshCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SearchCategoriesEvent>(_onSearchCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getCategoriesUseCase();

    result.fold((failure) => emit(CategoryError(failure.message)), (
      categories,
    ) {
      if (categories.isEmpty) {
        emit(const CategoryEmpty('No categories found'));
      } else {
        emit(
          CategoryLoaded(
            categories: categories,
            filteredCategories: categories,
          ),
        );
      }
    });
  }

  Future<void> _onRefreshCategories(
    RefreshCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await getCategoriesUseCase();

    result.fold((failure) => emit(CategoryError(failure.message)), (
      categories,
    ) {
      if (categories.isEmpty) {
        emit(const CategoryEmpty('No categories found'));
      } else {
        emit(
          CategoryLoaded(
            categories: categories,
            filteredCategories: categories,
          ),
        );
      }
    });
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryOperationLoading('Creating category...'));

    final result = await createCategoryUseCase(
      title: event.title,
      imagePath: event.imagePath,
    );

    await result.fold((failure) async => emit(CategoryError(failure.message)), (
      category,
    ) async {
      emit(const CategoryOperationSuccess('Category created successfully'));
      // Reload categories
      add(LoadCategoriesEvent());
    });
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryOperationLoading('Updating category...'));

    final result = await updateCategoryUseCase(
      id: event.id,
      title: event.title,
      imagePath: event.imagePath,
    );

    await result.fold((failure) async => emit(CategoryError(failure.message)), (
      category,
    ) async {
      emit(const CategoryOperationSuccess('Category updated successfully'));
      // Reload categories
      add(LoadCategoriesEvent());
    });
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryOperationLoading('Deleting category...'));

    final result = await deleteCategoryUseCase(event.id);

    await result.fold((failure) async => emit(CategoryError(failure.message)), (
      _,
    ) async {
      emit(const CategoryOperationSuccess('Category deleted successfully'));
      // Reload categories
      add(LoadCategoriesEvent());
    });
  }

  void _onSearchCategories(
    SearchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredCategories: currentState.categories,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.categories
            .where((category) => category.title.toLowerCase().contains(query))
            .toList();

        emit(
          currentState.copyWith(
            filteredCategories: filtered,
            searchQuery: query,
          ),
        );
      }
    }
  }
}
