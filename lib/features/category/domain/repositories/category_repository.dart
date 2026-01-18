import 'package:dartz/dartz.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  /// Fetch all categories
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Create a new category
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String title,
    required String imagePath,
  });

  /// Update an existing category
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String title,
    String? imagePath,
  });

  /// Delete a category
  Future<Either<Failure, void>> deleteCategory(String id);
}
