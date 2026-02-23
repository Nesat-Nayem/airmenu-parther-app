import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class KitchenTab extends StatefulWidget {
  final String hotelId;

  const KitchenTab({super.key, required this.hotelId});

  @override
  State<KitchenTab> createState() => _KitchenTabState();
}

class _KitchenTabState extends State<KitchenTab> {
  static const _primaryColor = Color(0xFFC52031);
  
  String _activeSection = 'dashboard';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  List<Map<String, dynamic>> _stations = [];
  Map<String, dynamic>? _config;
  Map<String, dynamic>? _kitchenStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await Future.wait([
        _loadStations(),
        _loadConfig(),
        _loadStatus(),
      ]);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

  Future<void> _loadConfig() async {
    final response = await locator<ApiService>().invoke(
      urlPath: ApiEndpoints.kitchenConfiguration(widget.hotelId),
      type: RequestType.get,
      fun: (data) => jsonDecode(data),
    );
    if (response is DataSuccess && response.data['success'] == true) {
      setState(() => _config = response.data['data']);
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
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenInitialize(widget.hotelId),
        type: RequestType.post,
        params: {'useDefaults': true},
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Stations initialized successfully');
        await _loadStations();
        await _loadStatus();
      } else {
        _showToast('Failed to initialize stations', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _createStation(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenStations(widget.hotelId),
        type: RequestType.post,
        params: data,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Station created successfully');
        await _loadStations();
      } else {
        _showToast('Failed to create station', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _updateStation(String stationId, Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenStation(stationId),
        type: RequestType.put,
        params: data,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Station updated successfully');
        await _loadStations();
      } else {
        _showToast('Failed to update station', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _deleteStation(String stationId) async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenStation(stationId),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Station deleted successfully');
        await _loadStations();
      } else {
        _showToast('Failed to delete station', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _adjustSlots(String stationId, int parallelSlots, String reason) async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenStationAdjust(stationId),
        type: RequestType.put,
        params: {'parallelSlots': parallelSlots, 'reason': reason},
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Slots adjusted successfully');
        await _loadStations();
      } else {
        _showToast('Failed to adjust slots', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _updateConfig(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenConfiguration(widget.hotelId),
        type: RequestType.put,
        params: data,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Configuration saved successfully');
        await _loadConfig();
      } else {
        _showToast('Failed to save configuration', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  Future<void> _resetConfig() async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenConfigurationReset(widget.hotelId),
        type: RequestType.post,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data['success'] == true) {
        _showToast('Configuration reset to defaults');
        await _loadConfig();
      } else {
        _showToast('Failed to reset configuration', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
    setState(() => _isSaving = false);
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return Colors.green;
      case 'BUSY':
        return Colors.orange;
      case 'OVERLOADED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'NORMAL':
        return Colors.green.shade50;
      case 'BUSY':
        return Colors.orange.shade50;
      case 'OVERLOADED':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Tabs
        _buildSectionTabs(),
        const SizedBox(height: 24),
        // Content
        if (_activeSection == 'dashboard') _buildDashboard(),
        if (_activeSection == 'stations') _buildStations(),
        if (_activeSection == 'config') _buildConfig(),
      ],
    );
  }

  Widget _buildSectionTabs() {
    return Row(
      children: [
        _buildTabButton('dashboard', 'Live Dashboard'),
        const SizedBox(width: 8),
        _buildTabButton('stations', 'Kitchen Stations'),
        const SizedBox(width: 8),
        _buildTabButton('config', 'Configuration'),
      ],
    );
  }

  Widget _buildTabButton(String section, String label) {
    final isActive = _activeSection == section;
    return ElevatedButton(
      onPressed: () => setState(() => _activeSection = section),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? _primaryColor : Colors.grey.shade100,
        foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildDashboard() {
    final overallStatus = _kitchenStatus?['overallStatus'] ?? 'NORMAL';
    final message = _kitchenStatus?['message'] ?? 'Kitchen is operating normally.';
    final waitMinutes = _kitchenStatus?['estimatedWaitMinutes'] ?? 0;
    final stations = List<Map<String, dynamic>>.from(_kitchenStatus?['stations'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Status Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getStatusBgColor(overallStatus),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusColor(overallStatus).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kitchen Status: $overallStatus', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getStatusColor(overallStatus))),
                    const SizedBox(height: 4),
                    Text(message, style: TextStyle(color: _getStatusColor(overallStatus).withOpacity(0.8))),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('$waitMinutes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _getStatusColor(overallStatus))),
                  Text('min wait', style: TextStyle(fontSize: 12, color: _getStatusColor(overallStatus))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Station Cards
        if (stations.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Text('No kitchen stations configured yet.', style: TextStyle(color: Colors.orange.shade800)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _initializeStations,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white),
                  child: Text(_isSaving ? 'Initializing...' : 'Initialize Default Stations'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 800 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: stations.length,
                itemBuilder: (context, index) => _buildStatusCard(stations[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> station) {
    final status = station['status'] ?? 'NORMAL';
    final loadMinutes = station['currentLoadMinutes'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusBgColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(station['stationName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: TextStyle(fontSize: 10, color: _getStatusColor(status))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Current Load', '$loadMinutes min'),
          _buildStatusRow('Parallel Slots', '${station['parallelSlots'] ?? 0}'),
          _buildStatusRow('Queued Tasks', '${station['queuedTasks'] ?? 0}'),
          _buildStatusRow('In Progress', '${station['inProgressTasks'] ?? 0}'),
          const SizedBox(height: 8),
          // Load Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (loadMinutes / 60).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(_getStatusColor(status).withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kitchen Stations (${_stations.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (_stations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _initializeStations,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                      child: Text(_isSaving ? 'Initializing...' : 'Initialize Defaults'),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStationModal(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Station'),
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_stations.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No stations configured. Initialize defaults or add a station.', style: TextStyle(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 800 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: _stations.length,
                itemBuilder: (context, index) => _buildStationCard(_stations[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    final isActive = station['isActive'] ?? true;
    final color = _parseColor(station['color'] ?? '#4ECDC4');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(station['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(isActive ? 'Active' : 'Inactive', 
                  style: TextStyle(fontSize: 10, color: isActive ? Colors.green.shade800 : Colors.grey.shade600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Code: ${station['code'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text('Parallel Slots: ${station['parallelSlots'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text('Soft Limit: ${station['softMaxBusyMinutes'] ?? 0} min', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text('Hard Limit: ${station['hardMaxBusyMinutes'] ?? 0} min', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _showEditStationModal(station),
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _showAdjustSlotsModal(station),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: const Text('Adjust', style: TextStyle(fontSize: 12)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _confirmDeleteStation(station),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfig() {
    final defaultPrepTime = TextEditingController(text: '${_config?['defaultPrepTimeMinutes'] ?? 15}');
    final bufferTime = TextEditingController(text: '${_config?['bufferTimeMinutes'] ?? 5}');
    final closingBuffer = TextEditingController(text: '${_config?['closingTimeBufferMinutes'] ?? 30}');
    final slotDuration = TextEditingController(text: '${_config?['slotDurationMinutes'] ?? 15}');
    final maxOrders = TextEditingController(text: '${_config?['maxOrdersPerSlot'] ?? 5}');
    
    bool loadBalancing = _config?['enableKitchenLoadBalancing'] ?? true;
    bool autoSlot = _config?['enableAutoSlotSuggestion'] ?? true;
    bool priorityQueue = _config?['enablePriorityQueue'] ?? true;
    bool autoDisable = _config?['autoDisableHighComplexityOnOverload'] ?? true;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kitchen Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _isSaving ? null : _resetConfig,
                  child: Text(_isSaving ? 'Resetting...' : 'Reset to Defaults'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Timing Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Timing Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  _buildConfigField('Default Prep Time (min)', defaultPrepTime),
                  _buildConfigField('Buffer Time (min)', bufferTime),
                  _buildConfigField('Closing Time Buffer (min)', closingBuffer),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Slot Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slot Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  _buildConfigField('Slot Duration (min)', slotDuration),
                  _buildConfigField('Max Orders Per Slot', maxOrders),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Feature Flags
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Feature Flags', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: loadBalancing,
                    onChanged: (v) => setModalState(() => loadBalancing = v ?? true),
                    title: const Text('Load Balancing', style: TextStyle(fontSize: 14)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: autoSlot,
                    onChanged: (v) => setModalState(() => autoSlot = v ?? true),
                    title: const Text('Auto Slot Suggestion', style: TextStyle(fontSize: 14)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: priorityQueue,
                    onChanged: (v) => setModalState(() => priorityQueue = v ?? true),
                    title: const Text('Priority Queue', style: TextStyle(fontSize: 14)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: autoDisable,
                    onChanged: (v) => setModalState(() => autoDisable = v ?? true),
                    title: const Text('Auto-disable Complex Items on Overload', style: TextStyle(fontSize: 14)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                await _updateConfig({
                  'hotelId': widget.hotelId,
                  'defaultPrepTimeMinutes': int.tryParse(defaultPrepTime.text) ?? 15,
                  'bufferTimeMinutes': int.tryParse(bufferTime.text) ?? 5,
                  'closingTimeBufferMinutes': int.tryParse(closingBuffer.text) ?? 30,
                  'slotDurationMinutes': int.tryParse(slotDuration.text) ?? 15,
                  'maxOrdersPerSlot': int.tryParse(maxOrders.text) ?? 5,
                  'enableKitchenLoadBalancing': loadBalancing,
                  'enableAutoSlotSuggestion': autoSlot,
                  'enablePriorityQueue': priorityQueue,
                  'autoDisableHighComplexityOnOverload': autoDisable,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: Text(_isSaving ? 'Saving...' : 'Save Configuration'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfigField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStationModal() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final slotsController = TextEditingController(text: '3');
    final softLimitController = TextEditingController(text: '20');
    final hardLimitController = TextEditingController(text: '40');
    Color selectedColor = const Color(0xFF4ECDC4);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Kitchen Station'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalField('Station Name', nameController, 'e.g., Grill Station'),
                _buildModalField('Code (unique)', codeController, 'e.g., grill'),
                _buildModalField('Parallel Slots', slotsController, '', isNumber: true),
                Row(
                  children: [
                    Expanded(child: _buildModalField('Soft Limit (min)', softLimitController, '', isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModalField('Hard Limit (min)', hardLimitController, '', isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final color = await _showColorPicker(selectedColor);
                        if (color != null) setModalState(() => selectedColor = color);
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createStation({
                  'hotelId': widget.hotelId,
                  'name': nameController.text,
                  'code': codeController.text.toLowerCase().replaceAll(' ', '_'),
                  'parallelSlots': int.tryParse(slotsController.text) ?? 3,
                  'softMaxBusyMinutes': int.tryParse(softLimitController.text) ?? 20,
                  'hardMaxBusyMinutes': int.tryParse(hardLimitController.text) ?? 40,
                  'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: const Text('Create Station'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStationModal(Map<String, dynamic> station) {
    final nameController = TextEditingController(text: station['name']);
    final slotsController = TextEditingController(text: '${station['parallelSlots'] ?? 3}');
    final softLimitController = TextEditingController(text: '${station['softMaxBusyMinutes'] ?? 20}');
    final hardLimitController = TextEditingController(text: '${station['hardMaxBusyMinutes'] ?? 40}');
    Color selectedColor = _parseColor(station['color'] ?? '#4ECDC4');
    bool isActive = station['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Station: ${station['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalField('Station Name', nameController, ''),
                _buildModalField('Parallel Slots', slotsController, '', isNumber: true),
                Row(
                  children: [
                    Expanded(child: _buildModalField('Soft Limit (min)', softLimitController, '', isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModalField('Hard Limit (min)', hardLimitController, '', isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final color = await _showColorPicker(selectedColor);
                        if (color != null) setModalState(() => selectedColor = color);
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isActive,
                  onChanged: (v) => setModalState(() => isActive = v ?? true),
                  title: const Text('Station is Active'),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStation(station['_id'], {
                  'name': nameController.text,
                  'parallelSlots': int.tryParse(slotsController.text) ?? 3,
                  'softMaxBusyMinutes': int.tryParse(softLimitController.text) ?? 20,
                  'hardMaxBusyMinutes': int.tryParse(hardLimitController.text) ?? 40,
                  'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                  'isActive': isActive,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustSlotsModal(Map<String, dynamic> station) {
    final slotsController = TextEditingController(text: '${station['parallelSlots'] ?? 3}');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Adjust Slots: ${station['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Use this to temporarily adjust capacity (e.g., staff shortage).', 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            _buildModalField('New Parallel Slots', slotsController, '', isNumber: true),
            _buildModalField('Reason (optional)', reasonController, 'e.g., Staff shortage'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adjustSlots(
                station['_id'],
                int.tryParse(slotsController.text) ?? station['parallelSlots'],
                reasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
            child: const Text('Adjust Slots'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStation(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Station'),
        content: Text('Are you sure you want to delete "${station['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStation(station['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildModalField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => GestureDetector(
            onTap: () => Navigator.pop(context, color),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color == initialColor ? Colors.black : Colors.transparent, width: 2),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4ECDC4);
    }
  }
}
