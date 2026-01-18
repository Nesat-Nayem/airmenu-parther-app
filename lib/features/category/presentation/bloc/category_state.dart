import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> filteredCategories;
  final String searchQuery;

  const CategoryLoaded({
    required this.categories,
    required this.filteredCategories,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [categories, filteredCategories, searchQuery];

  CategoryLoaded copyWith({
    List<CategoryEntity>? categories,
    List<CategoryEntity>? filteredCategories,
    String? searchQuery,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryEmpty extends CategoryState {
  final String message;

  const CategoryEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationLoading extends CategoryState {
  final String operation;

  const CategoryOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}
