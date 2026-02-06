import '../models/delivery_partner_models.dart';

abstract class DeliveryPartnerRepository {
  Future<List<DeliveryPartner>> getPartners();
  Future<DeliveryPartnerStats> getStats();
  Future<void> addPartner(DeliveryPartner partner);
  Future<void> updatePartner(DeliveryPartner partner);
  Future<void> deletePartner(String partnerId);
  Future<void> togglePartnerStatus(String partnerId, bool isActive);
}
