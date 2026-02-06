import 'package:equatable/equatable.dart';
import '../../data/models/hotel_models.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final List<HotelStat> stats;
  final List<Hotel> hotels;
  final List<Hotel> filteredHotels;
  final String? selectedHotelId;
  final HotelDetail? hotelDetail;
  final bool isDetailLoading;
  final String? searchQuery;

  const HotelLoaded({
    required this.stats,
    required this.hotels,
    required this.filteredHotels,
    this.selectedHotelId,
    this.hotelDetail,
    this.isDetailLoading = false,
    this.searchQuery,
  });

  HotelLoaded copyWith({
    List<HotelStat>? stats,
    List<Hotel>? hotels,
    List<Hotel>? filteredHotels,
    String? selectedHotelId,
    HotelDetail? hotelDetail,
    bool? isDetailLoading,
    String? searchQuery,
    bool clearDetail = false,
  }) {
    return HotelLoaded(
      stats: stats ?? this.stats,
      hotels: hotels ?? this.hotels,
      filteredHotels: filteredHotels ?? this.filteredHotels,
      selectedHotelId: clearDetail
          ? null
          : (selectedHotelId ?? this.selectedHotelId),
      hotelDetail: clearDetail ? null : (hotelDetail ?? this.hotelDetail),
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    hotels,
    filteredHotels,
    selectedHotelId,
    hotelDetail,
    isDetailLoading,
    searchQuery,
  ];
}

class HotelError extends HotelState {
  final String message;
  const HotelError(this.message);

  @override
  List<Object> get props => [message];
}
