import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/widgets/app_snackbar.dart';

class KitchenConfigManagement extends StatefulWidget {
  final String hotelId;

  const KitchenConfigManagement({super.key, required this.hotelId});

  @override
  State<KitchenConfigManagement> createState() => _KitchenConfigManagementState();
}

class _KitchenConfigManagementState extends State<KitchenConfigManagement> {
  static const _primaryColor = Color(0xFFC52031);

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _config;

  late TextEditingController _defaultPrepTime;
  late TextEditingController _bufferTime;
  late TextEditingController _closingBuffer;
  late TextEditingController _slotDuration;
  late TextEditingController _maxOrders;

  bool _loadBalancing = true;
  bool _autoSlot = true;
  bool _priorityQueue = true;
  bool _autoDisable = true;

  @override
  void initState() {
    super.initState();
    _defaultPrepTime = TextEditingController();
    _bufferTime = TextEditingController();
    _closingBuffer = TextEditingController();
    _slotDuration = TextEditingController();
    _maxOrders = TextEditingController();
    _loadConfig();
  }

  @override
  void dispose() {
    _defaultPrepTime.dispose();
    _bufferTime.dispose();
    _closingBuffer.dispose();
    _slotDuration.dispose();
    _maxOrders.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenConfiguration(widget.hotelId),
      type: RequestType.get,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _config = response.data['data'];
      _defaultPrepTime.text = '${_config?['defaultPrepTimeMinutes'] ?? 15}';
      _bufferTime.text = '${_config?['bufferTimeMinutes'] ?? 5}';
      _closingBuffer.text = '${_config?['closingTimeBufferMinutes'] ?? 30}';
      _slotDuration.text = '${_config?['slotDurationMinutes'] ?? 15}';
      _maxOrders.text = '${_config?['maxOrdersPerSlot'] ?? 5}';
      _loadBalancing = _config?['enableKitchenLoadBalancing'] ?? true;
      _autoSlot = _config?['enableAutoSlotSuggestion'] ?? true;
      _priorityQueue = _config?['enablePriorityQueue'] ?? true;
      _autoDisable = _config?['autoDisableHighComplexityOnOverload'] ?? true;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenConfiguration(widget.hotelId),
      type: RequestType.put,
      params: {
        'hotelId': widget.hotelId,
        'defaultPrepTimeMinutes': int.tryParse(_defaultPrepTime.text) ?? 15,
        'bufferTimeMinutes': int.tryParse(_bufferTime.text) ?? 5,
        'closingTimeBufferMinutes': int.tryParse(_closingBuffer.text) ?? 30,
        'slotDurationMinutes': int.tryParse(_slotDuration.text) ?? 15,
        'maxOrdersPerSlot': int.tryParse(_maxOrders.text) ?? 5,
        'enableKitchenLoadBalancing': _loadBalancing,
        'enableAutoSlotSuggestion': _autoSlot,
        'enablePriorityQueue': _priorityQueue,
        'autoDisableHighComplexityOnOverload': _autoDisable,
      },
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      AppSnackbar.success(context, 'Configuration saved successfully');
      await _loadConfig();
    } else {
      AppSnackbar.error(context, 'Failed to save configuration');
    }
    setState(() => _isSaving = false);
  }

  Future<void> _resetConfig() async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenConfigurationReset(widget.hotelId),
      type: RequestType.post,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      AppSnackbar.success(context, 'Configuration reset to defaults');
      await _loadConfig();
    } else {
      AppSnackbar.error(context, 'Failed to reset configuration');
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadConfig,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection('Timing Settings', Icons.schedule, [
              _buildField('Default Prep Time (min)', _defaultPrepTime),
              _buildField('Buffer Time (min)', _bufferTime),
              _buildField('Closing Time Buffer (min)', _closingBuffer),
            ]),
            const SizedBox(height: 20),
            _buildSection('Slot Settings', Icons.view_module, [
              _buildField('Slot Duration (min)', _slotDuration),
              _buildField('Max Orders Per Slot', _maxOrders),
            ]),
            const SizedBox(height: 20),
            _buildSection('Feature Flags', Icons.toggle_on_outlined, [
              _buildToggle('Kitchen Load Balancing', 'Distribute orders across stations evenly', _loadBalancing, (v) => setState(() => _loadBalancing = v)),
              _buildToggle('Auto Slot Suggestion', 'Suggest optimal time slots for orders', _autoSlot, (v) => setState(() => _autoSlot = v)),
              _buildToggle('Priority Queue', 'Prioritize urgent orders automatically', _priorityQueue, (v) => setState(() => _priorityQueue = v)),
              _buildToggle('Auto-disable Complex Items', 'Disable complex items when overloaded', _autoDisable, (v) => setState(() => _autoDisable = v)),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isSaving ? 'Saving...' : 'Save Configuration', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kitchen Configuration', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
            const SizedBox(height: 4),
            Text('Customize timing and feature settings', style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF6B7280))),
          ],
        ),
        TextButton.icon(
          onPressed: _isSaving ? null : _resetConfig,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(_isSaving ? 'Resetting...' : 'Reset Defaults'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: _primaryColor),
            ),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
          ]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.sora(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryColor)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _primaryColor),
        ],
      ),
    );
  }
}
