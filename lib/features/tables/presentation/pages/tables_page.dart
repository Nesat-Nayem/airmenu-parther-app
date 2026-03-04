import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/table_repository.dart';
import '../bloc/tables_bloc.dart';
import '../widgets/tables_stats_row.dart';
import '../widgets/tables_toolbar.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/download_helper_stub.dart'
    if (dart.library.html) '../widgets/download_helper_web.dart'
    as download_helper;

class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TablesBloc(repository: GetIt.I<TableRepository>())..add(LoadTables()),
      child: const TablesPageView(),
    );
  }
}

// Mixin to hold download state — used in TablesPageView via StatefulWidget
class _TablesPageViewState extends State<TablesPageView> {
  bool _isDownloadingAll = false;

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
      // For vendors, hotelId is resolved by backend auth middleware
      // We pass the hotelId from localStorage via the repository's _getHotelId
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
          download_helper.downloadFileFromUrl(url, 'table_${tableNum}_qrcode.png');
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
    return _TablesPageViewContent(
      isDownloadingAll: _isDownloadingAll,
      onDownloadAll: () => _downloadAllQr(context),
    );
  }
}

class TablesPageView extends StatefulWidget {
  const TablesPageView({super.key});

  @override
  State<TablesPageView> createState() => _TablesPageViewState();
}

class _TablesPageViewContent extends StatelessWidget {
  final bool isDownloadingAll;
  final VoidCallback onDownloadAll;

  const _TablesPageViewContent({
    required this.isDownloadingAll,
    required this.onDownloadAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header removed as it is handled by AppScaffoldShell
          Expanded(
            child: BlocConsumer<TablesBloc, TablesState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.allTables.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFDC2626)),
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
                          style: TextStyle(color: Colors.grey.shade600),
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
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TablesBloc>().add(LoadTables());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        TablesStatsRow(tables: state.filteredTables),
                        const SizedBox(height: 24),

                        // Toolbar & Add Button
                        _buildToolbarSection(context, isDesktop, isDownloadingAll, onDownloadAll),
                        const SizedBox(height: 24),

                        // Grid
                        if (state.filteredTables.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No tables found',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop
                                      ? 4
                                      : (isTablet ? 2 : 1),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.4,
                                ),
                            itemCount: state.filteredTables.length,
                            itemBuilder: (context, index) {
                              return TableCard(
                                table: state.filteredTables[index],
                              );
                            },
                          ),
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

  Widget _buildToolbarSection(
    BuildContext context,
    bool isDesktop,
    bool isDownloadingAll,
    VoidCallback onDownloadAll,
  ) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const TablesToolbar(),
          ),
          Row(
            children: [
              if (kIsWeb)
              OutlinedButton.icon(
                onPressed: isDownloadingAll ? null : onDownloadAll,
                icon: isDownloadingAll
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(isDownloadingAll ? 'Downloading...' : 'Download All QR'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<TablesBloc>(),
                      child: const AddTableDialog(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Table'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile/Tablet Vertical Layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TablesToolbar(),
          const SizedBox(height: 16),
          Row(
            children: [
              if (kIsWeb) ...
              [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isDownloadingAll ? null : onDownloadAll,
                  icon: isDownloadingAll
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(isDownloadingAll ? 'Downloading...' : 'Download All QR'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<TablesBloc>(),
                        child: const AddTableDialog(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Table'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
