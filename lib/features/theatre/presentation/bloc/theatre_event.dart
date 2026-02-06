import 'package:equatable/equatable.dart';

abstract class TheatreEvent extends Equatable {
  const TheatreEvent();

  @override
  List<Object> get props => [];
}

class LoadTheatreData extends TheatreEvent {}

class FilterTheatres extends TheatreEvent {
  final String? city;
  final String? searchQuery;

  const FilterTheatres({this.city, this.searchQuery});

  @override
  List<Object> get props => [city ?? '', searchQuery ?? ''];
}

class SelectTheatre extends TheatreEvent {
  final String theatreId;

  const SelectTheatre(this.theatreId);

  @override
  List<Object> get props => [theatreId];
}

class CloseTheatreDetail extends TheatreEvent {}
