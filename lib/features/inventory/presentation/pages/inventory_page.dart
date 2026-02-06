import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/bulk_po_popup.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/create_po_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_widgets.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_fab.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_search_bar.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/scan_stock_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/manual_stock_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/supplier_price_comparison_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_forecasting_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/inventory_locations_main_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_export_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/vendor_management_dialogs.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_shimmer.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc()..add(LoadInventory()),
      child: const InventoryPageView(),
    );
  }
}

class InventoryPageView extends StatelessWidget {
  const InventoryPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAFAFA),
            body: InventoryShimmer(),
          );
        }

        final isMobile = Responsive.isMobile(context);

        return Scaffold(
          backgroundColor: InventoryColors.bgLight,
          body: Builder(
            builder: (innerContext) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 32,
                      vertical: isMobile ? 16 : 20, // Reduced from 24
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats Cards Grid
                        const _InventoryStatsGrid(),
                        const SizedBox(height: 20), // Reduced from 24
                        // Critical Alert
                        CriticalItemsAlert(
                          criticalItems: state.items
                              .where((i) => i.status == StockStatus.critical)
                              .toList(),
                          onCreatePO: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) => BulkPurchaseOrderDialog(
                                criticalItems: state.items
                                    .where(
                                      (i) => i.status == StockStatus.critical,
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),

                        // Search Bar with Filters
                        InventorySearchBar(
                          searchQuery: state.searchQuery,
                          onSearchChanged: (query) => context
                              .read<InventoryBloc>()
                              .add(UpdateSearchQuery(query)),
                          categoryFilter: state.categoryFilter,
                          onCategoryChanged: (category) => context
                              .read<InventoryBloc>()
                              .add(UpdateCategoryFilter(category)),
                          statusFilter: state.statusFilter,
                          onStatusChanged: (status) => context
                              .read<InventoryBloc>()
                              .add(UpdateStatusFilter(status)),
                          isCompactView: state.isCompactView,
                          onToggleCompact: () => context
                              .read<InventoryBloc>()
                              .add(ToggleCompactView()),
                          onCostAnalysis: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const SupplierPriceComparisonDialog(),
                            );
                          },
                          onForecast: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const InventoryForecastingDialog(),
                            );
                          },
                          onLocations: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const InventoryLocationsMainDialog(),
                            );
                          },
                          onExport: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const InventoryExportDialog(),
                            );
                          },
                          onVendors: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const VendorManagementDialog(),
                            );
                          },
                          onShortcuts: () {
                            // TODO: Show shortcuts dialog
                          },
                        ),
                        const SizedBox(height: 24),

                        // Inventory Table
                        InventoryItemsTable(
                          items: state.filteredItems,
                          isCompactView: state.isCompactView,
                          onRestock: (item) {},
                        ),
                        const SizedBox(height: 20),

                        // Secondary Widgets (POs & Recipe Mapping)
                        InventoryDashboardSecondaryWidgets(
                          recentOrders: state.recentOrders,
                          onNewPO: () {
                            showDialog(
                              context: innerContext,
                              builder: (context) =>
                                  const CreatePurchaseOrderDialog(),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: InventoryFAB(
            onAddItem: () {
              // TODO: Implement add item
            },
            onCreatePO: () {
              showDialog(
                context: context,
                builder: (context) => const CreatePurchaseOrderDialog(),
              );
            },
            onStockOut: () {
              showDialog(
                context: context,
                builder: (context) => const ManualStockDialog(isStockIn: false),
              );
            },
            onStockIn: () {
              showDialog(
                context: context,
                builder: (context) => const ManualStockDialog(isStockIn: true),
              );
            },
            onScanOut: () {
              showDialog(
                context: context,
                builder: (context) => const ScanStockDialog(isStockIn: false),
              );
            },
            onScanIn: () {
              showDialog(
                context: context,
                builder: (context) => const ScanStockDialog(isStockIn: true),
              );
            },
          ),
        );
      },
    );
  }
}

class _InventoryStatsGrid extends StatelessWidget {
  const _InventoryStatsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final isMobile = Responsive.isMobile(context);

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Total Items',
                      value: '156',
                      icon: Icons.inventory_2_outlined,
                      iconColor: InventoryColors.primaryRed,
                      showViewDetails: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Low Stock',
                      value: '12',
                      subtitle: 'vs yesterday',
                      trend: '2%',
                      isTrendPositive: false,
                      icon: Icons.warning_amber_rounded,
                      iconColor: InventoryColors.textQuaternary,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Near Expiry',
                      value: '5',
                      icon: Icons.calendar_today_outlined,
                      iconColor: InventoryColors.textQuaternary,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Today Usage',
                      value: '₹8.45M',
                      subtitle: 'vs yesterday',
                      trend: '15%',
                      isTrendPositive: true,
                      icon: Icons.trending_up,
                      iconColor: InventoryColors.textQuaternary,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InventoryStatCard(
                title: 'Wastage',
                value: '₹320',
                icon: Icons.delete_outline_rounded,
                iconColor: InventoryColors.textQuaternary,
                onTap: () {},
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('total_items'),
                title: 'Total Items',
                value: '156',
                icon: Icons.inventory_2_outlined,
                iconColor: InventoryColors.primaryRed,
                showViewDetails: true,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('low_stock'),
                title: 'Low Stock',
                value: '12',
                subtitle: 'vs yesterday',
                trend: '2%',
                isTrendPositive: false,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.grey.shade400,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('near_expiry'),
                title: 'Near Expiry',
                value: '5',
                icon: Icons.calendar_today_outlined,
                iconColor: Colors.grey.shade400,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('todays_usage'),
                title: 'Today\'s Usage',
                value: '₹8,450,450',
                subtitle: 'vs yesterday',
                trend: '15%',
                isTrendPositive: true,
                icon: Icons.trending_up,
                iconColor: Colors.grey.shade400,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SupplierPriceComparisonDialog(),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('wastage'),
                title: 'Wastage',
                value: '₹320',
                icon: Icons.delete_outline_rounded,
                iconColor: Colors.grey.shade400,
                onTap: () {},
              ),
            ),
          ],
        );
      },
    );
  }
}
