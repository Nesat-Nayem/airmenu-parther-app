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

class SubmitRestaurantWithImage extends CreateRestaurantEvent {
  final String name;
  final String cuisine;
  final String description;
  final String location;
  final String? googlePlaceId;
  final String price;
  final double? rating;
  final String? offer;
  final num? cgstRate;
  final num? sgstRate;
  final num? serviceCharge;
  final List<WeeklyTimingModel> weeklyTimings;
  final String imagePath;

  const SubmitRestaurantWithImage({
    required this.name,
    required this.cuisine,
    required this.description,
    required this.location,
    this.googlePlaceId,
    required this.price,
    this.rating,
    this.offer,
    this.cgstRate,
    this.sgstRate,
    this.serviceCharge,
    required this.weeklyTimings,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [
        name,
        cuisine,
        description,
        location,
        googlePlaceId,
        price,
        rating,
        offer,
        cgstRate,
        sgstRate,
        serviceCharge,
        weeklyTimings,
        imagePath,
      ];
}
