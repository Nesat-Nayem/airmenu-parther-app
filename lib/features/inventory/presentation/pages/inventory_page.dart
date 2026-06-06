import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/add_edit_material_dialog.dart';
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
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryBloc(locator<InventoryRepository>())
        ..add(LoadInventory())
        ..add(LoadRecipes()),
      child: const InventoryPageView(),
    );
  }
}

class InventoryPageView extends StatefulWidget {
  const InventoryPageView({super.key});

  @override
  State<InventoryPageView> createState() => _InventoryPageViewState();
}

class _InventoryPageViewState extends State<InventoryPageView> {
  final _secondaryWidgetsKey = GlobalKey<InventoryDashboardSecondaryWidgetsState>();

  Future<bool?> _openCreatePODialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const CreatePurchaseOrderDialog(),
    );
  }

  Future<void> _afterPOCreated(bool? created) async {
    if (created != true || !mounted) return;
    context.read<InventoryBloc>().add(RefreshInventory());
    await _secondaryWidgetsKey.currentState?.reloadPurchaseOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.successMessage != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: InventoryColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state.errorMessage != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: InventoryColors.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
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
          body: Stack(
            children: [
              Builder(
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
                              onCreatePO: () async {
                                final result = await showDialog<bool>(
                                  context: innerContext,
                                  builder: (context) => BulkPurchaseOrderDialog(
                                    criticalItems: state.items
                                        .where(
                                          (i) => i.status == StockStatus.critical,
                                        )
                                        .toList(),
                                  ),
                                );
                                if (innerContext.mounted) {
                                  innerContext
                                      .read<InventoryBloc>()
                                      .add(RefreshInventory());
                                  if (result == true) {
                                    await _secondaryWidgetsKey.currentState
                                        ?.reloadPurchaseOrders();
                                  }
                                }
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
                            ),
                            const SizedBox(height: 20),

                            // Secondary Widgets (Recipe Mapping)
                            InventoryDashboardSecondaryWidgets(
                              key: _secondaryWidgetsKey,
                              onNewPO: () => _openCreatePODialog(innerContext),
                            ),
                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Action-loading overlay for create/update/delete/stock operations
              if (state.isActionLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          InventoryColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: InventoryFAB(
            onAddItem: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<InventoryBloc>(),
                  child: const AddEditMaterialDialog(),
                ),
              );
            },
            onCreatePO: () async {
              final created = await _openCreatePODialog(context);
              await _afterPOCreated(created);
            },
            onStockOut: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<InventoryBloc>(),
                  child: const ManualStockDialog(isStockIn: false),
                ),
              );
            },
            onStockIn: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<InventoryBloc>(),
                  child: const ManualStockDialog(isStockIn: true),
                ),
              );
            },
            onScanOut: () {
              showDialog(
                context: context,
                builder: (_) => const ScanStockDialog(isStockIn: false),
              );
            },
            onScanIn: () {
              showDialog(
                context: context,
                builder: (_) => const ScanStockDialog(isStockIn: true),
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

        final totalItems = state.totalItems.toString();
        final lowStock = state.lowStockCount.toString();
        final criticalCount = state.criticalCount.toString();
        final totalCost = state.analytics.totalCost > 0
            ? '₹${state.analytics.totalCost.toStringAsFixed(0)}'
            : '—';
        final wastage = state.analytics.totalWastage > 0
            ? '₹${state.analytics.totalWastage.toStringAsFixed(0)}'
            : '—';

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Total Items',
                      value: totalItems,
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
                      value: lowStock,
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
                      title: 'Critical',
                      value: criticalCount,
                      icon: Icons.error_outline_rounded,
                      iconColor: InventoryColors.textQuaternary,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InventoryStatCard(
                      title: 'Total Cost',
                      value: totalCost,
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
                value: wastage,
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
                value: totalItems,
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
                value: lowStock,
                isTrendPositive: false,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.grey.shade400,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('critical'),
                title: 'Critical',
                value: criticalCount,
                icon: Icons.error_outline_rounded,
                iconColor: Colors.red.shade400,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InventoryStatCard(
                key: const ValueKey('total_cost'),
                title: 'Total Cost',
                value: totalCost,
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
                value: wastage,
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
