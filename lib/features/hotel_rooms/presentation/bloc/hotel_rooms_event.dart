import 'package:equatable/equatable.dart';

abstract class HotelRoomsEvent extends Equatable {
  const HotelRoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHotelRooms extends HotelRoomsEvent {
  const LoadHotelRooms();
}

class SelectRoom extends HotelRoomsEvent {
  final String? roomId;
  const SelectRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class FilterRooms extends HotelRoomsEvent {
  final String query;
  final int? floor;
  final String? status; // 'all', 'occupied', 'vacant', 'cleaning'

  const FilterRooms({this.query = '', this.floor, this.status});

  @override
  List<Object?> get props => [query, floor, status];
}
