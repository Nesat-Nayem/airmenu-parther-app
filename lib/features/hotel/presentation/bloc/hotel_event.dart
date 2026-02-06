import 'package:equatable/equatable.dart';

abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object> get props => [];
}

class LoadHotels extends HotelEvent {}

class FilterHotels extends HotelEvent {
  final String? searchQuery;
  // Add other filters if needed, e.g., Filter by City/Status
  const FilterHotels({this.searchQuery});

  @override
  List<Object> get props => [if (searchQuery != null) searchQuery!];
}

class SelectHotel extends HotelEvent {
  final String id;
  const SelectHotel(this.id);

  @override
  List<Object> get props => [id];
}

class CloseHotelDetail extends HotelEvent {}
