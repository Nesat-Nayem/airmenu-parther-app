import '../models/delivery_partner_models.dart';
import '../repositories/delivery_partner_repository.dart';

class DeliveryPartnerDataSource implements DeliveryPartnerRepository {
  // Mock data storage
  final List<DeliveryPartner> _partners = [
    DeliveryPartner(
      id: '1',
      name: 'Shadowfax',
      type: 'Hyperlocal',
      costPerKm: 8.0,
      avgTimeMinutes: 28,
      slaScore: 94.0,
      activeRiders: 245,
      coverage: '12 cities',
      totalDeliveries: 15234,
      status: 'active',
      apiStatus: 'connected',
      webhookUrl: 'https://api.airmenu.com/webhooks/delivery',
      apiKey: 'sk-live-shadowfax-*********************',
      priorityOrder: 1,
      autoAssignOrders: true,
      fallbackPartner: 'Rapido',
    ),
    DeliveryPartner(
      id: '2',
      name: 'Rapido',
      type: 'Bike Delivery',
      costPerKm: 6.0,
      avgTimeMinutes: 22,
      slaScore: 91.0,
      activeRiders: 189,
      coverage: '8 cities',
      totalDeliveries: 12456,
      status: 'active',
      apiStatus: 'connected',
      webhookUrl: 'https://api.airmenu.com/webhooks/delivery',
      apiKey: 'sk-live-rapido-*********************',
      priorityOrder: 2,
      autoAssignOrders: true,
    ),
    DeliveryPartner(
      id: '3',
      name: 'Dunzo',
      type: 'Multi-mode',
      costPerKm: 10.0,
      avgTimeMinutes: 35,
      slaScore: 88.0,
      activeRiders: 156,
      coverage: '5 cities',
      totalDeliveries: 8934,
      status: 'active',
      apiStatus: 'error',
      webhookUrl: 'https://api.airmenu.com/webhooks/delivery',
      apiKey: 'sk-live-dunzo-*********************',
      priorityOrder: 3,
      autoAssignOrders: false,
    ),
    DeliveryPartner(
      id: '4',
      name: 'Porter',
      type: 'Heavy Delivery',
      costPerKm: 15.0,
      avgTimeMinutes: 45,
      slaScore: 92.0,
      activeRiders: 78,
      coverage: '10 cities',
      totalDeliveries: 0,
      status: 'pending',
      apiStatus: 'pending',
      priorityOrder: 4,
      autoAssignOrders: false,
    ),
  ];

  @override
  Future<List<DeliveryPartner>> getPartners() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_partners);
  }

  @override
  Future<DeliveryPartnerStats> getStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final activePartners = _partners
        .where((p) => p.status == 'active')
        .toList();
    final totalActiveRiders = activePartners.fold<int>(
      0,
      (sum, p) => sum + p.activeRiders,
    );
    final avgTime = activePartners.isEmpty
        ? 0
        : activePartners.fold<int>(0, (sum, p) => sum + p.avgTimeMinutes) ~/
              activePartners.length;
    final avgSla = activePartners.isEmpty
        ? 0.0
        : activePartners.fold<double>(0, (sum, p) => sum + p.slaScore) /
              activePartners.length;
    final apiErrors = _partners.where((p) => p.apiStatus == 'error').length;

    return DeliveryPartnerStats(
      totalPartners: _partners.length,
      activeRiders: totalActiveRiders,
      avgDeliveryTimeMinutes: avgTime,
      avgSlaScore: avgSla,
      apiErrors: apiErrors,
      totalPartnersChange: '+12%',
      activeRidersChange: 'vs yesterday',
      avgDeliveryTimeChange: '-3%',
      avgSlaScoreChange: '+2%',
    );
  }

  @override
  Future<void> addPartner(DeliveryPartner partner) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _partners.add(partner);
  }

  @override
  Future<void> updatePartner(DeliveryPartner partner) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _partners.indexWhere((p) => p.id == partner.id);
    if (index != -1) {
      _partners[index] = partner;
    }
  }

  @override
  Future<void> deletePartner(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _partners.removeWhere((p) => p.id == partnerId);
  }

  @override
  Future<void> togglePartnerStatus(String partnerId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _partners.indexWhere((p) => p.id == partnerId);
    if (index != -1) {
      _partners[index] = _partners[index].copyWith(
        status: isActive ? 'active' : 'inactive',
      );
    }
  }
}
