import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_state.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/offers_table.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_card.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Offers & Combos page for Vendor - matching the mockup design
class ExclusiveOffersPage extends StatelessWidget {
  const ExclusiveOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MarketingBloc(locator<IMarketingRepository>())
            ..add(const LoadMarketingData()),
      child: const _OffersPageView(),
    );
  }
}

class _OffersPageView extends StatefulWidget {
  const _OffersPageView();

  @override
  State<_OffersPageView> createState() => _OffersPageViewState();
}

class _OffersPageViewState extends State<_OffersPageView> {
  bool _isOffersTab = true; // true = Offers, false = Combos
  final TextEditingController _searchController = TextEditingController();

  // Mock combos data matching the mockup
  final List<ComboModel> _mockCombos = [
    ComboModel(
      id: '1',
      title: 'Family Feast',
      description: 'Perfect for family dinners',
      items: [
        ComboItemModel(name: 'Biryani', quantity: 2, originalPrice: 300),
        ComboItemModel(name: 'Curry', quantity: 2, originalPrice: 200),
        ComboItemModel(name: 'Roti', quantity: 4, originalPrice: 30),
        ComboItemModel(name: 'Raita', quantity: 1, originalPrice: 50),
      ],
      comboPrice: 899,
      originalPrice: 1150,
      savings: 251,
      orderCount: 156,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '2',
      title: 'Couple Combo',
      description: 'Romantic dinner for two',
      items: [
        ComboItemModel(name: 'Biryani', quantity: 1, originalPrice: 300),
        ComboItemModel(name: 'Curry', quantity: 1, originalPrice: 200),
        ComboItemModel(name: 'Roti', quantity: 2, originalPrice: 30),
        ComboItemModel(name: 'Drink', quantity: 2, originalPrice: 60),
      ],
      comboPrice: 549,
      originalPrice: 680,
      savings: 131,
      orderCount: 234,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '3',
      title: 'Solo Lunch',
      description: 'Quick and tasty lunch',
      items: [
        ComboItemModel(name: 'Mini Biryani', quantity: 1, originalPrice: 180),
        ComboItemModel(name: 'Salad', quantity: 1, originalPrice: 50),
        ComboItemModel(name: 'Drink', quantity: 1, originalPrice: 30),
      ],
      comboPrice: 199,
      originalPrice: 260,
      savings: 61,
      orderCount: 456,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '4',
      title: 'Weekend Special',
      description: 'Special treat for weekends',
      items: [
        ComboItemModel(name: 'Starter', quantity: 2, originalPrice: 250),
        ComboItemModel(name: 'Main Course', quantity: 2, originalPrice: 350),
        ComboItemModel(name: 'Dessert', quantity: 2, originalPrice: 200),
      ],
      comboPrice: 1299,
      originalPrice: 1600,
      savings: 301,
      orderCount: 89,
      isActive: false,
      validDays: const ['saturday', 'sunday'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketingBloc, MarketingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<MarketingBloc>().add(const RefreshMarketingData());
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatCards(context, state),
                      const SizedBox(height: 24),
                      _buildTabBar(context),
                      const SizedBox(height: 24),
                      _buildContent(context, state),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Offers & Combos',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Manage discounts and meal deals',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, MarketingState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - 48) / 4
            : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              width: cardWidth,
              icon: Icons.local_offer_outlined,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '4',
              label: 'Active Offers',
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.card_giftcard_rounded,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '3',
              label: 'Active Combos',
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.check_circle_outline,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '1124',
              label: 'Total Redemptions',
              trend: '+18%',
              trendPositive: true,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.trending_up_rounded,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '+₹24.5K',
              label: 'Revenue Impact',
              trend: '+12%',
              trendPositive: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab buttons
          _buildTabButton('Offers', _isOffersTab, () {
            setState(() => _isOffersTab = true);
          }),
          const SizedBox(width: 8),
          _buildTabButton('Combos', !_isOffersTab, () {
            setState(() => _isOffersTab = false);
          }),
          const SizedBox(width: 16),
          // Search
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _isOffersTab
                      ? 'Search offers...'
                      : 'Search combos...',
                  hintStyle: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: AirMenuTextStyle.small,
              ),
            ),
          ),
          const Spacer(),
          // Create button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Create ${_isOffersTab ? 'Offer' : 'Combo'} coming soon',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(_isOffersTab ? 'Create Offer' : 'Create Combo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC52031),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC52031) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketingState state) {
    if (_isOffersTab) {
      return _buildOffersContent(context, state);
    } else {
      return _buildCombosContent();
    }
  }

  Widget _buildOffersContent(BuildContext context, MarketingState state) {
    if (state.promoCodesStatus == MarketingLoadStatus.loading ||
        state.promoCodesStatus == MarketingLoadStatus.initial) {
      return const OffersTableSkeleton();
    }

    if (state.promoCodesStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load offers',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    return OffersTable(
      offers: state.filteredPromoCodes,
      actionInProgressId: state.actionInProgressId,
      onEditTap: (offer) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Edit ${offer.code}')));
      },
      onDeleteTap: (offer) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete ${offer.code}')));
      },
      onStatusToggle: (offer) {
        context.read<MarketingBloc>().add(
          TogglePromoCodeStatus(promoId: offer.id, currentStatus: offer.status),
        );
      },
    );
  }

  Widget _buildCombosContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _mockCombos.map((combo) {
            return SizedBox(
              width: itemWidth,
              height: 260,
              child: ComboCard(
                combo: combo,
                onToggle: () {
                  setState(() {
                    final index = _mockCombos.indexWhere(
                      (c) => c.id == combo.id,
                    );
                    if (index != -1) {
                      _mockCombos[index] = combo.copyWith(
                        isActive: !combo.isActive,
                      );
                    }
                  });
                },
                onEdit: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Edit ${combo.name}')));
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: const Color(0xFFDC2626).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget matching the mockup
class _StatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final String? trend;
  final bool trendPositive;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    this.trend,
    this.trendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (trend != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trendPositive
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: trendPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
