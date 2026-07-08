import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/repositories/table_repository.dart';
import '../../data/repositories/zone_repository.dart';
import '../bloc/tables_bloc.dart';
import '../widgets/tables_stats_row.dart';
import '../widgets/tables_toolbar.dart';
import '../widgets/table_card.dart';
import '../widgets/table_list_row.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/zone_manager_dialog.dart';
import '../widgets/download_helper_stub.dart'
    if (dart.library.html) '../widgets/download_helper_web.dart'
    as download_helper;

class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TablesBloc(
        repository: GetIt.I<TableRepository>(),
        zoneRepository: GetIt.I<ZoneRepository>(),
      )
        ..add(LoadTables())
        ..add(LoadZones()),
      child: const TablesPageView(),
    );
  }
}

class TablesPageView extends StatefulWidget {
  const TablesPageView({super.key});

  @override
  State<TablesPageView> createState() => _TablesPageViewState();
}

class _TablesPageViewState extends State<TablesPageView> {
  bool _isDownloadingAll = false;
  bool _isGridView = true;

  Future<void> _downloadAllQr(BuildContext context) async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download All is only supported on web')),
      );
      return;
    }
    setState(() => _isDownloadingAll = true);
    try {
      final repo = GetIt.I<TableRepository>();
      final hotelId = await repo.getVendorHotelId() ?? '';
      final urls = await repo.getDownloadAllUrls(hotelId);
      if (urls.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No QR codes to download')),
          );
        }
        return;
      }
      for (final item in urls) {
        final url = item['qrCodeImage'] ?? '';
        final tableNum = item['tableNumber'] ?? '';
        if (url.isNotEmpty) {
          download_helper.downloadFileFromUrl(
            url,
            'table_${tableNum}_qrcode.png',
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ${urls.length} QR codes...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    return Scaffold(
      backgroundColor: TableCardLayout.canvas,
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<TablesBloc, TablesState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!)),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.allTables.isEmpty) {
                  return _TablesLoadingSkeleton(
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    isGrid: _isGridView,
                  );
                }

                if (state.error != null && state.allTables.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: GoogleFonts.sora(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<TablesBloc>().add(LoadTables());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TableCardLayout.accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: TableCardLayout.accent,
                  onRefresh: () async {
                    context.read<TablesBloc>().add(LoadTables());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TablesStatsRow(tables: state.allTables),
                        const SizedBox(height: 20),
                        _buildToolbarSection(
                          context,
                          isDesktop,
                          _isDownloadingAll,
                          () => _downloadAllQr(context),
                        ),
                        const SizedBox(height: 20),
                        if (state.filteredTables.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Text(
                                'No tables found',
                                style: GoogleFonts.sora(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else if (_isGridView)
                          _buildGrid(state, isDesktop, isTablet)
                        else
                          _buildList(state),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(TablesState state, bool isDesktop, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 210,
      ),
      itemCount: state.filteredTables.length,
      itemBuilder: (context, index) {
        return TableCard(
          table: state.filteredTables[index],
          animationIndex: index,
        );
      },
    );
  }

  Widget _buildList(TablesState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TableCardLayout.idleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const _ListHeader(),
          ...List.generate(state.filteredTables.length, (index) {
            return TableListRow(
              table: state.filteredTables[index],
              animationIndex: index,
              isLast: index == state.filteredTables.length - 1,
            );
          }),
        ],
      ),
    );
  }

  void _showZoneManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TablesBloc>(),
        child: const ZoneManagerDialog(),
      ),
    );
  }

  Widget _buildToolbarSection(
    BuildContext context,
    bool isDesktop,
    bool isDownloadingAll,
    VoidCallback onDownloadAll,
  ) {
    final actions = _buildActions(context, isDownloadingAll, onDownloadAll);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TablesToolbar(
              isGridView: _isGridView,
              onViewModeChanged: (isGrid) {
                setState(() => _isGridView = isGrid);
              },
            ),
          ),
          const SizedBox(width: 12),
          actions,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TablesToolbar(
          isGridView: _isGridView,
          onViewModeChanged: (isGrid) {
            setState(() => _isGridView = isGrid);
          },
        ),
        const SizedBox(height: 12),
        actions,
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    bool isDownloadingAll,
    VoidCallback onDownloadAll,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _OutlineAction(
          icon: Icons.layers_outlined,
          label: 'Manage Zones',
          onPressed: () => _showZoneManager(context),
        ),
        if (kIsWeb)
          _OutlineAction(
            icon: Icons.download_rounded,
            label: isDownloadingAll ? 'Downloading...' : 'Download All QR',
            onPressed: isDownloadingAll ? null : onDownloadAll,
            loading: isDownloadingAll,
          ),
        _GradientAction(
          icon: Icons.add,
          label: 'Add Table',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<TablesBloc>(),
                child: const AddTableDialog(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: TableCardLayout.idleBorder),
        textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _GradientAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GradientAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC52031), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TableCardLayout.accent.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.sora(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: TableCardLayout.muted,
      letterSpacing: 0.4,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TableCardLayout.idleBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('TABLE', style: style)),
          Expanded(flex: 2, child: Text('ZONE', style: style)),
          Expanded(child: Text('CAPACITY', style: style)),
          Expanded(child: Text('STATUS', style: style)),
          SizedBox(
            width: 100,
            child: Text('ACTIONS', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _TablesLoadingSkeleton extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final bool isGrid;

  const _TablesLoadingSkeleton({
    required this.isDesktop,
    required this.isTablet,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFECE8E6),
        highlightColor: const Color(0xFFF8F6F4),
        child: Column(
          children: [
            const TablesStatsSkeleton(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 120,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isGrid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 210,
                ),
                itemCount: crossAxisCount * 2,
                itemBuilder: (_, _) => const TableCardSkeleton(),
              )
            else
              Column(
                children: List.generate(
                  6,
                  (_) => Container(
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
