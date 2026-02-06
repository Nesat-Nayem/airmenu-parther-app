import 'package:equatable/equatable.dart';
import '../../data/models/theatre_models.dart';

abstract class TheatreState extends Equatable {
  const TheatreState();

  @override
  List<Object?> get props => [];
}

class TheatreInitial extends TheatreState {}

class TheatreLoading extends TheatreState {}

class TheatreLoaded extends TheatreState {
  final List<TheatreStat> stats;
  final List<Theatre> theatres;
  final List<Theatre> filteredTheatres;
  final String? selectedCity;
  // Detail View State
  final String? selectedTheatreId;
  final bool isDetailLoading;
  final TheatreDetail? theatreDetail;

  const TheatreLoaded({
    required this.stats,
    required this.theatres,
    required this.filteredTheatres,
    this.selectedCity,
    this.selectedTheatreId,
    this.isDetailLoading = false,
    this.theatreDetail,
  });

  @override
  List<Object?> get props => [
    stats,
    theatres,
    filteredTheatres,
    selectedCity,
    selectedTheatreId,
    isDetailLoading,
    theatreDetail,
  ];

  TheatreLoaded copyWith({
    List<TheatreStat>? stats,
    List<Theatre>? theatres,
    List<Theatre>? filteredTheatres,
    String? selectedCity,
    String? selectedTheatreId,
    bool? isDetailLoading,
    TheatreDetail? theatreDetail,
    bool clearDetail = false,
  }) {
    return TheatreLoaded(
      stats: stats ?? this.stats,
      theatres: theatres ?? this.theatres,
      filteredTheatres: filteredTheatres ?? this.filteredTheatres,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedTheatreId: clearDetail
          ? null
          : (selectedTheatreId ?? this.selectedTheatreId),
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      theatreDetail: clearDetail ? null : (theatreDetail ?? this.theatreDetail),
    );
  }
}

class TheatreError extends TheatreState {
  final String message;

  const TheatreError(this.message);

  @override
  List<Object> get props => [message];
}

class TheatreEmpty extends TheatreState {}
