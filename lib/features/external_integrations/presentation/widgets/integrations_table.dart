import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/external_integration_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/external_integrations_bloc.dart';

class IntegrationsTable extends StatelessWidget {
  final List<IntegrationPartner> partners;

  const IntegrationsTable({super.key, required this.partners});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          ...partners.map((p) => _buildRow(context, p)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell('PARTNER')),
          Expanded(flex: 2, child: _buildHeaderCell('TYPE')),
          Expanded(flex: 1, child: _buildHeaderCell('SLA %', showSort: true)),
          Expanded(
            flex: 2,
            child: _buildHeaderCell('AVG TIME', showSort: true),
          ),
          Expanded(flex: 1, child: _buildHeaderCell('SUCCESS', showSort: true)),
          Expanded(flex: 1, child: _buildHeaderCell('FAILURE', showSort: true)),
          Expanded(flex: 2, child: _buildHeaderCell('COST/KM')),
          Expanded(flex: 2, child: _buildHeaderCell('STATUS')),
          Expanded(
            flex: 2,
            child: _buildHeaderCell('ACTION', align: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, IntegrationPartner partner) {
    return InkWell(
      onTap: () {
        context.read<ExternalIntegrationsBloc>().add(
          SelectIntegrationPartner(partner),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
        ),
        child: Row(
          children: [
            // Partner
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      partner.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name,
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          partner.restaurantsLinked,
                          style: AirMenuTextStyle.caption.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Type
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: partner.type == 'Internal'
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    partner.type,
                    style: AirMenuTextStyle.caption.copyWith(
                      color: partner.type == 'Internal'
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF374151),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Metrics
            Expanded(
              flex: 1,
              child: _buildMetricText(
                '${partner.sla}%',
                const Color(
                  0xFF059669,
                ), // Green matching screenshot roughly or logic? Screenshot shows green 94%, orange 89%, red 78%
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildMetricText(partner.avgTime, const Color(0xFF6B7280)),
            ),
            Expanded(
              flex: 1,
              child: _buildMetricText(
                '${partner.successRate}%',
                const Color(0xFF059669),
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildMetricText(
                '${partner.failureRate}%',
                const Color(
                  0xFF6B7280,
                ), // Screenshot shows 3.5% grey/black? No, let's keep it specific
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildMetricText(
                '₹${partner.costPerKm}',
                const Color(0xFF111827),
              ),
            ),
            // Status
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: partner.status == 'active'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: partner.status == 'active'
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: partner.status == 'active'
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        partner.status,
                        style: AirMenuTextStyle.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: partner.status == 'active'
                              ? const Color(0xFF047857)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<ExternalIntegrationsBloc>().add(
                      SelectIntegrationPartner(partner),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined, size: 14),
                  label: const Text('Configure'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    TextAlign align = TextAlign.left,
    bool showSort = false,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align == TextAlign.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: align == TextAlign.right
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: align,
            style: AirMenuTextStyle.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          if (showSort) ...[
            const SizedBox(width: 4),
            const Icon(Icons.swap_vert, size: 14, color: Color(0xFFD1D5DB)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricText(String text, Color color) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AirMenuTextStyle.small.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
