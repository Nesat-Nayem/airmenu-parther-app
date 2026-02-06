import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/price_comparison_cubit.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupplierPriceComparisonDialog extends StatelessWidget {
  const SupplierPriceComparisonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceComparisonCubit(),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 1100,
        height: isMobile ? MediaQuery.of(context).size.height * 0.9 : 750,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            const _Header(),

            // Main Content
            Expanded(
              child: isMobile
                  ? const SingleChildScrollView(
                      child: Column(children: [_ItemsPanel(), _DetailsPanel()]),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel: Items List
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: const _ItemsPanel(),
                          ),
                        ),

                        // Right Panel: Details
                        const Expanded(flex: 6, child: _DetailsPanel()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supplier Price Comparison',
                            style: AirMenuTextStyle.headingH4.withColor(
                              const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compare prices across vendors and find the best deals',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.trending_down,
                              size: 20,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Potential Monthly Savings',
                                  style: AirMenuTextStyle.normal
                                      .bold600()
                                      .withColor(const Color(0xFF065F46)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'By switching to lowest-price vendors',
                                  style: AirMenuTextStyle.small
                                      .medium500()
                                      .withColor(const Color(0xFF047857)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '₹530',
                          style: AirMenuTextStyle.headingH2
                              .black900()
                              .withColor(const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.trending_down,
                              size: 20,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Potential Monthly Savings',
                                style: AirMenuTextStyle.normal
                                    .bold600()
                                    .withColor(const Color(0xFF065F46)),
                              ),
                              Text(
                                'By switching to lowest-price vendors',
                                style: AirMenuTextStyle.small
                                    .medium500()
                                    .withColor(const Color(0xFF047857)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '₹530',
                        style: AirMenuTextStyle.headingH2.black900().withColor(
                          const Color(0xFF059669),
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

class _ItemsPanel extends StatelessWidget {
  const _ItemsPanel();

  @override
  Widget build(BuildContext context) {
    final itemsList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 16),
        _ItemCard(
          id: 'paneer',
          name: 'Paneer',
          category: 'Dairy',
          currentVendor: 'Fresh Dairy Co.',
          price: '320',
          unit: 'kg',
          savings: '25',
          vendorsAvailable: 4,
        ),
        SizedBox(height: 12),
        _ItemCard(
          id: 'chicken',
          name: 'Chicken',
          category: 'Meat',
          currentVendor: 'Farm Fresh Meats',
          price: '280',
          unit: 'kg',
          savings: '15',
          vendorsAvailable: 3,
        ),
        SizedBox(height: 12),
        _ItemCard(
          id: 'oil',
          name: 'Cooking Oil',
          category: 'Oils',
          currentVendor: 'Oil Mills Ltd.',
          price: '150',
          unit: 'L',
          savings: '8',
          vendorsAvailable: 3,
        ),
        SizedBox(height: 12),
        _ItemCard(
          id: 'rice',
          name: 'Basmati Rice',
          category: 'Grains',
          currentVendor: 'Grain Traders',
          price: '120',
          unit: 'kg',
          savings: '5',
          vendorsAvailable: 3,
        ),
      ],
    );

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Responsive.isMobile(context)
              ? Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: AirMenuTextStyle.small
                              .medium500()
                              .withColor(const Color(0xFF9CA3AF)),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'All Categories',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            hintStyle: AirMenuTextStyle.small
                                .medium500()
                                .withColor(const Color(0xFF9CA3AF)),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'All Categories',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),

        // List
        Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: itemsList,
              )
            : Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: itemsList,
                ),
              ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String currentVendor;
  final String price;
  final String unit;
  final String savings;
  final int vendorsAvailable;

  const _ItemCard({
    required this.id,
    required this.name,
    required this.category,
    required this.currentVendor,
    required this.price,
    required this.unit,
    required this.savings,
    required this.vendorsAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PriceComparisonCubit, PriceComparisonState>(
      builder: (context, state) {
        final isSelected =
            (state as PriceComparisonInitial).selectedItemId == id;

        return GestureDetector(
          onTap: () => context.read<PriceComparisonCubit>().selectItem(id),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: AirMenuTextStyle.normal
                                    .bold600()
                                    .withColor(const Color(0xFF111827)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($category)',
                              style: AirMenuTextStyle.caption
                                  .medium500()
                                  .withColor(const Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹$price/$unit',
                        style: AirMenuTextStyle.normal.bold700().withColor(
                          const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildResponsiveDetails(
                          isMobile: Responsive.isMobile(context),
                          currentVendor: currentVendor,
                          vendorsAvailable: vendorsAvailable,
                          savings: savings,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_down,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Save ₹$savings',
                              style: AirMenuTextStyle.tiny.bold600().withColor(
                                const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveDetails({
    required bool isMobile,
    required String currentVendor,
    required int vendorsAvailable,
    required String savings,
  }) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current: $currentVendor',
          style: AirMenuTextStyle.small.medium500().withColor(
            const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$vendorsAvailable vendors available',
          style: AirMenuTextStyle.tiny.medium500().withColor(
            const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_down, size: 14, color: Color(0xFF059669)),
          const SizedBox(width: 4),
          Text(
            'Save ₹$savings',
            style: AirMenuTextStyle.tiny.bold600().withColor(
              const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [info, const SizedBox(height: 8), badge],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [info, badge],
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PriceComparisonCubit, PriceComparisonState>(
      builder: (context, state) {
        final itemId = (state as PriceComparisonInitial).selectedItemId;
        // Mock Item Names mapping
        final itemNames = {
          'paneer': 'Paneer',
          'chicken': 'Chicken',
          'oil': 'Cooking Oil',
          'rice': 'Basmati Rice',
        };
        final itemName = itemNames[itemId] ?? 'Paneer';

        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Comparison - $itemName',
                  style: AirMenuTextStyle.headingH3.withColor(
                    const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),

                // Mock Bar Chart
                Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (_) => Container(
                            height: 1,
                            color: const Color(0xFFF3F4F6),
                          ),
                        ),
                      ),
                      // Bars (Mock Visuals) - Customized based on ID to look dynamic
                      _MockBarChart(itemId: itemId),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _LegendItem(
                      color: const Color(0xFF10B981),
                      label: 'Lowest Price',
                    ),
                    const SizedBox(width: 16),
                    _LegendItem(
                      color: const Color(0xFFDC2626),
                      label: 'Current Vendor',
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Text(
                  'Vendor Details',
                  style: AirMenuTextStyle.headingH3.withColor(
                    const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),

                // Best Price Vendor
                _VendorCard(
                  name: 'Dairy Direct',
                  price: '295',
                  unit: 'kg',
                  rating: '4.2',
                  delivery: 'Next day',
                  minOrder: '10 kg',
                  updated: '1 day ago',
                  isBestPrice: true,
                  onSwitch: () {},
                ),
                const SizedBox(height: 16),

                // Other Vendor
                _VendorCard(
                  name: 'Farm Fresh',
                  price: '310',
                  unit: 'kg',
                  rating: '4.0',
                  delivery: '2-3 days',
                  minOrder: '3 kg',
                  updated: '3 days ago',
                  isBestPrice: false,
                  onSwitch: () {},
                ),

                const SizedBox(height: 32),
                Text(
                  'Price Trend (6 Months)',
                  style: AirMenuTextStyle.headingH4.withColor(
                    const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6E7).withOpacity(
                      0.3,
                    ), // Beige/Peach background like screenshot
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: CustomPaint(painter: _MockTrendChartPainter()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AirMenuTextStyle.small.medium500().withColor(
            const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

// Vendor Card
class _VendorCard extends StatelessWidget {
  final String name;
  final String price;
  final String unit;
  final String rating;
  final String delivery;
  final String minOrder;
  final String updated;
  final bool isBestPrice;
  final VoidCallback onSwitch;

  const _VendorCard({
    required this.name,
    required this.price,
    required this.unit,
    required this.rating,
    required this.delivery,
    required this.minOrder,
    required this.updated,
    required this.isBestPrice,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBestPrice ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestPrice
              ? const Color(0xFF86EFAC)
              : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AirMenuTextStyle.large.medium500().withColor(
                          const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Text(
                      '₹$price/$unit',
                      style: AirMenuTextStyle.headingH3.withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                if (isBestPrice) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Best Price',
                          style: AirMenuTextStyle.tiny.bold700().withColor(
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AirMenuTextStyle.large.medium500().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    if (isBestPrice) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best Price',
                              style: AirMenuTextStyle.tiny.bold700().withColor(
                                Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '₹$price/$unit',
                  style: AirMenuTextStyle.headingH3.withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          // Stats Row
          if (isMobile)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _VendorStat(
                  label: 'Rating',
                  value: rating,
                  icon: Icons.star,
                  iconColor: const Color(0xFFF59E0B),
                ),
                _VendorStat(label: 'Delivery', value: delivery),
                _VendorStat(label: 'Min Order', value: minOrder),
                _VendorStat(label: 'Updated', value: updated),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _VendorStat(
                  label: 'Rating',
                  value: rating,
                  icon: Icons.star,
                  iconColor: const Color(0xFFF59E0B),
                ),
                _VendorStat(label: 'Delivery', value: delivery),
                _VendorStat(label: 'Min Order', value: minOrder),
                _VendorStat(label: 'Updated', value: updated),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSwitch,
              style: OutlinedButton.styleFrom(
                backgroundColor: isBestPrice ? Colors.white : Colors.white,
                side: BorderSide(
                  color: isBestPrice
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Switch to this vendor',
                    style: AirMenuTextStyle.normal.bold600().withColor(
                      const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF111827),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _VendorStat({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.medium500().withColor(
            const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MockBarChart extends StatelessWidget {
  final String itemId;
  const _MockBarChart({required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 80, top: 10, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BarRow(
            label: 'Dairy Direct',
            widthPct: 0.8,
            color: const Color(0xFFDC2626),
          ), // Red for current? Wait screenshot shows Red as Current.
          _BarRow(
            label: 'Farm Fresh',
            widthPct: 0.85,
            color: const Color(0xFF10B981),
          ), // Green for best?
          _BarRow(
            label: 'Fresh Dairy Co.',
            widthPct: 0.9,
            color: const Color(0xFFF3F4F6),
          ),
          _BarRow(
            label: 'Quality Dairy',
            widthPct: 0.95,
            color: const Color(0xFFF3F4F6),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double widthPct;
  final Color color;

  const _BarRow({
    required this.label,
    required this.widthPct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AirMenuTextStyle.caption.medium500().withColor(
              const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthPct,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Simple CustomPainter to draw a nice looking curve
class _MockTrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Start low, go up, dip slightly, end high
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFFEF4444);
    final dots = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5), // approx
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    for (var dot in dots) {
      canvas.drawCircle(dot, 4, dotPaint);
      canvas.drawCircle(dot, 2, Paint()..color = Colors.white);
    }

    // Axis labels simplified/mocked
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
