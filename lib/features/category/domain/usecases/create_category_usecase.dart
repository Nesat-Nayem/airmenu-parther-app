import 'package:dartz/dartz.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/domain/repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required String title,
    required String imagePath,
  }) async {
    return await repository.createCategory(title: title, imagePath: imagePath);
  }
}
