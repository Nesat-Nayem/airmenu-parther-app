import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:airmenuai_partner_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String title,
    required String imagePath,
  }) async {
    try {
      final category = await remoteDataSource.createCategory(
        title: title,
        imagePath: imagePath,
      );
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String title,
    String? imagePath,
  }) async {
    try {
      final category = await remoteDataSource.updateCategory(
        id: id,
        title: title,
        imagePath: imagePath,
      );
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
