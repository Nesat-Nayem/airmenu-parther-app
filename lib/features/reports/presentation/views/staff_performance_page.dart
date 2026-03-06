import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Staff Performance Report Detail Page - With hover effects
class StaffPerformancePage extends StatefulWidget {
  const StaffPerformancePage({super.key});

  @override
  State<StaffPerformancePage> createState() => _StaffPerformancePageState();
}

class _StaffPerformancePageState extends State<StaffPerformancePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _staffList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: '/staff',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> staff = data['data'] is List ? data['data'] : [];
          setState(() {
            _staffList = staff.map((s) => s as Map<String, dynamic>).toList();
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading staff: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Staff Performance',
      subtitle: 'Orders handled and service metrics',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStaffTable(),
    );
  }

  Widget _buildStaffTable() {
    if (_staffList.isEmpty) {
      return HoverCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No staff members found',
            style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
          ),
        ),
      );
    }

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Staff',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Role',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Phone',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._staffList.map(
            (staff) {
              final name = staff['name'] ?? 'Unknown';
              final role = staff['role'] ?? 'Staff';
              final isActive = staff['isActive'] ?? true;
              final phone = staff['phone'] ?? '-';

              return HoverTableRow(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        name,
                        style: AirMenuTextStyle.normal.bold600().withColor(
                          Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        role.toString().replaceFirst(role.toString()[0], role.toString()[0].toUpperCase()),
                        style: AirMenuTextStyle.normal.withColor(
                          Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: AirMenuTextStyle.small.bold600().withColor(
                                isActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        phone,
                        style: AirMenuTextStyle.normal.withColor(
                          Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
