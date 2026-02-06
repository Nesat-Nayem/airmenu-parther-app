import 'package:equatable/equatable.dart';
import '../../data/models/delivery_partner_models.dart';

abstract class DeliveryPartnerState extends Equatable {
  const DeliveryPartnerState();

  @override
  List<Object?> get props => [];
}

class DeliveryPartnerInitial extends DeliveryPartnerState {
  const DeliveryPartnerInitial();
}

class DeliveryPartnerLoading extends DeliveryPartnerState {
  const DeliveryPartnerLoading();
}

class DeliveryPartnerSuccess extends DeliveryPartnerState {
  final List<DeliveryPartner> partners;
  final List<DeliveryPartner> filteredPartners;
  final DeliveryPartnerStats stats;
  final String currentFilter;
  final String searchQuery;

  const DeliveryPartnerSuccess({
    required this.partners,
    required this.filteredPartners,
    required this.stats,
    this.currentFilter = 'all',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    partners,
    filteredPartners,
    stats,
    currentFilter,
    searchQuery,
  ];

  DeliveryPartnerSuccess copyWith({
    List<DeliveryPartner>? partners,
    List<DeliveryPartner>? filteredPartners,
    DeliveryPartnerStats? stats,
    String? currentFilter,
    String? searchQuery,
  }) {
    return DeliveryPartnerSuccess(
      partners: partners ?? this.partners,
      filteredPartners: filteredPartners ?? this.filteredPartners,
      stats: stats ?? this.stats,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DeliveryPartnerEmpty extends DeliveryPartnerState {
  final String message;

  const DeliveryPartnerEmpty({this.message = 'No delivery partners found'});

  @override
  List<Object?> get props => [message];
}

class DeliveryPartnerError extends DeliveryPartnerState {
  final String message;

  const DeliveryPartnerError(this.message);

  @override
  List<Object?> get props => [message];
}
