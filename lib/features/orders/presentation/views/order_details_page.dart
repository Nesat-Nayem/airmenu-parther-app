import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'print_helper_stub.dart'
    if (dart.library.html) 'print_helper_web.dart';

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
  late String _orderStatus;

  static const _allStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'served',
    'completed',
    'cancelled',
  ];

  static const _itemStatuses = ['pending', 'preparing', 'served', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order.status ?? 'pending';
  }

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
          _showSnack('Refund processed successfully', Colors.green[600]!);
          _refundAmountCtrl.clear();
          _refundReasonCtrl.clear();
        } else if (state is RefundFailure) {
          _showSnack(state.message, Colors.red[600]!);
        } else if (state is ManualPaymentSuccess) {
          _showSnack('Payment recorded successfully', Colors.green[600]!);
          _manualPaymentCtrl.clear();
        } else if (state is ManualPaymentFailure) {
          _showSnack(state.message, Colors.red[600]!);
        } else if (state is MarkCompleteSuccess) {
          _showSnack('Order marked as complete', Colors.green[600]!);
          Navigator.pop(context);
        } else if (state is MarkCompleteFailure) {
          _showSnack(state.message, Colors.red[600]!);
        } else if (state is ItemStatusUpdateSuccess) {
          _showSnack('Item status updated', Colors.green[600]!);
        } else if (state is ItemStatusUpdateFailure) {
          _showSnack(state.message, Colors.red[600]!);
        } else if (state is OrderStatusUpdateSuccess) {
          _showSnack('Order status updated', Colors.green[600]!);
        } else if (state is OrderStatusUpdateFailure) {
          _showSnack(state.message, Colors.red[600]!);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return CustomScrollView(
              slivers: [
                _buildHeader(isDesktop),
                SliverPadding(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  sliver: SliverToBoxAdapter(
                    child: isDesktop
                        ? _buildDesktopLayout()
                        : _buildMobileLayout(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDesktop) {
    final o = widget.order;
    return SliverAppBar(
      pinned: true,
      toolbarHeight: isDesktop ? 80 : 70,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 0, isDesktop ? 24 : 16, 0),
        alignment: Alignment.center,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Back button
              _headerIconBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
              const SizedBox(width: 16),
              // Order info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #${_getShortOrderId()}',
                          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 12),
                          _statusBadge(_orderStatus, _statusColor(_orderStatus)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (o.hotel?.name != null) ...[
                          Text('Hotel: ', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280))),
                          Text(o.hotel!.name!, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AirMenuColors.primary)),
                          const SizedBox(width: 12),
                        ],
                        if (o.tableNumber != null) ...[
                          Text('Table: ', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280))),
                          Text(o.tableNumber!, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AirMenuColors.primary)),
                          const SizedBox(width: 12),
                        ],
                        if (!isDesktop) ...[
                          const Spacer(),
                          _statusBadge(_orderStatus, _statusColor(_orderStatus)),
                        ],
                      ],
                    ),
                    if (isDesktop)
                      Text(
                        'Placed on ${_formatDate(o.createdAt ?? '')}',
                        style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF)),
                      ),
                  ],
                ),
              ),
              // Status dropdown + Print buttons
              if (isDesktop) ...[
                _buildCompactStatusDropdown(),
                const SizedBox(width: 10),
                _headerActionBtn(Icons.receipt_long_outlined, 'Print Bill', const Color(0xFFDC2626), _handlePrintBill),
                const SizedBox(width: 8),
                _headerActionBtn(Icons.print_outlined, 'Print KOT', const Color(0xFF374151), _handlePrintKOT),
              ] else ...[
                _headerIconBtn(Icons.print_outlined, _handlePrintBill),
                const SizedBox(width: 6),
                _headerIconBtn(Icons.receipt_long_outlined, _handlePrintKOT),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }

  Widget _headerActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _allStatuses.contains(_orderStatus) ? _orderStatus : 'pending',
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF6B7280)),
          style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
          items: _allStatuses.map((s) {
            return DropdownMenuItem(value: s, child: Text(_capitalize(s)));
          }).toList(),
          onChanged: (val) {
            if (val != null && val != _orderStatus) {
              setState(() => _orderStatus = val);
              context.read<OrdersBloc>().add(UpdateOrderStatus(orderId: widget.order.id!, newStatus: val));
            }
          },
        ),
      ),
    );
  }

  // ─── LAYOUTS ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCompactStatusRow(),
        const SizedBox(height: 16),
        _buildOrderItemsTable(),
        const SizedBox(height: 16),
        _buildRefundHistoryCard(),
        const SizedBox(height: 16),
        if (widget.order.users != null && widget.order.users!.isNotEmpty) ...[
          _buildGuestsCard(),
          const SizedBox(height: 16),
        ],
        _buildOrderStatusCard(),
        const SizedBox(height: 16),
        _buildPaymentInfoCard(),
        const SizedBox(height: 16),
        _buildOrderTimelineCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — items + refund history
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildOrderItemsTable(),
              const SizedBox(height: 20),
              _buildRefundHistoryCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right column — guests, status, payment, actions, timeline
        SizedBox(
          width: 380,
          child: Column(
            children: [
              if (widget.order.users != null && widget.order.users!.isNotEmpty) ...[
                _buildGuestsCard(),
                const SizedBox(height: 16),
              ],
              _buildOrderStatusCard(),
              const SizedBox(height: 16),
              _buildPaymentInfoCard(),
              const SizedBox(height: 16),
              _buildOrderTimelineCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ─── COMPACT STATUS ROW (mobile only) ──────────────────────────────────

  Widget _buildCompactStatusRow() {
    return _card(
      child: Row(
        children: [
          Expanded(child: _buildCompactStatusDropdown()),
          const SizedBox(width: 10),
          _headerActionBtn(Icons.receipt_long_outlined, 'Bill', const Color(0xFFDC2626), _handlePrintBill),
          const SizedBox(width: 6),
          _headerActionBtn(Icons.print_outlined, 'KOT', const Color(0xFF374151), _handlePrintKOT),
        ],
      ),
    );
  }

  // ─── ORDER ITEMS TABLE ──────────────────────────────────────────────────

  Widget _buildOrderItemsTable() {
    final items = widget.order.items ?? [];
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                _iconBox(Icons.shopping_cart_outlined, const Color(0xFFDC2626)),
                const SizedBox(width: 10),
                Text('Order Items (${items.length})', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text('Item', style: _tableHeaderStyle())),
                Expanded(flex: 2, child: Text('Ordered By', style: _tableHeaderStyle())),
                SizedBox(width: 50, child: Text('Qty', style: _tableHeaderStyle(), textAlign: TextAlign.center)),
                SizedBox(width: 70, child: Text('Price', style: _tableHeaderStyle(), textAlign: TextAlign.right)),
                SizedBox(width: 130, child: Text('Status', style: _tableHeaderStyle(), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Table rows
          ...items.asMap().entries.map((entry) => _buildItemRow(entry.value, entry.key, items.length)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item, int index, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: index < total - 1
            ? const Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))
            : null,
      ),
      child: Row(
        children: [
          // Item image + name
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.menuItemData?.image != null && item.menuItemData!.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.menuItemData!.image!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imgPlaceholder(size: 44),
                          errorWidget: (_, __, ___) => _imgPlaceholder(size: 44),
                        )
                      : _imgPlaceholder(size: 44),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuItemData?.title ?? 'Unknown Item',
                        style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.size != null)
                        Text(item.size!, style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF))),
                      if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Note: ${item.specialInstructions}',
                            style: GoogleFonts.sora(fontSize: 10, color: const Color(0xFF3B82F6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ordered By
          Expanded(
            flex: 2,
            child: Text(
              item.orderedBy ?? 'N/A',
              style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Qty
          SizedBox(
            width: 50,
            child: Text(
              'x${item.quantity ?? 1}',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
              textAlign: TextAlign.center,
            ),
          ),
          // Price
          SizedBox(
            width: 70,
            child: Text(
              _formatCurrency(item.price ?? 0),
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
              textAlign: TextAlign.right,
            ),
          ),
          // Status dropdown
          SizedBox(
            width: 130,
            child: _buildItemStatusDropdown(item),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStatusDropdown(OrderItemModel item) {
    final current = item.status ?? 'pending';
    final color = _itemStatusColor(current);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _itemStatuses.contains(current) ? current : 'pending',
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
          style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          items: _itemStatuses.map((s) {
            return DropdownMenuItem(value: s, child: Text(_capitalize(s)));
          }).toList(),
          onChanged: (val) {
            if (val != null && val != current && item.id != null) {
              context.read<OrdersBloc>().add(
                UpdateItemStatus(orderId: widget.order.id!, itemId: item.id!, status: val),
              );
            }
          },
        ),
      ),
    );
  }

  // ─── GUESTS CARD ────────────────────────────────────────────────────────

  Widget _buildGuestsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.people_outline_rounded, const Color(0xFFDC2626)),
              const SizedBox(width: 10),
              Text('Guests at Table', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...widget.order.users!.map(
            (user) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name ?? 'Guest', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500)),
                        if (user.phone != null)
                          Text(user.phone!, style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF))),
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

  // ─── ORDER STATUS CARD ──────────────────────────────────────────────────

  Widget _buildOrderStatusCard() {
    final o = widget.order;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.calendar_today_outlined, const Color(0xFFDC2626)),
              const SizedBox(width: 10),
              Text('Order Status', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _sidebarRow('Status:', _statusBadge(_orderStatus, _statusColor(_orderStatus))),
          const SizedBox(height: 10),
          _sidebarRow('Order Date:', Text(_formatDate(o.createdAt ?? ''), style: GoogleFonts.sora(fontSize: 12))),
          const SizedBox(height: 10),
          _sidebarRow('Last Updated:', Text(_formatDate(o.updatedAt ?? ''), style: GoogleFonts.sora(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _sidebarRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280))),
        value,
      ],
    );
  }

  // ─── PAYMENT INFORMATION CARD ───────────────────────────────────────────

  Widget _buildPaymentInfoCard() {
    final o = widget.order;
    final taxes = (o.cgstAmount ?? 0) + (o.sgstAmount ?? 0);
    final amountDue = (o.totalAmount ?? 0) - (o.amountPaid ?? 0);
    final refundable = (o.amountPaid ?? 0) - (o.amountRefunded ?? 0);

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final isProcessing = state is RefundProcessing ||
            state is ManualPaymentProcessing ||
            state is MarkCompleteProcessing;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconBox(Icons.credit_card_outlined, const Color(0xFFDC2626)),
                  const SizedBox(width: 10),
                  Text('Payment Information', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              // Payment method & status
              _sidebarRow('Payment Method:', Text(_capitalize(o.paymentMethod ?? 'N/A'), style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600))),
              const SizedBox(height: 10),
              _sidebarRow('Payment Status:', _paymentStatusBadge(o.paymentStatus)),
              if (o.paymentId != null) ...[
                const SizedBox(height: 10),
                _sidebarRow('Payment ID:', Text(o.paymentId!, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
              ],
              // Breakdown
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFE5E7EB))),
              _payRow('Subtotal:', o.subtotal ?? 0),
              _payRow('Taxes (CGST+SGST):', taxes),
              _payRow('Service Charge:', o.serviceCharge ?? 0),
              _payRow('Discount:', -(o.discountAmount ?? 0), color: const Color(0xFFDC2626)),
              if ((o.offerDiscount ?? 0) > 0)
                _payRow('Offer Discount:', -(o.offerDiscount ?? 0), color: const Color(0xFFDC2626)),
              // Totals
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFE5E7EB))),
              _payRow('Total Amount:', o.totalAmount ?? 0, bold: true, color: const Color(0xFFDC2626), size: 16),
              const SizedBox(height: 4),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              _payRow('Amount Paid:', o.amountPaid ?? 0, bold: true, color: const Color(0xFF16A34A), size: 16),
              const SizedBox(height: 4),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              _payRow('Amount Due:', amountDue, bold: true, color: const Color(0xFFEA580C), size: 16),
              const SizedBox(height: 4),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              _payRow('Amount Refunded:', o.amountRefunded ?? 0, bold: true, color: const Color(0xFFDC2626), size: 16),

              // ── Refund Section ──
              if (refundable > 0) ...[
                const SizedBox(height: 20),
                Text('Refund', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _styledInput(_refundAmountCtrl, 'Refund amount', isProcessing, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    _buildRefundMethodDropdown(),
                  ],
                ),
                const SizedBox(height: 8),
                _styledInput(_refundReasonCtrl, 'Reason (optional)', isProcessing),
                const SizedBox(height: 6),
                Text(
                  'Refundable remaining: ${_formatCurrency(refundable)}',
                  style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _handleRefund,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(isProcessing ? 'Processing...' : 'Process Refund', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],

              // ── Manual Payment Section ──
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _styledInput(_manualPaymentCtrl, 'Enter amount', isProcessing, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _handleManualPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(isProcessing ? 'Recording...' : 'Record Manual Payment', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),

              // ── Mark Complete Button ──
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: (isProcessing || amountDue > 0) ? null : _handleMarkComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    disabledBackgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    isProcessing ? 'Completing...' : 'Mark as Completed & Paid',
                    style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundMethodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _refundMethod,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF6B7280)),
          style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF374151)),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'razorpay', child: Text('Razorpay')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _refundMethod = val);
          },
        ),
      ),
    );
  }

  Widget _styledInput(TextEditingController ctrl, String hint, bool disabled, {TextInputType? keyboardType}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: ctrl,
        enabled: !disabled,
        keyboardType: keyboardType,
        style: GoogleFonts.sora(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _paymentStatusBadge(String? status) {
    Color bg, fg;
    switch (status?.toLowerCase()) {
      case 'paid':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case 'partially-paid':
      case 'partial':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF3B82F6);
        break;
      case 'failed':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFF59E0B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(_capitalize(status ?? 'N/A'), style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _payRow(String label, num amount, {bool bold = false, Color? color, double size = 13}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: bold ? size : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? (color ?? const Color(0xFF111827)) : const Color(0xFF6B7280),
            ),
          ),
          Text(
            '${amount < 0 ? '- ' : ''}${_formatCurrency(amount.abs())}',
            style: GoogleFonts.sora(
              fontSize: bold ? size : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  // ─── REFUND HISTORY ───────────────────────────────────────────────────

  Widget _buildRefundHistoryCard() {
    final refunds = widget.order.refunds ?? [];
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Text('Refund History', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          if (refunds.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('No refunds yet.', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF9CA3AF))),
            )
          else ...[
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB)), bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Date', style: _tableHeaderStyle())),
                  Expanded(flex: 2, child: Text('Method', style: _tableHeaderStyle())),
                  Expanded(flex: 2, child: Text('Amount', style: _tableHeaderStyle())),
                  Expanded(flex: 2, child: Text('Reason', style: _tableHeaderStyle())),
                ],
              ),
            ),
            ...refunds.map((r) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(_formatDate(r.createdAt ?? ''), style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF6B7280)))),
                      Expanded(flex: 2, child: Text(_capitalize(r.method ?? 'N/A'), style: GoogleFonts.sora(fontSize: 12))),
                      Expanded(flex: 2, child: Text(_formatCurrency(r.amount ?? 0), style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)))),
                      Expanded(flex: 2, child: Text(r.reason ?? '-', style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF6B7280)), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ─── ORDER TIMELINE CARD ────────────────────────────────────────────────

  Widget _buildOrderTimelineCard() {
    final o = widget.order;
    final status = _orderStatus.toLowerCase();

    final List<_TimelineEntry> entries = [
      _TimelineEntry('Order Placed', _formatDate(o.createdAt ?? ''), const Color(0xFFDC2626)),
    ];

    if (status != 'pending' && status != 'cancelled') {
      entries.add(_TimelineEntry('Order Confirmed', 'Processing started', const Color(0xFF3B82F6)));
    }

    if (status == 'preparing' || status == 'ready' || status == 'served' || status == 'completed') {
      entries.add(_TimelineEntry('Preparing', 'Kitchen is preparing the order', const Color(0xFF8B5CF6)));
    }

    if (status == 'ready' || status == 'served' || status == 'completed') {
      entries.add(_TimelineEntry('Ready', 'Order is ready for serving', const Color(0xFF06B6D4)));
    }

    if (status == 'served' || status == 'completed') {
      entries.add(_TimelineEntry('Served', 'Order has been served', const Color(0xFF16A34A)));
    }

    if (status == 'completed') {
      entries.add(_TimelineEntry('Completed', _formatDate(o.updatedAt ?? ''), const Color(0xFF16A34A)));
    }

    if (status == 'cancelled') {
      entries.add(_TimelineEntry('Order Cancelled', _formatDate(o.updatedAt ?? ''), const Color(0xFFDC2626)));
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Timeline', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((e) {
            final entry = e.value;
            final isLast = e.key == entries.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 28,
                          color: const Color(0xFFE5E7EB),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(entry.subtitle, style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───────────────────────────────────────────────────

  TextStyle _tableHeaderStyle() => GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280));

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 20, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _pill(String text, {Color color = const Color(0xFFF3F4F6)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _capitalize(text),
        style: GoogleFonts.sora(fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _imgPlaceholder({double size = 56}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.restaurant, size: size * 0.43, color: const Color(0xFFD1D5DB)),
      );

  // ─── COLORS / HELPERS ─────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'preparing':
        return const Color(0xFF8B5CF6);
      case 'ready':
        return const Color(0xFF06B6D4);
      case 'served':
      case 'completed':
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _itemStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'preparing':
        return const Color(0xFF8B5CF6);
      case 'served':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ─── HANDLERS ─────────────────────────────────────────────────────────

  void _handlePrintBill() => _printHtml(_buildBillHtml());
  void _handlePrintKOT() => _printHtml(_buildKotHtml());
  void _printHtml(String htmlContent) => printHtmlContent(htmlContent);

  void _handleRefund() {
    final amount = double.tryParse(_refundAmountCtrl.text) ?? 0;
    if (amount <= 0) {
      _showSnack('Please enter a valid refund amount', Colors.red[600]!);
      return;
    }
    context.read<OrdersBloc>().add(
      ProcessRefund(
        orderId: widget.order.id!,
        amount: amount,
        method: _refundMethod,
        reason: _refundReasonCtrl.text.isNotEmpty ? _refundReasonCtrl.text : null,
      ),
    );
  }

  void _handleManualPayment() {
    final amount = double.tryParse(_manualPaymentCtrl.text) ?? 0;
    if (amount <= 0) {
      _showSnack('Please enter a valid payment amount', Colors.red[600]!);
      return;
    }
    context.read<OrdersBloc>().add(
      RecordManualPayment(orderId: widget.order.id!, amount: amount),
    );
  }

  void _handleMarkComplete() => context.read<OrdersBloc>().add(
        MarkOrderComplete(orderId: widget.order.id!),
      );

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.sora(fontSize: 13)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatCurrency(num amount) => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 0,
        locale: 'en_IN',
      ).format(amount);

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMMM yyyy \'at\' hh:mm:ss a').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  String _getShortOrderId() {
    final orderId = widget.order.id ?? 'N/A';
    return orderId.length > 8 ? orderId.substring(orderId.length - 8) : orderId;
  }

  // ─── PRINT HTML BUILDERS ──────────────────────────────────────────────

  String _buildBillHtml() {
    final o = widget.order;
    final hotelName = o.hotel?.name ?? 'Restaurant';
    final orderIdShort = '#${_getShortOrderId()}';
    final created = _formatDate(o.createdAt ?? '');
    final table = o.tableNumber != null ? 'Table: ${o.tableNumber}' : '';

    final itemLines = (o.items ?? []).map((it) {
      final name = it.menuItemData?.title ?? 'Item';
      final qty = 'x${it.quantity ?? 1}';
      final price = (it.price ?? 0).toStringAsFixed(0);
      final size = it.size != null ? ' (${it.size})' : '';
      final pad = (32 - '$name$size $qty'.length - price.length).clamp(1, 32);
      return '$name$size $qty${' ' * pad}$price';
    }).join('\n');

    final sub = (o.subtotal ?? 0).toStringAsFixed(0);
    final cgst = (o.cgstAmount ?? 0).toStringAsFixed(0);
    final sgst = (o.sgstAmount ?? 0).toStringAsFixed(0);
    final svc = (o.serviceCharge ?? 0).toStringAsFixed(0);
    final disc = (o.discountAmount ?? 0).toStringAsFixed(0);
    final total = (o.totalAmount ?? 0).toStringAsFixed(0);
    final paid = (o.amountPaid ?? 0).toStringAsFixed(0);
    final due = ((o.totalAmount ?? 0) - (o.amountPaid ?? 0)).toStringAsFixed(0);
    final payMethod = (o.paymentMethod ?? '-').toUpperCase();

    return '''<!doctype html>
<html><head><meta charset="utf-8"/>
<title>Bill $orderIdShort</title>
<style>
@page{size:80mm auto;margin:0}
body{width:80mm;margin:0;font-family:monospace;font-size:12px;color:#000}
.wrap{padding:8px}.center{text-align:center}.bold{font-weight:700}
.line{border-top:1px dashed #000;margin:6px 0}pre{white-space:pre-wrap;word-break:break-word}
</style></head><body><div class="wrap">
<div class="center bold">$hotelName</div>
<div class="center">Bill $orderIdShort</div>
<div class="center">$created${table.isNotEmpty ? ' • $table' : ''}</div>
<div class="line"></div>
<pre>$itemLines</pre>
<div class="line"></div>
<pre>
Subtotal${' ' * (24 - 'Subtotal'.length)}$sub
CGST${' ' * (24 - 'CGST'.length)}$cgst
SGST${' ' * (24 - 'SGST'.length)}$sgst
Service${' ' * (24 - 'Service'.length)}$svc
${disc != '0' ? 'Discount${' ' * (24 - 'Discount'.length)}-$disc\n' : ''}Total${' ' * (24 - 'Total'.length)}$total
Paid${' ' * (24 - 'Paid'.length)}$paid
Due${' ' * (24 - 'Due'.length)}$due
Payment${' ' * (24 - 'Payment'.length)}$payMethod
</pre>
<div class="line"></div>
<div class="center">Thank you! Visit again.</div>
</div></body></html>''';
  }

  String _buildKotHtml() {
    final o = widget.order;
    final hotelName = o.hotel?.name ?? 'Restaurant';
    final orderIdShort = '#${_getShortOrderId()}';
    final created = _formatDate(o.createdAt ?? '');
    final table = o.tableNumber != null ? 'Table: ${o.tableNumber}' : '';

    final itemLines = (o.items ?? []).map((it) {
      final name = it.menuItemData?.title ?? 'Item';
      final qty = 'x${it.quantity ?? 1}';
      final size = it.size != null ? ' (${it.size})' : '';
      final note = it.specialInstructions != null && it.specialInstructions!.isNotEmpty
          ? '\n  Note: ${it.specialInstructions}'
          : '';
      return '$name$size  $qty$note';
    }).join('\n');

    return '''<!doctype html>
<html><head><meta charset="utf-8"/>
<title>KOT $orderIdShort</title>
<style>
@page{size:80mm auto;margin:0}
body{width:80mm;margin:0;font-family:monospace;font-size:12px;color:#000}
.wrap{padding:8px}.center{text-align:center}.bold{font-weight:700}
.line{border-top:1px dashed #000;margin:6px 0}pre{white-space:pre-wrap;word-break:break-word}
</style></head><body><div class="wrap">
<div class="center bold">KITCHEN ORDER TICKET (KOT)</div>
<div class="center">$hotelName${table.isNotEmpty ? ' • $table' : ''}</div>
<div class="center">Order $orderIdShort • $created</div>
<div class="line"></div>
<pre>$itemLines</pre>
<div class="line"></div>
</div></body></html>''';
  }
}

class _TimelineEntry {
  final String title;
  final String subtitle;
  final Color color;
  const _TimelineEntry(this.title, this.subtitle, this.color);
}
