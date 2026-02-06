import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LocationsState extends Equatable {
  const LocationsState();
  @override
  List<Object?> get props => [];
}

class LocationsInitial extends LocationsState {
  final int selectedTabIndex;

  const LocationsInitial({this.selectedTabIndex = 0});

  LocationsInitial copyWith({int? selectedTabIndex}) {
    return LocationsInitial(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [selectedTabIndex];
}

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit() : super(const LocationsInitial());

  void selectTab(int index) {
    if (state is LocationsInitial) {
      emit((state as LocationsInitial).copyWith(selectedTabIndex: index));
    }
  }
}
