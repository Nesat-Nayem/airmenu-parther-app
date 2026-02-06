import 'package:equatable/equatable.dart';
import '../../data/models/delivery_partner_models.dart';

abstract class DeliveryPartnerEvent extends Equatable {
  const DeliveryPartnerEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryPartners extends DeliveryPartnerEvent {
  const LoadDeliveryPartners();
}

class RefreshDeliveryPartners extends DeliveryPartnerEvent {
  const RefreshDeliveryPartners();
}

class FilterPartnersByStatus extends DeliveryPartnerEvent {
  final String status; // 'all', 'active', 'inactive', 'pending'

  const FilterPartnersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchPartners extends DeliveryPartnerEvent {
  final String query;

  const SearchPartners(this.query);

  @override
  List<Object?> get props => [query];
}

class AddDeliveryPartner extends DeliveryPartnerEvent {
  final DeliveryPartner partner;

  const AddDeliveryPartner(this.partner);

  @override
  List<Object?> get props => [partner];
}

class UpdateDeliveryPartner extends DeliveryPartnerEvent {
  final DeliveryPartner partner;

  const UpdateDeliveryPartner(this.partner);

  @override
  List<Object?> get props => [partner];
}

class TogglePartnerStatus extends DeliveryPartnerEvent {
  final String partnerId;
  final bool isActive;

  const TogglePartnerStatus(this.partnerId, this.isActive);

  @override
  List<Object?> get props => [partnerId, isActive];
}

class DeleteDeliveryPartner extends DeliveryPartnerEvent {
  final String partnerId;

  const DeleteDeliveryPartner(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}
