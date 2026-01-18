import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';

abstract class RestaurantFormEvent extends Equatable {
  const RestaurantFormEvent();

  @override
  List<Object?> get props => [];
}

class CreateRestaurantEvent extends RestaurantFormEvent {
  final RestaurantFormModel formModel;
  final XFile? imageFile;

  const CreateRestaurantEvent({required this.formModel, this.imageFile});

  @override
  List<Object?> get props => [formModel, imageFile];
}

class UpdateRestaurantEvent extends RestaurantFormEvent {
  final String restaurantId;
  final RestaurantFormModel formModel;
  final XFile? imageFile;

  const UpdateRestaurantEvent({
    required this.restaurantId,
    required this.formModel,
    this.imageFile,
  });

  @override
  List<Object?> get props => [restaurantId, formModel, imageFile];
}
