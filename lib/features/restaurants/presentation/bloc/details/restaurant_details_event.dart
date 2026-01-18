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
