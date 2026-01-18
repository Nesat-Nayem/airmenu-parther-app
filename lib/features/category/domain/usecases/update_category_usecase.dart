import 'package:dartz/dartz.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/domain/repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required String id,
    required String title,
    String? imagePath,
  }) async {
    return await repository.updateCategory(
      id: id,
      title: title,
      imagePath: imagePath,
    );
  }
}
