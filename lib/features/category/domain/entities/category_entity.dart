import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String title;
  final String image;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  const CategoryEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    image,
    isDeleted,
    createdAt,
    updatedAt,
  ];
}
