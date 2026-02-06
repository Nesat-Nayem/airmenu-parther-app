import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/delivery_partner_models.dart';
import '../../data/repositories/delivery_partner_repository.dart';
import 'delivery_partner_event.dart';
import 'delivery_partner_state.dart';

class DeliveryPartnerBloc
    extends Bloc<DeliveryPartnerEvent, DeliveryPartnerState> {
  final DeliveryPartnerRepository repository;

  DeliveryPartnerBloc({required this.repository})
    : super(const DeliveryPartnerInitial()) {
    on<LoadDeliveryPartners>(_onLoadDeliveryPartners);
    on<RefreshDeliveryPartners>(_onRefreshDeliveryPartners);
    on<FilterPartnersByStatus>(_onFilterPartnersByStatus);
    on<SearchPartners>(_onSearchPartners);
    on<AddDeliveryPartner>(_onAddDeliveryPartner);
    on<UpdateDeliveryPartner>(_onUpdateDeliveryPartner);
    on<TogglePartnerStatus>(_onTogglePartnerStatus);
    on<DeleteDeliveryPartner>(_onDeleteDeliveryPartner);
  }

  Future<void> _onLoadDeliveryPartners(
    LoadDeliveryPartners event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    emit(const DeliveryPartnerLoading());
    try {
      final partners = await repository.getPartners();
      final stats = await repository.getStats();

      if (partners.isEmpty) {
        emit(const DeliveryPartnerEmpty());
      } else {
        emit(
          DeliveryPartnerSuccess(
            partners: partners,
            filteredPartners: partners,
            stats: stats,
          ),
        );
      }
    } catch (e) {
      emit(
        DeliveryPartnerError(
          'Failed to load delivery partners: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshDeliveryPartners(
    RefreshDeliveryPartners event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    try {
      final partners = await repository.getPartners();
      final stats = await repository.getStats();

      if (partners.isEmpty) {
        emit(const DeliveryPartnerEmpty());
      } else {
        emit(
          DeliveryPartnerSuccess(
            partners: partners,
            filteredPartners: partners,
            stats: stats,
          ),
        );
      }
    } catch (e) {
      emit(
        DeliveryPartnerError(
          'Failed to refresh delivery partners: ${e.toString()}',
        ),
      );
    }
  }

  void _onFilterPartnersByStatus(
    FilterPartnersByStatus event,
    Emitter<DeliveryPartnerState> emit,
  ) {
    if (state is DeliveryPartnerSuccess) {
      final currentState = state as DeliveryPartnerSuccess;
      List<DeliveryPartner> filtered;

      if (event.status.toLowerCase() == 'all' ||
          event.status.toLowerCase() == 'all status') {
        filtered = currentState.partners;
      } else {
        filtered = currentState.partners
            .where(
              (partner) =>
                  partner.status.toLowerCase() == event.status.toLowerCase(),
            )
            .toList();
      }

      // Apply search query if exists
      if (currentState.searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (partner) => partner.name.toLowerCase().contains(
                currentState.searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }

      if (filtered.isEmpty) {
        emit(
          DeliveryPartnerEmpty(
            message: 'No partners found with status: ${event.status}',
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            filteredPartners: filtered,
            currentFilter: event.status,
          ),
        );
      }
    }
  }

  void _onSearchPartners(
    SearchPartners event,
    Emitter<DeliveryPartnerState> emit,
  ) {
    if (state is DeliveryPartnerSuccess) {
      final currentState = state as DeliveryPartnerSuccess;
      List<DeliveryPartner> filtered = currentState.partners;

      // Apply filter
      if (currentState.currentFilter.toLowerCase() != 'all' &&
          currentState.currentFilter.toLowerCase() != 'all status') {
        filtered = filtered
            .where(
              (partner) =>
                  partner.status.toLowerCase() ==
                  currentState.currentFilter.toLowerCase(),
            )
            .toList();
      }

      // Apply search
      if (event.query.isNotEmpty) {
        filtered = filtered
            .where(
              (partner) =>
                  partner.name.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ) ||
                  partner.type.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ),
            )
            .toList();
      }

      if (filtered.isEmpty) {
        emit(
          const DeliveryPartnerEmpty(message: 'No partners match your search'),
        );
      } else {
        emit(
          currentState.copyWith(
            filteredPartners: filtered,
            searchQuery: event.query,
          ),
        );
      }
    }
  }

  Future<void> _onAddDeliveryPartner(
    AddDeliveryPartner event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    try {
      await repository.addPartner(event.partner);
      add(const RefreshDeliveryPartners());
    } catch (e) {
      emit(DeliveryPartnerError('Failed to add partner: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDeliveryPartner(
    UpdateDeliveryPartner event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    try {
      await repository.updatePartner(event.partner);
      add(const RefreshDeliveryPartners());
    } catch (e) {
      emit(DeliveryPartnerError('Failed to update partner: ${e.toString()}'));
    }
  }

  Future<void> _onTogglePartnerStatus(
    TogglePartnerStatus event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    if (state is DeliveryPartnerSuccess) {
      try {
        await repository.togglePartnerStatus(event.partnerId, event.isActive);
        add(const RefreshDeliveryPartners());
      } catch (e) {
        emit(
          DeliveryPartnerError(
            'Failed to toggle partner status: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onDeleteDeliveryPartner(
    DeleteDeliveryPartner event,
    Emitter<DeliveryPartnerState> emit,
  ) async {
    try {
      await repository.deletePartner(event.partnerId);
      add(const RefreshDeliveryPartners());
    } catch (e) {
      emit(DeliveryPartnerError('Failed to delete partner: ${e.toString()}'));
    }
  }
}
