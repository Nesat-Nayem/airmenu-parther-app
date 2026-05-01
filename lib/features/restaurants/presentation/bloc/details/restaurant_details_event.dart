import 'package:equatable/equatable.dart';

abstract class RestaurantDetailsEvent extends Equatable {
  const RestaurantDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurantDetails extends RestaurantDetailsEvent {
  final String restaurantId;

  const LoadRestaurantDetails(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class SwitchDetailsTab extends RestaurantDetailsEvent {
  final int index;

  const SwitchDetailsTab(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadBranches extends RestaurantDetailsEvent {
  final String restaurantId;
  const LoadBranches(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

class UpdateBranch extends RestaurantDetailsEvent {
  final String branchId;
  final String name;
  final String location;
  const UpdateBranch({required this.branchId, required this.name, required this.location});
  @override
  List<Object?> get props => [branchId, name, location];
}

class DeleteBranch extends RestaurantDetailsEvent {
  final String branchId;
  final String restaurantId;
  const DeleteBranch({required this.branchId, required this.restaurantId});
  @override
  List<Object?> get props => [branchId, restaurantId];
}
