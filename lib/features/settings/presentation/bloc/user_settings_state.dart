import 'package:equatable/equatable.dart';

enum UserSettingsStatus { initial, loading, success, failure }

class UserSettingsState extends Equatable {
  final UserSettingsStatus status;
  final int currentTabIndex; // 0: Users, 1: Roles, 2: Feature Flags
  final List<dynamic> users; // Replace with actual models
  final List<dynamic> roles; // Replace with actual models
  final List<dynamic> featureFlags; // Replace with actual models
  final Map<String, dynamic> stats; // Top row stats
  final String? errorMessage;

  const UserSettingsState({
    this.status = UserSettingsStatus.initial,
    this.currentTabIndex = 0,
    this.users = const [],
    this.roles = const [],
    this.featureFlags = const [],
    this.stats = const {},
    this.errorMessage,
  });

  UserSettingsState copyWith({
    UserSettingsStatus? status,
    int? currentTabIndex,
    List<dynamic>? users,
    List<dynamic>? roles,
    List<dynamic>? featureFlags,
    Map<String, dynamic>? stats,
    String? errorMessage,
  }) {
    return UserSettingsState(
      status: status ?? this.status,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      users: users ?? this.users,
      roles: roles ?? this.roles,
      featureFlags: featureFlags ?? this.featureFlags,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentTabIndex,
    users,
    roles,
    featureFlags,
    stats,
    errorMessage,
  ];
}
