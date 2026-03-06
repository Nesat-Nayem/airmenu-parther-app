import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/widgets/app_snackbar.dart';

class KitchenStationManagement extends StatefulWidget {
  final String hotelId;
  final VoidCallback? onStationsChanged;

  const KitchenStationManagement({
    super.key,
    required this.hotelId,
    this.onStationsChanged,
  });

  @override
  State<KitchenStationManagement> createState() =>
      _KitchenStationManagementState();
}

class _KitchenStationManagementState extends State<KitchenStationManagement> {
  static const _primaryColor = Color(0xFFC52031);

  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _stations = [];
  Map<String, dynamic>? _kitchenStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadStations(), _loadStatus()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadStations() async {
    final response = await locator<ApiService>().invoke(
      urlPath: '${ApiEndpoints.kitchenStations(widget.hotelId)}?includeInactive=true',
      type: RequestType.get,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      setState(() {
        _stations = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      });
    }
  }

  Future<void> _loadStatus() async {
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenStatus(widget.hotelId),
      type: RequestType.get,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      setState(() => _kitchenStatus = response.data['data']);
    }
  }

  Future<void> _initializeStations() async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenInitialize(widget.hotelId),
      type: RequestType.post,
      params: {'useDefaults': true},
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _showToast('Stations initialized successfully');
      await _loadData();
      widget.onStationsChanged?.call();
    } else {
      _showToast('Failed to initialize stations', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _createStation(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenStations(widget.hotelId),
      type: RequestType.post,
      params: data,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _showToast('Station created successfully');
      await _loadStations();
      widget.onStationsChanged?.call();
    } else {
      _showToast('Failed to create station', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _updateStation(String stationId, Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenStation(stationId),
      type: RequestType.put,
      params: data,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _showToast('Station updated successfully');
      await _loadStations();
      widget.onStationsChanged?.call();
    } else {
      _showToast('Failed to update station', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _deleteStation(String stationId) async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenStation(stationId),
      type: RequestType.delete,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _showToast('Station deleted successfully');
      await _loadStations();
      widget.onStationsChanged?.call();
    } else {
      _showToast('Failed to delete station', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _adjustSlots(String stationId, int slots, String reason) async {
    setState(() => _isSaving = true);
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenStationAdjust(stationId),
      type: RequestType.put,
      params: {'parallelSlots': slots, 'reason': reason},
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      _showToast('Slots adjusted successfully');
      await _loadStations();
    } else {
      _showToast('Failed to adjust slots', isError: true);
    }
    setState(() => _isSaving = false);
  }

  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      AppSnackbar.error(context, message);
    } else {
      AppSnackbar.success(context, message);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NORMAL': return const Color(0xFF10B981);
      case 'BUSY': return const Color(0xFFF59E0B);
      case 'OVERLOADED': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'NORMAL': return const Color(0xFFD1FAE5);
      case 'BUSY': return const Color(0xFFFEF3C7);
      case 'OVERLOADED': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFF3F4F6);
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4ECDC4);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_stations.isEmpty)
              _buildEmptyState()
            else
              _buildStationsGrid(),
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
            Text(
              'Kitchen Stations',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_stations.length} stations configured',
              style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
        Row(
          children: [
            if (_stations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _initializeStations,
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: Text(_isSaving ? 'Setting up...' : 'Auto Setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _showAddStationModal,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Station'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.kitchen_outlined, size: 40, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 20),
          Text(
            'No Kitchen Stations',
            style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your kitchen stations to manage orders efficiently.\nUse Auto Setup for default stations or add custom ones.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 900 ? 2 : 3);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.35,
          ),
          itemCount: _stations.length,
          itemBuilder: (context, index) => _buildStationCard(_stations[index]),
        );
      },
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    final isActive = station['isActive'] ?? true;
    final color = _parseColor(station['color'] ?? '#4ECDC4');
    final statusData = _kitchenStatus?['stations']?.firstWhere(
      (s) => s['stationId'] == station['_id'],
      orElse: () => null,
    );
    final status = statusData?['status'] ?? 'NORMAL';
    final loadMinutes = statusData?['currentLoadMinutes'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    station['name'] ?? '',
                    style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getStatusBgColor(status), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w600, color: _getStatusColor(status))),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.code, 'Code', station['code'] ?? '-'),
            _buildInfoRow(Icons.layers, 'Slots', '${station['parallelSlots'] ?? 0}'),
            _buildInfoRow(Icons.timer_outlined, 'Load', '$loadMinutes min'),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (loadMinutes / 60).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(_getStatusColor(status).withOpacity(0.6)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAction(Icons.edit_outlined, 'Edit', const Color(0xFF6B7280), () => _showEditStationModal(station))),
                const SizedBox(width: 8),
                Expanded(child: _buildAction(Icons.tune, 'Adjust', const Color(0xFF3B82F6), () => _showAdjustSlotsModal(station))),
                const SizedBox(width: 8),
                Expanded(child: _buildAction(Icons.delete_outline, 'Delete', const Color(0xFFEF4444), () => _confirmDeleteStation(station))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Text('$label: ', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280))),
          Text(value, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  void _showAddStationModal() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final slotsCtrl = TextEditingController(text: '3');
    final softCtrl = TextEditingController(text: '20');
    final hardCtrl = TextEditingController(text: '40');
    Color selectedColor = const Color(0xFF4ECDC4);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Kitchen Station', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Station Name', nameCtrl, 'e.g., Grill Station'),
                _buildField('Code (unique)', codeCtrl, 'e.g., grill'),
                _buildField('Parallel Slots', slotsCtrl, '', isNumber: true),
                Row(children: [
                  Expanded(child: _buildField('Soft Limit (min)', softCtrl, '', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Hard Limit (min)', hardCtrl, '', isNumber: true)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Color: ', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final c = await _showColorPicker(selectedColor);
                      if (c != null) setModalState(() => selectedColor = c);
                    },
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300))),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.sora(color: const Color(0xFF6B7280)))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _createStation({
                  'hotelId': widget.hotelId,
                  'name': nameCtrl.text,
                  'code': codeCtrl.text.toLowerCase().replaceAll(' ', '_'),
                  'parallelSlots': int.tryParse(slotsCtrl.text) ?? 3,
                  'softMaxBusyMinutes': int.tryParse(softCtrl.text) ?? 20,
                  'hardMaxBusyMinutes': int.tryParse(hardCtrl.text) ?? 40,
                  'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Create', style: GoogleFonts.sora()),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStationModal(Map<String, dynamic> station) {
    final nameCtrl = TextEditingController(text: station['name']);
    final slotsCtrl = TextEditingController(text: '${station['parallelSlots'] ?? 3}');
    final softCtrl = TextEditingController(text: '${station['softMaxBusyMinutes'] ?? 20}');
    final hardCtrl = TextEditingController(text: '${station['hardMaxBusyMinutes'] ?? 40}');
    Color selectedColor = _parseColor(station['color'] ?? '#4ECDC4');
    bool isActive = station['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Station', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Station Name', nameCtrl, ''),
                _buildField('Parallel Slots', slotsCtrl, '', isNumber: true),
                Row(children: [
                  Expanded(child: _buildField('Soft Limit (min)', softCtrl, '', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Hard Limit (min)', hardCtrl, '', isNumber: true)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Color: ', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final c = await _showColorPicker(selectedColor);
                      if (c != null) setModalState(() => selectedColor = c);
                    },
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300))),
                  ),
                ]),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isActive,
                  onChanged: (v) => setModalState(() => isActive = v),
                  title: Text('Station Active', style: GoogleFonts.sora(fontSize: 14)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.sora(color: const Color(0xFF6B7280)))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStation(station['_id'], {
                  'name': nameCtrl.text,
                  'parallelSlots': int.tryParse(slotsCtrl.text) ?? 3,
                  'softMaxBusyMinutes': int.tryParse(softCtrl.text) ?? 20,
                  'hardMaxBusyMinutes': int.tryParse(hardCtrl.text) ?? 40,
                  'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                  'isActive': isActive,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Save', style: GoogleFonts.sora()),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustSlotsModal(Map<String, dynamic> station) {
    final slotsCtrl = TextEditingController(text: '${station['parallelSlots'] ?? 3}');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Adjust Slots: ${station['name']}', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temporarily adjust capacity (e.g., staff shortage).', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF6B7280))),
            const SizedBox(height: 16),
            _buildField('New Parallel Slots', slotsCtrl, '', isNumber: true),
            _buildField('Reason (optional)', reasonCtrl, 'e.g., Staff shortage'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.sora(color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _adjustSlots(station['_id'], int.tryParse(slotsCtrl.text) ?? station['parallelSlots'], reasonCtrl.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Adjust', style: GoogleFonts.sora()),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStation(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Station', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${station['name']}"?', style: GoogleFonts.sora(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.sora(color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteStation(station['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Delete', style: GoogleFonts.sora()),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.sora(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(Color initialColor) async {
    final colors = [
      const Color(0xFFFF6B35), const Color(0xFF4ECDC4), const Color(0xFF45B7D1),
      const Color(0xFFF7DC6F), const Color(0xFFBB8FCE), const Color(0xFF58D68D),
      const Color(0xFFE74C3C), const Color(0xFF3498DB), const Color(0xFF9B59B6),
    ];
    return showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Color', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) => GestureDetector(
            onTap: () => Navigator.pop(ctx, c),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: c == initialColor ? Colors.black : Colors.transparent, width: 2)),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
