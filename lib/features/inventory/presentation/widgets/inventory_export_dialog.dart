import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/export_cubit.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class InventoryExportDialog extends StatelessWidget {
  const InventoryExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: BlocBuilder<ExportCubit, ExportState>(
          builder: (context, state) {
            final isPdf = state.selectedFormat == ExportFormat.pdf;
            final isExcel = state.selectedFormat == ExportFormat.excel;
            final isLoading = state.status == ExportStatus.loading;
            final isSuccess = state.status == ExportStatus.success;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        color: const Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Export Inventory Data',
                        style: AirMenuTextStyle.headingH4.withColor(
                          const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Format Selection
                  Text(
                    'Export Format',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FormatCard(
                          icon: Icons.table_chart_outlined,
                          label: 'Excel (.xlsx)',
                          sub: 'Spreadsheet format',
                          isSelected: isExcel,
                          onTap: () => context.read<ExportCubit>().selectFormat(
                            ExportFormat.excel,
                          ),
                          color: const Color(0xFF10B981), // Green for Excel
                          bg: const Color(0xFFECFDF5),
                          border: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FormatCard(
                          icon: Icons.picture_as_pdf_outlined,
                          label: 'PDF',
                          sub: 'Print-ready format',
                          isSelected: isPdf,
                          onTap: () => context.read<ExportCubit>().selectFormat(
                            ExportFormat.pdf,
                          ),
                          color: const Color(0xFFEF4444), // Red for PDF
                          bg: const Color(0xFFFEF2F2),
                          border: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Data Selection
                  Text(
                    'Select Data to Export',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CheckboxRow(
                    label: 'Inventory Items',
                    sub: 'All items with stock levels, vendors, and values',
                    isSelected: state.selectedDataTypes.contains(
                      ExportDataType.inventoryItems,
                    ),
                    onTap: () => context.read<ExportCubit>().toggleDataType(
                      ExportDataType.inventoryItems,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CheckboxRow(
                    label: 'Purchase Orders',
                    sub: 'PO history with vendors and totals',
                    isSelected: state.selectedDataTypes.contains(
                      ExportDataType.purchaseOrders,
                    ),
                    onTap: () => context.read<ExportCubit>().toggleDataType(
                      ExportDataType.purchaseOrders,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CheckboxRow(
                    label: 'Analytics Data',
                    sub: 'Consumption, wastage, and cost analysis',
                    isSelected: state.selectedDataTypes.contains(
                      ExportDataType.analytics,
                    ),
                    onTap: () => context.read<ExportCubit>().toggleDataType(
                      ExportDataType.analytics,
                    ),
                  ),

                  // Status Banner area
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (isLoading || isSuccess) ? 80 : 0,
                    margin: (isLoading || isSuccess)
                        ? const EdgeInsets.only(top: 24)
                        : EdgeInsets.zero,
                    child: ClipRRect(
                      // Clip content when height 0
                      borderRadius: BorderRadius.circular(16),
                      child: (isLoading || isSuccess)
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSuccess
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (isLoading)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFFEF4444),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF10B981),
                                      size: 24,
                                    ),

                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isSuccess
                                            ? 'Export Complete!'
                                            : 'Generating Report...',
                                        style: AirMenuTextStyle.normal
                                            .bold600()
                                            .withColor(
                                              isSuccess
                                                  ? const Color(0xFF047857)
                                                  : const Color(0xFF111827),
                                            ),
                                      ),
                                      Text(
                                        isSuccess
                                            ? 'Your file has been downloaded'
                                            : 'Exporting ${state.selectedDataTypes.length} data types to ${isPdf ? 'PDF' : 'Excel'}',
                                        style: AirMenuTextStyle.small
                                            .medium500()
                                            .withColor(
                                              isSuccess
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFF6B7280),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          foregroundColor: const Color(0xFF374151),
                        ),
                        child: Text(
                          'Cancel',
                          style: AirMenuTextStyle.normal.bold600(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: (isLoading)
                            ? null // Disable tap while loading
                            : () => context.read<ExportCubit>().exportData(),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.download, size: 18),
                        label: Text(
                          isLoading
                              ? 'Exporting...'
                              : 'Export ${isPdf ? 'PDF' : 'EXCEL'}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: InventoryColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0, // Flat premium look
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final Color bg;
  final Color border;

  const _FormatCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? bg : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? border : Colors.transparent,
            width: 1.5,
          ),
          /* boxShadow optional if you want depth, keeping flat for modern look */
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? color
                  : const Color(0xFF6B7280), // Grey when not selected
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AirMenuTextStyle.normal.bold600().withColor(
                const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: AirMenuTextStyle.tiny.medium500().withColor(
                const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final String sub;
  final bool isSelected;
  final VoidCallback onTap;

  const _CheckboxRow({
    required this.label,
    required this.sub,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: AirMenuTextStyle.small.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
