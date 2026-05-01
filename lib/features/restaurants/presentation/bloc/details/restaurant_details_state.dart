import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/restaurant_creation_models.dart';


abstract class RestaurantDetailsState extends Equatable {
  const RestaurantDetailsState();

  @override
  List<Object?> get props => [];
}

class RestaurantDetailsInitial extends RestaurantDetailsState {}

class RestaurantDetailsLoading extends RestaurantDetailsState {}

class RestaurantDetailsLoaded extends RestaurantDetailsState {
  final RestaurantModel restaurant;
  final int selectedTabIndex;

  // Mock Data
  final Map<String, dynamic> overviewStats;
  final List<Map<String, dynamic>> menuIssues;
  final List<Map<String, dynamic>> tables;
  final Map<String, dynamic> inventoryHealth;
  final List<BranchModel> branches;
  final bool isBranchesLoading;
  final String? branchError;
  final Map<String, dynamic> billingInfo;
  final List<Map<String, dynamic>> staffList;
  final Map<String, dynamic> integrationsData;
  final Map<String, dynamic> onboardingData;
  final List<BuffetModel> buffets;
  final bool isBuffetsLoading;

  const RestaurantDetailsLoaded({
    required this.restaurant,
    this.selectedTabIndex = 0,
    required this.overviewStats,
    required this.menuIssues,
    required this.tables,
    required this.inventoryHealth,
    required this.branches,
    this.isBranchesLoading = false,
    this.branchError,
    required this.billingInfo,
    required this.staffList,
    required this.integrationsData,
    required this.onboardingData,
    this.buffets = const [],
    this.isBuffetsLoading = false,
  });

  RestaurantDetailsLoaded copyWith({
    RestaurantModel? restaurant,
    int? selectedTabIndex,
    Map<String, dynamic>? overviewStats,
    List<Map<String, dynamic>>? menuIssues,
    List<Map<String, dynamic>>? tables,
    Map<String, dynamic>? inventoryHealth,
    List<BranchModel>? branches,
    bool? isBranchesLoading,
    String? branchError,
    bool clearBranchError = false,
    Map<String, dynamic>? billingInfo,
    List<Map<String, dynamic>>? staffList,
    Map<String, dynamic>? integrationsData,
    Map<String, dynamic>? onboardingData,
    List<BuffetModel>? buffets,
    bool? isBuffetsLoading,
  }) {
    return RestaurantDetailsLoaded(
      restaurant: restaurant ?? this.restaurant,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      overviewStats: overviewStats ?? this.overviewStats,
      menuIssues: menuIssues ?? this.menuIssues,
      tables: tables ?? this.tables,
      inventoryHealth: inventoryHealth ?? this.inventoryHealth,
      branches: branches ?? this.branches,
      isBranchesLoading: isBranchesLoading ?? this.isBranchesLoading,
      branchError: clearBranchError ? null : (branchError ?? this.branchError),
      billingInfo: billingInfo ?? this.billingInfo,
      staffList: staffList ?? this.staffList,
      integrationsData: integrationsData ?? this.integrationsData,
      onboardingData: onboardingData ?? this.onboardingData,
      buffets: buffets ?? this.buffets,
      isBuffetsLoading: isBuffetsLoading ?? this.isBuffetsLoading,
    );
  }

  @override
  List<Object?> get props => [
    restaurant,
    selectedTabIndex,
    overviewStats,
    menuIssues,
    tables,
    inventoryHealth,
    branches,
    isBranchesLoading,
    branchError,
    billingInfo,
    staffList,
    integrationsData,
    onboardingData,
    buffets,
    isBuffetsLoading,
  ];
}

class RestaurantDetailsError extends RestaurantDetailsState {
  final String message;

  const RestaurantDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
