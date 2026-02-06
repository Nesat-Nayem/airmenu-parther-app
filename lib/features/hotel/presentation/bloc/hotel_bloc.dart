import 'package:airmenuai_partner_app/features/hotel/data/models/hotel_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/hotel_repository.dart';
import 'hotel_event.dart';
import 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository repository;

  HotelBloc({required this.repository}) : super(HotelInitial()) {
    on<LoadHotels>(_onLoadHotels);
    on<FilterHotels>(_onFilterHotels);
    on<SelectHotel>(_onSelectHotel);
    on<CloseHotelDetail>(_onCloseHotelDetail);
  }

  Future<void> _onLoadHotels(LoadHotels event, Emitter<HotelState> emit) async {
    emit(HotelLoading());
    try {
      final stats = await repository.getStats();
      final hotels = await repository.getHotels();
      emit(HotelLoaded(stats: stats, hotels: hotels, filteredHotels: hotels));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  void _onFilterHotels(FilterHotels event, Emitter<HotelState> emit) {
    if (state is HotelLoaded) {
      final currentState = state as HotelLoaded;
      List<Hotel> filtered = currentState.hotels;

      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        filtered = filtered
            .where(
              (hotel) =>
                  hotel.name.toLowerCase().contains(
                    event.searchQuery!.toLowerCase(),
                  ) ||
                  hotel.address.toLowerCase().contains(
                    event.searchQuery!.toLowerCase(),
                  ),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredHotels: filtered,
          searchQuery: event.searchQuery,
        ),
      );
    }
  }

  Future<void> _onSelectHotel(
    SelectHotel event,
    Emitter<HotelState> emit,
  ) async {
    if (state is HotelLoaded) {
      final currentState = state as HotelLoaded;
      emit(
        currentState.copyWith(selectedHotelId: event.id, isDetailLoading: true),
      );

      try {
        final detail = await repository.getHotelDetail(event.id);
        // If the user hasn't deselected in the meantime
        if (state is HotelLoaded &&
            (state as HotelLoaded).selectedHotelId == event.id) {
          emit(
            (state as HotelLoaded).copyWith(
              hotelDetail: detail,
              isDetailLoading: false,
            ),
          );
        }
      } catch (e) {
        // Handle error, maybe revert selection or show snackbar
        // For now just stop loading
        if (state is HotelLoaded) {
          emit((state as HotelLoaded).copyWith(isDetailLoading: false));
        }
      }
    }
  }

  void _onCloseHotelDetail(CloseHotelDetail event, Emitter<HotelState> emit) {
    if (state is HotelLoaded) {
      emit((state as HotelLoaded).copyWith(clearDetail: true));
    }
  }
}
