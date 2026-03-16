import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/transfer_stock_form_dialog.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

import 'package:airmenuai_partner_app/features/responsive.dart';

class StockByLocationTabContent extends StatefulWidget {
  const StockByLocationTabContent({super.key});

  @override
  State<StockByLocationTabContent> createState() => _StockByLocationTabContentState();
}

class _StockByLocationTabContentState extends State<StockByLocationTabContent> {
  List<InventoryItem> _materials = [];
  List<LocationModel> _locations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLocation = 'All Locations';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = locator<InventoryRepository>();
    final materialsRes = await repo.getMaterials();
    final locationsRes = await repo.getLocations();
    if (mounted) {
      setState(() {
        if (materialsRes is DataSuccess<List<InventoryItem>>) {
          _materials = materialsRes.data!;
        }
        if (locationsRes is DataSuccess<List<LocationModel>>) {
          _locations = locationsRes.data!;
        }
        _isLoading = false;
      });
    }
  }

  List<InventoryItem> get _filteredMaterials {
    var filtered = _materials;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.category.toLowerCase().contains(q)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    final locationNames = ['All Locations', ..._locations.map((l) => l.name)];

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      flex: isMobile ? 1 : 0,
                      child: Container(
                        width: isMobile ? double.infinity : 300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: 'Search items...',
                                  hintStyle: AirMenuTextStyle.small
                                      .medium500()
                                      .withColor(const Color(0xFF9CA3AF)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: AirMenuTextStyle.small.medium500(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      // Location Filter
                      PopupMenuButton<String>(
                        onSelected: (val) => setState(() => _selectedLocation = val),
                        itemBuilder: (context) => locationNames.map((l) =>
                          PopupMenuItem(value: l, child: Text(l)),
                        ).toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_selectedLocation, style: AirMenuTextStyle.small.medium500()),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TransferStockFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Transfer Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Headers (Hidden on Mobile)
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ITEM',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CATEGORY',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STOCK LEVEL',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!isMobile) const Divider(height: 1),

        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMaterials.isEmpty
                  ? Center(
                      child: Text(
                        _materials.isEmpty ? 'No inventory items found' : 'No items match your search',
                        style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF)),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: _filteredMaterials.map((item) => _StockRow(material: item)).toList(),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  final InventoryItem material;

  const _StockRow({required this.material});

  @override
  Widget build(BuildContext context) {
    final isCritical = material.status == StockStatus.critical;
    final isLow = material.status == StockStatus.low;

    Color barColor = isCritical
        ? const Color(0xFFEF4444)
        : (isLow ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
    String status = material.status.label;
    Color bg = isCritical
        ? const Color(0xFFFEF2F2)
        : (isLow ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
    Color text = isCritical
        ? const Color(0xFFDC2626)
        : (isLow ? const Color(0xFFD97706) : const Color(0xFF047857));

    final stockStr = '${material.currentStock.toStringAsFixed(material.currentStock.truncateToDouble() == material.currentStock ? 0 : 1)} ${material.unit}';
    final maxStr = material.reorderLevel > 0 ? material.reorderLevel.toStringAsFixed(0) : material.maxStock.toStringAsFixed(0);

    bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: AirMenuTextStyle.normal.bold600().withColor(
                          const Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        material.category.isNotEmpty ? material.category : 'Uncategorized',
                        style: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: AirMenuTextStyle.small.bold600().withColor(text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stockStr,
                            style: AirMenuTextStyle.small.bold600().withColor(
                              const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '/ $maxStr',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: material.stockPercentage,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: AirMenuTextStyle.normal.bold600().withColor(
                    const Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  material.sku.isNotEmpty ? material.sku : '',
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              material.category.isNotEmpty ? material.category : 'Uncategorized',
              style: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stockStr,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        '/ $maxStr',
                        style: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    width: 120,
                    child: LinearProgressIndicator(
                      value: material.stockPercentage,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: text),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: AirMenuTextStyle.small.bold600().withColor(text),
                      ),
                    ],
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
