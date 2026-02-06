import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Very simple state for the dialog interactions
abstract class PriceComparisonState extends Equatable {
  const PriceComparisonState();
  @override
  List<Object?> get props => [];
}

class PriceComparisonInitial extends PriceComparisonState {
  final String selectedItemId;
  // In a real app, we'd have a list of items loaded here.
  // For UI demo, we'll assume static list but track selection.

  const PriceComparisonInitial({this.selectedItemId = 'paneer'});

  @override
  List<Object?> get props => [selectedItemId];
}

class PriceComparisonCubit extends Cubit<PriceComparisonState> {
  PriceComparisonCubit() : super(const PriceComparisonInitial());

  void selectItem(String itemId) {
    emit(PriceComparisonInitial(selectedItemId: itemId));
  }
}
