import 'package:equatable/equatable.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserSettings extends UserSettingsEvent {
  const LoadUserSettings();
}

class ChangeSettingsTab extends UserSettingsEvent {
  final int tabIndex;

  const ChangeSettingsTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class FilterUsers extends UserSettingsEvent {
  final String query;

  const FilterUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFeatureFlag extends UserSettingsEvent {
  final String featureId;
  final bool isEnabled;

  const ToggleFeatureFlag({required this.featureId, required this.isEnabled});

  @override
  List<Object?> get props => [featureId, isEnabled];
}
