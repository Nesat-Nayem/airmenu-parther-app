import 'package:equatable/equatable.dart';
import '../../../data/models/admin/restaurant_creation_models.dart';

abstract class CreateRestaurantEvent extends Equatable {
  const CreateRestaurantEvent();

  @override
  List<Object?> get props => [];
}

class UpdateAutocompleteQuery extends CreateRestaurantEvent {
  final String query;
  const UpdateAutocompleteQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSuggestions extends CreateRestaurantEvent {
  const ClearSuggestions();
}

class SubmitRestaurant extends CreateRestaurantEvent {
  final RestaurantCreateRequestModel request;
  const SubmitRestaurant(this.request);

  @override
  List<Object?> get props => [request];
}
