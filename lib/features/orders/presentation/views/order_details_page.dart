import 'package:airmenuai_partner_app/utils/widgets/airmenu_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/utils/widgets/airmenu_dropdown.dart';
import 'package:airmenuai_partner_app/utils/widgets/airmenu_text_field.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController _refundAmountCtrl = TextEditingController();
  final TextEditingController _refundReasonCtrl = TextEditingController();
  final TextEditingController _manualPaymentCtrl = TextEditingController();
  String _refundMethod = 'cash';

  @override
  void dispose() {
    _refundAmountCtrl.dispose();
    _refundReasonCtrl.dispose();
    _manualPaymentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is RefundSuccess) {
          _showSuccess('Refund processed successfully');
          _refundAmountCtrl.clear();
          _refundReasonCtrl.clear();
        } else if (state is RefundFailure) {
          _showError(state.message);
        } else if (state is ManualPaymentSuccess) {
          _showSuccess('Payment recorded successfully');
          _manualPaymentCtrl.clear();
        } else if (state is ManualPaymentFailure) {
          _showError(state.message);
        } else if (state is MarkCompleteSuccess) {
          _showSuccess('Order marked as complete');
          Navigator.pop(context);
        } else if (state is MarkCompleteFailure) {
          _showError(state.message);
        } else if (state is ItemStatusUpdateSuccess) {
          _showSuccess('Item status updated');
        } else if (state is ItemStatusUpdateFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildOrderItemsCard(isMobile: true),
        const SizedBox(height: 16),
        if (widget.order.users != null && widget.order.users!.isNotEmpty) ...[
          _buildGuestsCard(),
          const SizedBox(height: 16),
        ],
        _buildOrderInfoCard(),
        const SizedBox(height: 16),
        _buildPaymentCard(isMobile: true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildOrderItemsCard(isMobile: false)),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              if (widget.order.users != null &&
                  widget.order.users!.isNotEmpty) ...[
                _buildGuestsCard(),
                const SizedBox(height: 16),
              ],
              _buildOrderInfoCard(),
              const SizedBox(height: 16),
              _buildPaymentCard(isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Order #${_getShortOrderId()}',
            style: AirMenuTextStyle.headingH4,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.order.hotel?.name != null)
            Text(
              widget.order.hotel!.name!,
              style: AirMenuTextStyle.caption.copyWith(
                color: AirMenuColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined, size: 20),
          onPressed: _handlePrintKOT,
          tooltip: 'Print KOT',
        ),
        IconButton(
          icon: const Icon(Icons.print_outlined, size: 20),
          onPressed: _handlePrintBill,
          tooltip: 'Print Bill',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOrderItemsCard({required bool isMobile}) {
    final refunds = widget.order.refunds ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Items', style: AirMenuTextStyle.subheadingH5),
                      Text(
                        '${widget.order.items?.length ?? 0} items',
                        style: AirMenuTextStyle.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (refunds.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Refund History',
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...refunds.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDate(r.createdAt ?? ''),
                              style: AirMenuTextStyle.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCurrency(r.amount ?? 0),
                            style: AirMenuTextStyle.small.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              r.method?.toUpperCase() ?? 'N/A',
                              style: AirMenuTextStyle.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children:
                  widget.order.items
                      ?.map((item) => _buildOrderItem(item, isMobile))
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.menuItemData?.image != null &&
                        item.menuItemData!.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.menuItemData!.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuItemData?.title ?? 'Unknown Item',
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.size != null)
                      Text(
                        item.size!,
                        style: AirMenuTextStyle.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'x${item.quantity ?? 1}',
                            style: AirMenuTextStyle.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatCurrency(item.price ?? 0),
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.specialInstructions != null &&
              item.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_outlined, size: 14, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.specialInstructions!,
                      style: AirMenuTextStyle.caption.copyWith(
                        color: Colors.blue[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AirMenuDropdown<String>(
              value: item.status ?? 'pending',
              items: const ['pending', 'preparing', 'served', 'cancelled'],
              itemBuilder: (value) =>
                  value[0].toUpperCase() + value.substring(1),
              onChanged: (value) {
                if (value != null && item.id != null) {
                  context.read<OrdersBloc>().add(
                    UpdateItemStatus(
                      orderId: widget.order.id!,
                      itemId: item.id!,
                      status: value,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.restaurant, size: 24, color: Colors.grey[400]),
  );

  Widget _buildGuestsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 16,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(width: 10),
              Text('Guests', style: AirMenuTextStyle.subheadingH5),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.order.users!.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AirMenuColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: AirMenuColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'Guest',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.phone != null)
                          Text(
                            user.phone!,
                            style: AirMenuTextStyle.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 10),
              Text('Order Information', style: AirMenuTextStyle.subheadingH5),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Table',
            widget.order.tableNumber ?? 'N/A',
            Icons.table_restaurant,
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Status', widget.order.status ?? 'pending', Icons.info),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Placed',
            _formatDate(widget.order.createdAt ?? ''),
            Icons.access_time,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Updated',
            _formatDate(widget.order.updatedAt ?? ''),
            Icons.update,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(label, style: AirMenuTextStyle.caption),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AirMenuTextStyle.small.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard({required bool isMobile}) {
    final refundable =
        (widget.order.amountPaid ?? 0) - (widget.order.amountRefunded ?? 0);
    final amountDue =
        (widget.order.totalAmount ?? 0) - (widget.order.amountPaid ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final isProcessing =
              state is RefundProcessing ||
              state is ManualPaymentProcessing ||
              state is MarkCompleteProcessing;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Payment', style: AirMenuTextStyle.subheadingH5),
                ],
              ),
              const SizedBox(height: 16),
              _buildPaymentRow('Subtotal', widget.order.subtotal ?? 0),
              const SizedBox(height: 8),
              _buildPaymentRow(
                'Taxes',
                (widget.order.cgstAmount ?? 0) + (widget.order.sgstAmount ?? 0),
              ),
              const SizedBox(height: 8),
              _buildPaymentRow('Service', widget.order.serviceCharge ?? 0),
              if ((widget.order.discountAmount ?? 0) > 0) ...[
                const SizedBox(height: 8),
                _buildPaymentRow(
                  'Discount',
                  -(widget.order.discountAmount ?? 0),
                  isDiscount: true,
                ),
              ],
              Divider(height: 24, color: Colors.grey[200]),
              _buildPaymentRow(
                'Total',
                widget.order.totalAmount ?? 0,
                isTotal: true,
              ),
              const SizedBox(height: 10),
              _buildPaymentRow(
                'Paid',
                widget.order.amountPaid ?? 0,
                color: Colors.green[700],
              ),
              const SizedBox(height: 8),
              _buildPaymentRow(
                'Due',
                amountDue,
                color: amountDue > 0 ? Colors.orange[700] : Colors.grey[600],
              ),
              if ((widget.order.amountRefunded ?? 0) > 0) ...[
                const SizedBox(height: 8),
                _buildPaymentRow(
                  'Refunded',
                  widget.order.amountRefunded ?? 0,
                  color: Colors.red[700],
                ),
              ],
              if (amountDue > 0 || refundable > 0) ...[
                Divider(height: 24, color: Colors.grey[200]),
                if (amountDue > 0) ...[
                  Text('Record Payment', style: AirMenuTextStyle.subheadingH5),
                  const SizedBox(height: 12),
                  isMobile
                      ? Column(
                          children: [
                            AirMenuTextField(
                              controller: _manualPaymentCtrl,
                              hint: 'Enter amount',
                              keyboardType: TextInputType.number,
                              enabled: !isProcessing,
                            ),
                            const SizedBox(height: 12),
                            AirMenuButton(
                              label: 'Record',
                              onPressed: _handleManualPayment,
                              isLoading: isProcessing,
                              width: double.infinity,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: AirMenuTextField(
                                controller: _manualPaymentCtrl,
                                hint: 'Enter amount',
                                keyboardType: TextInputType.number,
                                enabled: !isProcessing,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AirMenuButton(
                              label: 'Record',
                              onPressed: _handleManualPayment,
                              isLoading: isProcessing,
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                ],
                if (refundable > 0) ...[
                  Text('Process Refund', style: AirMenuTextStyle.subheadingH5),
                  const SizedBox(height: 12),
                  AirMenuTextField(
                    controller: _refundAmountCtrl,
                    hint: 'Refund amount',
                    keyboardType: TextInputType.number,
                    enabled: !isProcessing,
                  ),
                  const SizedBox(height: 12),
                  AirMenuDropdown<String>(
                    value: _refundMethod,
                    items: const ['cash', 'razorpay'],
                    itemBuilder: (value) =>
                        value[0].toUpperCase() + value.substring(1),
                    onChanged: !isProcessing
                        ? (value) => setState(() => _refundMethod = value!)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AirMenuTextField(
                    controller: _refundReasonCtrl,
                    hint: 'Reason (optional)',
                    maxLines: 2,
                    enabled: !isProcessing,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available: ${_formatCurrency(refundable)}',
                    style: AirMenuTextStyle.caption,
                  ),
                  const SizedBox(height: 12),
                  AirMenuButton(
                    label: 'Process Refund',
                    onPressed: _handleRefund,
                    width: double.infinity,
                    isLoading: isProcessing,
                  ),
                ],
                if (amountDue <= 0 && refundable <= 0) ...[
                  const SizedBox(height: 16),
                  AirMenuButton(
                    label: 'Mark as Completed',
                    onPressed: _handleMarkComplete,
                    width: double.infinity,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    isLoading: isProcessing,
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    num amount, {
    bool isTotal = false,
    bool isDiscount = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w700)
              : AirMenuTextStyle.small,
        ),
        Text(
          _formatCurrency(amount.abs()),
          style:
              (isTotal
                      ? AirMenuTextStyle.subheadingH5.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      : AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ))
                  .copyWith(
                    color: color ?? (isDiscount ? Colors.green[700] : null),
                  ),
        ),
      ],
    );
  }

  void _handlePrintBill() =>
      _showInfo('Print Bill functionality - Coming soon');
  void _handlePrintKOT() => _showInfo('Print KOT functionality - Coming soon');

  void _handleRefund() {
    final amount = double.tryParse(_refundAmountCtrl.text) ?? 0;
    if (amount <= 0) {
      _showError('Please enter a valid refund amount');
      return;
    }
    context.read<OrdersBloc>().add(
      ProcessRefund(
        orderId: widget.order.id!,
        amount: amount,
        method: _refundMethod,
        reason: _refundReasonCtrl.text.isNotEmpty
            ? _refundReasonCtrl.text
            : null,
      ),
    );
  }

  void _handleManualPayment() {
    final amount = double.tryParse(_manualPaymentCtrl.text) ?? 0;
    if (amount <= 0) {
      _showError('Please enter a valid payment amount');
      return;
    }
    context.read<OrdersBloc>().add(
      RecordManualPayment(orderId: widget.order.id!, amount: amount),
    );
  }

  void _handleMarkComplete() => context.read<OrdersBloc>().add(
    MarkOrderComplete(orderId: widget.order.id!),
  );

  void _showSuccess(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[600],
      behavior: SnackBarBehavior.floating,
    ),
  );
  void _showInfo(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue[600],
      behavior: SnackBarBehavior.floating,
    ),
  );

  String _formatCurrency(num amount) => NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  ).format(amount);

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  String _getShortOrderId() {
    final orderId = widget.order.id ?? 'N/A';
    return orderId.length > 8 ? orderId.substring(orderId.length - 8) : orderId;
  }
}
