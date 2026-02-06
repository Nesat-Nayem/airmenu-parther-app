import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/external_integration_models.dart';
import 'package:flutter/material.dart';

// Events
abstract class ExternalIntegrationsEvent extends Equatable {
  const ExternalIntegrationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadExternalIntegrations extends ExternalIntegrationsEvent {}

class SelectIntegrationPartner extends ExternalIntegrationsEvent {
  final IntegrationPartner partner;
  const SelectIntegrationPartner(this.partner);
  @override
  List<Object?> get props => [partner];
}

class CloseIntegrationDetails extends ExternalIntegrationsEvent {}

class FilterIntegrations extends ExternalIntegrationsEvent {
  final String filterType; // 'All', 'Third Party', 'Internal'
  const FilterIntegrations(this.filterType);
  @override
  List<Object?> get props => [filterType];
}

// State
enum ExternalIntegrationsStatus { initial, loading, success, failure }

class ExternalIntegrationsState extends Equatable {
  final ExternalIntegrationsStatus status;
  final List<IntegrationStat> stats;
  final List<IntegrationPartner> partners;
  final List<IntegrationPartner> filteredPartners;
  final IntegrationPartner? selectedPartner;
  final String currentFilter;
  final String? errorMessage;

  const ExternalIntegrationsState({
    this.status = ExternalIntegrationsStatus.initial,
    this.stats = const [],
    this.partners = const [],
    this.filteredPartners = const [],
    this.selectedPartner,
    this.currentFilter = 'All',
    this.errorMessage,
  });

  ExternalIntegrationsState copyWith({
    ExternalIntegrationsStatus? status,
    List<IntegrationStat>? stats,
    List<IntegrationPartner>? partners,
    List<IntegrationPartner>? filteredPartners,
    IntegrationPartner? selectedPartner,
    String? currentFilter,
    String? errorMessage,
    bool clearSelection = false,
  }) {
    return ExternalIntegrationsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      partners: partners ?? this.partners,
      filteredPartners: filteredPartners ?? this.filteredPartners,
      selectedPartner: clearSelection
          ? null
          : (selectedPartner ?? this.selectedPartner),
      currentFilter: currentFilter ?? this.currentFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    partners,
    filteredPartners,
    selectedPartner,
    currentFilter,
    errorMessage,
  ];
}

// Bloc
class ExternalIntegrationsBloc
    extends Bloc<ExternalIntegrationsEvent, ExternalIntegrationsState> {
  ExternalIntegrationsBloc() : super(const ExternalIntegrationsState()) {
    on<LoadExternalIntegrations>(_onLoad);
    on<SelectIntegrationPartner>(_onSelect);
    on<CloseIntegrationDetails>(_onCloseDetails);
    on<FilterIntegrations>(_onFilter);
  }

  Future<void> _onLoad(
    LoadExternalIntegrations event,
    Emitter<ExternalIntegrationsState> emit,
  ) async {
    emit(state.copyWith(status: ExternalIntegrationsStatus.loading));
    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    try {
      final stats = [
        IntegrationStat(
          label: 'Active Partners',
          value: '4',
          subtext: 'Connected integrations',
          comparisonText: 'vs yesterday',
          trend: 1.0,
          icon: Icons.local_shipping_outlined,
          iconColor: Color(0xFFDC2626),
          iconBgColor: Color(0xFFFEE2E2),
        ),
        IntegrationStat(
          label: 'Restaurants Using Delivery',
          value: '1,769',
          subtext: 'Across all partners',
          comparisonText: 'vs yesterday',
          trend: 12.0,
          icon: Icons.storefront_outlined,
          iconColor: Color(0xFFDC2626),
          iconBgColor: Color(0xFFFEE2E2),
        ),
        IntegrationStat(
          label: 'Avg Delivery SLA',
          value: '89.5%',
          subtext: 'This week',
          comparisonText: 'vs yesterday',
          trend: 2.3,
          icon: Icons.timelapse_outlined,
          iconColor: Color(0xFFDC2626),
          iconBgColor: Color(0xFFFEE2E2),
        ),
        IntegrationStat(
          label: 'Failed Deliveries Today',
          value: '23',
          subtext: '5 require action',
          comparisonText: 'vs yesterday',
          trend: -15.0,
          icon: Icons.warning_amber_rounded,
          iconColor: Color(0xFFDC2626),
          iconBgColor: Color(0xFFFEE2E2),
        ),
        IntegrationStat(
          label: 'API Uptime',
          value: '99.8%',
          subtext: 'Last 30 days',
          comparisonText: '',
          trend: 0.0,
          icon: Icons.analytics_outlined,
          iconColor: Color(0xFFDC2626),
          iconBgColor: Color(0xFFFEE2E2),
        ),
      ];

      final partners = [
        IntegrationPartner(
          id: '1',
          name: 'Shadowfax',
          type: 'Third Party',
          restaurantsLinked: '845 restaurants',
          sla: 94,
          avgTime: '28 min',
          successRate: 96.5,
          failureRate: 3.5,
          costPerKm: 8.5,
          status: 'active',
          lastSync: '2 min ago',
        ),
        IntegrationPartner(
          id: '2',
          name: 'Rapido',
          type: 'Third Party',
          restaurantsLinked: '567 restaurants',
          sla: 89,
          avgTime: '32 min',
          successRate: 92.8,
          failureRate: 7.2,
          costPerKm: 6.5,
          status: 'active',
          lastSync: '1 min ago',
        ),
        IntegrationPartner(
          id: '3',
          name: 'Internal Fleet',
          type: 'Internal',
          restaurantsLinked: '234 restaurants',
          sla: 97,
          avgTime: '24 min',
          successRate: 98.2,
          failureRate: 1.8,
          costPerKm: 5.0,
          status: 'active',
          lastSync: 'Just now',
        ),
        IntegrationPartner(
          id: '4',
          name: 'Dunzo',
          type: 'Third Party',
          restaurantsLinked: '123 restaurants',
          sla: 78,
          avgTime: '42 min',
          successRate: 84.5,
          failureRate: 15.5,
          costPerKm: 10.5,
          status: 'degraded',
          lastSync: '5 min ago',
        ),
      ];

      emit(
        state.copyWith(
          status: ExternalIntegrationsStatus.success,
          stats: stats,
          partners: partners,
          filteredPartners: partners,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExternalIntegrationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelect(
    SelectIntegrationPartner event,
    Emitter<ExternalIntegrationsState> emit,
  ) {
    emit(state.copyWith(selectedPartner: event.partner));
  }

  void _onCloseDetails(
    CloseIntegrationDetails event,
    Emitter<ExternalIntegrationsState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }

  void _onFilter(
    FilterIntegrations event,
    Emitter<ExternalIntegrationsState> emit,
  ) {
    if (event.filterType == 'All') {
      emit(
        state.copyWith(
          currentFilter: event.filterType,
          filteredPartners: state.partners,
        ),
      );
    } else {
      final filtered = state.partners
          .where((p) => p.type == event.filterType)
          .toList();
      emit(
        state.copyWith(
          currentFilter: event.filterType,
          filteredPartners: filtered,
        ),
      );
    }
  }
}
