import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/delivery_partner_models.dart';
import '../bloc/delivery_partner_bloc.dart';
import '../bloc/delivery_partner_event.dart';
import '../dialogs/partner_settings_dialog.dart';

class DeliveryPartnerCard extends StatefulWidget {
  final DeliveryPartner partner;

  const DeliveryPartnerCard({super.key, required this.partner});

  @override
  State<DeliveryPartnerCard> createState() => _DeliveryPartnerCardState();
}

class _DeliveryPartnerCardState extends State<DeliveryPartnerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFDC2626).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.partner.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.partner.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.partner.status == 'active'
                                    ? const Color(0xFFECFDF5)
                                    : widget.partner.status == 'pending'
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.partner.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.partner.status == 'active'
                                      ? const Color(0xFF059669)
                                      : widget.partner.status == 'pending'
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.partner.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings Icon
                  IconButton(
                    onPressed: () => _showSettingsDialog(context),
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    color: const Color(0xFF9CA3AF),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Toggle Switch
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: widget.partner.status == 'active',
                      onChanged: (value) {
                        context.read<DeliveryPartnerBloc>().add(
                          TogglePartnerStatus(widget.partner.id, value),
                        );
                      },
                      activeColor: const Color(0xFFDC2626),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Cost',
                      '₹${widget.partner.costPerKm}/km',
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Avg Time',
                      '${widget.partner.avgTimeMinutes} min',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'SLA Score',
                      '${widget.partner.slaScore.toStringAsFixed(0)}%',
                      color: const Color(0xFF059669),
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Active Riders',
                      widget.partner.activeRiders.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 8),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Coverage: ${widget.partner.coverage}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatNumber(widget.partner.totalDeliveries)} deliveries',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.partner.apiStatus == 'connected'
                          ? const Color(0xFF059669)
                          : widget.partner.apiStatus == 'error'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.partner.apiStatus == 'connected'
                        ? 'Connected'
                        : widget.partner.apiStatus == 'error'
                        ? 'API Error'
                        : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.partner.apiStatus == 'connected'
                          ? const Color(0xFF059669)
                          : widget.partner.apiStatus == 'error'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DeliveryPartnerBloc>(),
        child: PartnerSettingsDialog(partner: widget.partner),
      ),
    );
  }
}
