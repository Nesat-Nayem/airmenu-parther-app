import 'package:equatable/equatable.dart';

abstract class RestaurantFormState extends Equatable {
  const RestaurantFormState();

  @override
  List<Object?> get props => [];
}

class RestaurantFormInitial extends RestaurantFormState {}

class RestaurantFormLoading extends RestaurantFormState {}

class RestaurantFormSuccess extends RestaurantFormState {
  final String message;

  const RestaurantFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RestaurantFormFailure extends RestaurantFormState {
  final String error;

  const RestaurantFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}
