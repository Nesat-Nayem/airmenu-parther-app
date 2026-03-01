import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/locations_extended_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/transfer_stock_form_dialog.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class TransfersTabContent extends StatelessWidget {
  const TransfersTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsExtCubit, LocationsExtState>(
      builder: (context, state) {
        if (state.status == LocationsExtStatus.loading && state.transfers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final transfers = state.transfers;
        final activeCount = transfers.where((t) => t.status != 'completed' && t.status != 'cancelled').length;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$activeCount active transfer${activeCount == 1 ? '' : 's'}',
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<LocationsExtCubit>(),
                          child: const TransferStockFormDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('New Transfer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (transfers.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No transfers found')))
              else
                ...transfers.expand((t) => [
                  _TransferCard(
                    item: t.materialName,
                    qty: '${t.quantity.toStringAsFixed(1)} ${t.unit}',
                    from: t.fromLocationName,
                    to: t.toLocationName,
                    date: 'Created: ${t.createdAt.toLocal().toString().substring(0, 16)}',
                    status: t.status,
                  ),
                  const SizedBox(height: 16),
                ]),
            ],
          ),
        );
      },
    );
  }
}

class _TransferCard extends StatelessWidget {
  final String item;
  final String qty;
  final String from;
  final String to;
  final String date;
  final String status;

  const _TransferCard({
    required this.item,
    required this.qty,
    required this.from,
    required this.to,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFECFDF5);
    Color text = const Color(0xFF047857);
    if (status == 'in transit') {
      bg = const Color(0xFFFFFBEB);
      text = const Color(0xFFD97706);
    } else if (status == 'pending') {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFC2410C);
    }

    bool isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item,
                      style: AirMenuTextStyle.large.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (isMobile)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          qty,
                          style: AirMenuTextStyle.normal.medium500().withColor(
                            const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Text(
                  qty,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: text),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: AirMenuTextStyle.small.bold600().withColor(text),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location Row (Responsive)
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationItem(label: 'From', value: from),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                ),
                _LocationItem(label: 'To', value: to),
              ],
            )
          else
            Row(
              children: [
                Flexible(
                  child: Text(
                    from,
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.swap_horiz,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
                Flexible(
                  child: Text(
                    to,
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),
          Text(
            date,
            style: AirMenuTextStyle.small.medium500().withColor(
              const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String label;
  final String value;

  const _LocationItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AirMenuTextStyle.small.medium500().withColor(
            const Color(0xFF9CA3AF),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AirMenuTextStyle.normal.medium500().withColor(
              const Color(0xFF4B5563),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
