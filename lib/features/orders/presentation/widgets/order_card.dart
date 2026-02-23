import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onViewDetails;

  const OrderCard({super.key, required this.order, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient and status dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AirMenuColors.primary,
                    AirMenuColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Table info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${order.tableNumber ?? "N/A"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getShortOrderId(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status dropdown with icon - Compact
                  _buildHeaderStatusDropdown(context),
                ],
              ),
            ),

            // Content - Ultra compact
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Guest count and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.users?.length ?? 0} Guest(s)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (order.createdAt != null)
                          Text(
                            _formatDate(order.createdAt!),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),

                    // Items summary
                    _buildItemsSummary(),

                    // Bottom section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bill Total with payment info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Bill Total',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                // Payment status and method below
                                if (order.paymentStatus != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        _getPaymentStatusIcon(),
                                        size: 10,
                                        color: _getPaymentStatusColor(),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        order.paymentStatus!.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: _getPaymentStatusColor(),
                                        ),
                                      ),
                                      if (order.paymentMethod != null) ...[
                                        const Text(
                                          ' • ',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        Text(
                                          order.paymentMethod!,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            // Total amount
                            Text(
                              NumberFormat.currency(
                                symbol: '₹',
                                decimalDigits: 0,
                                locale: 'en_IN',
                              ).format(order.totalAmount ?? 0),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AirMenuColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Action buttons - Ultra compact
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onViewDetails,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AirMenuColors.primary,
                                  ),
                                  foregroundColor: AirMenuColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'View Order',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  debugPrint(
                                    'Print bill for order: ${order.id}',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                  foregroundColor: const Color(0xFF6B7280),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Print Bill',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortOrderId() {
    final orderId = order.id ?? 'N/A';
    if (orderId.length > 8) {
      return '#${orderId.substring(orderId.length - 8)}';
    }
    return '#$orderId';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  // Status dropdown in header - Compact with only 4 statuses
  Widget _buildHeaderStatusDropdown(BuildContext context) {
    final status = order.status ?? 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 12, color: Colors.white),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: status,
            underline: const SizedBox(),
            isDense: true,
            dropdownColor: AirMenuColors.primary,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 14,
            ),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null && newValue != status) {
                _showStatusUpdateConfirmation(context, newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'processing':
        return Icons.sync;
      case 'delivered':
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildItemsSummary() {
    final items = order.items ?? [];
    if (items.isEmpty) {
      return const Text(
        'No items',
        style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      );
    }

    final itemCount = items.length;
    final firstItem = items.first;

    final allItems = items
        .map(
          (item) =>
              '• ${item.menuItemData?.title ?? "Unknown"} x${item.quantity ?? 1}',
        )
        .join('\n');

    return Row(
      children: [
        const Icon(Icons.restaurant_menu, size: 11, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            firstItem.menuItemData?.title ?? "Unknown",
            style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (itemCount > 1)
          Tooltip(
            message: allItems,
            waitDuration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(fontSize: 11, color: Colors.white),
            child: Text(
              '+${itemCount - 1}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _showStatusUpdateConfirmation(BuildContext context, String newStatus) {
    final formattedStatus =
        '${newStatus[0].toUpperCase()}${newStatus.substring(1)}';
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Update Order Status',
        message:
            'Are you sure you want to change the order status to $formattedStatus?',
        confirmText: 'Yes, update it!',
        cancelText: 'Cancel',
        icon: Icons.sync,
        onConfirm: () {
          context.read<OrdersBloc>().add(
            UpdateOrderStatus(orderId: order.id!, newStatus: newStatus),
          );
        },
      ),
    );
  }

  Color _getPaymentStatusColor() {
    final status = order.paymentStatus?.toLowerCase() ?? '';
    switch (status) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFFBBF24);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getPaymentStatusIcon() {
    final status = order.paymentStatus?.toLowerCase() ?? '';
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.payment;
    }
  }
}
