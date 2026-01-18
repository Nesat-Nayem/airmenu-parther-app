import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {}

class RefreshCategoriesEvent extends CategoryEvent {}

class CreateCategoryEvent extends CategoryEvent {
  final String title;
  final String imagePath;

  const CreateCategoryEvent({required this.title, required this.imagePath});

  @override
  List<Object?> get props => [title, imagePath];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String title;
  final String? imagePath;

  const UpdateCategoryEvent({
    required this.id,
    required this.title,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, title, imagePath];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchCategoriesEvent extends CategoryEvent {
  final String query;

  const SearchCategoriesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
