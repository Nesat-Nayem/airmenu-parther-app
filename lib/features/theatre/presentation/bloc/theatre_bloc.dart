import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/theatre_repository.dart';
import 'theatre_event.dart';
import 'theatre_state.dart';

class TheatreBloc extends Bloc<TheatreEvent, TheatreState> {
  final TheatreRepository repository;

  TheatreBloc({required this.repository}) : super(TheatreInitial()) {
    on<LoadTheatreData>(_onLoadTheatreData);
    on<FilterTheatres>(_onFilterTheatres);
    on<SelectTheatre>(_onSelectTheatre);
    on<CloseTheatreDetail>(_onCloseTheatreDetail);
  }

  Future<void> _onLoadTheatreData(
    LoadTheatreData event,
    Emitter<TheatreState> emit,
  ) async {
    emit(TheatreLoading());
    try {
      final stats = await repository.getStats();
      final theatres = await repository.getTheatres();

      if (theatres.isEmpty) {
        emit(TheatreEmpty());
      } else {
        emit(
          TheatreLoaded(
            stats: stats,
            theatres: theatres,
            filteredTheatres: theatres,
          ),
        );
      }
    } catch (e) {
      emit(TheatreError(e.toString()));
    }
  }

  void _onFilterTheatres(FilterTheatres event, Emitter<TheatreState> emit) {
    if (state is TheatreLoaded) {
      final currentState = state as TheatreLoaded;

      var filtered = currentState.theatres;

      // Filter by City
      if (event.city != null && event.city != 'All Cities') {
        filtered = filtered.where((t) => t.city == event.city).toList();
      }

      // Filter by Search Query
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final query = event.searchQuery!.toLowerCase();
        filtered = filtered
            .where(
              (t) =>
                  t.name.toLowerCase().contains(query) ||
                  t.restaurant.toLowerCase().contains(query),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredTheatres: filtered,
          selectedCity: event.city,
        ),
      );
    }
  }

  Future<void> _onSelectTheatre(
    SelectTheatre event,
    Emitter<TheatreState> emit,
  ) async {
    if (state is TheatreLoaded) {
      final currentState = state as TheatreLoaded;
      emit(
        currentState.copyWith(
          selectedTheatreId: event.theatreId,
          isDetailLoading: true,
        ),
      );

      try {
        final detail = await repository.getTheatreDetail(event.theatreId);
        emit(
          currentState.copyWith(
            selectedTheatreId: event.theatreId,
            isDetailLoading: false,
            theatreDetail: detail,
          ),
        );
      } catch (e) {
        // Handle error specifically for detail if needed, or just stop loading
        emit(currentState.copyWith(isDetailLoading: false));
      }
    }
  }

  void _onCloseTheatreDetail(
    CloseTheatreDetail event,
    Emitter<TheatreState> emit,
  ) {
    if (state is TheatreLoaded) {
      final currentState = state as TheatreLoaded;
      emit(currentState.copyWith(clearDetail: true));
    }
  }
}
