import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class IntegrationsTab extends StatelessWidget {
  const IntegrationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDetailsBloc, RestaurantDetailsState>(
      builder: (context, state) {
        if (state is! RestaurantDetailsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final integrations = state.integrationsData;
        final apiKey = integrations['apiKey'] as String;
        final webhooks = integrations['webhooks'] as List<dynamic>;
        final logs = integrations['logs'] as List<dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('API Keys'),
            const SizedBox(height: 16),
            _buildApiKeyCard(context, apiKey),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Webhooks'),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.addWebhook.path),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Add Webhook'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWebhooksTable(webhooks),
            const SizedBox(height: 32),
            _buildSectionHeader('Recent API Logs'),
            const SizedBox(height: 16),
            _buildLogsTable(logs),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AirMenuTextStyle.headingH4.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildApiKeyCard(BuildContext context, String apiKey) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.vpn_key, color: Color(0xFFC52031)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Production API Key',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apiKey,
                  style: AirMenuTextStyle.small.copyWith(
                    fontFamily: 'Monospace',
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: apiKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Rotate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhooksTable(List<dynamic> webhooks) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'EVENT',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'URL',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'LAST TRIGGERED',
                    textAlign: TextAlign.right,
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ...webhooks.map((webhook) => _buildWebhookRow(webhook)),
        ],
      ),
    );
  }

  Widget _buildWebhookRow(Map<String, dynamic> webhook) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              webhook['event'],
              style: AirMenuTextStyle.small.copyWith(
                fontFamily: 'Monospace',
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              webhook['url'],
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Active',
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              webhook['lastTriggered'],
              textAlign: TextAlign.right,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTable(List<dynamic> logs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'TIME',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'EVENT',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'DURATION',
                    textAlign: TextAlign.right,
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ...logs.map((log) => _buildLogRow(log)),
        ],
      ),
    );
  }

  Widget _buildLogRow(Map<String, dynamic> log) {
    final status = log['status'] as String;
    final isSuccess = status == 'Success';
    final statusColor = isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final statusBg = isSuccess
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFFEE2E2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              log['time'],
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              log['event'],
              style: AirMenuTextStyle.small.copyWith(
                fontFamily: 'Monospace',
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: AirMenuTextStyle.small.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              log['duration'],
              textAlign: TextAlign.right,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
