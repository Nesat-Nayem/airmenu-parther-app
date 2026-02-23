import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class BuffetsTab extends StatefulWidget {
  final String hotelId;

  const BuffetsTab({super.key, required this.hotelId});

  @override
  State<BuffetsTab> createState() => _BuffetsTabState();
}

class _BuffetsTabState extends State<BuffetsTab> {
  static const _primaryColor = Color(0xFFC52031);
  
  List<Buffet> _buffets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuffets();
  }

  Future<void> _loadBuffets() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelBuffets(widget.hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        final List<dynamic> buffetsList = data is Map ? (data['data'] ?? data['buffets'] ?? []) : (data is List ? data : []);
        setState(() {
          _buffets = buffetsList.map((e) => Buffet.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; _buffets = []; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<bool> _addBuffet(Map<String, dynamic> data) async {
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelBuffets(widget.hotelId),
        type: RequestType.post,
        params: data,
        fun: (data) => jsonDecode(data),
      );
      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateBuffet(String buffetId, Map<String, dynamic> data) async {
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelBuffet(widget.hotelId, buffetId),
        type: RequestType.put,
        params: data,
        fun: (data) => jsonDecode(data),
      );
      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteBuffet(String buffetId) async {
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelBuffet(widget.hotelId, buffetId),
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );
      return response is DataSuccess;
    } catch (e) {
      return false;
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAddEditModal({Buffet? buffet}) {
    final isEditing = buffet != null;
    final nameController = TextEditingController(text: buffet?.name ?? '');
    final priceController = TextEditingController(text: buffet?.price.toString() ?? '');
    String selectedType = buffet?.type ?? 'Lunch';
    List<String> selectedDays = buffet?.days.toList() ?? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String hoursFrom = buffet?.hours.split(' - ').first ?? '12:00 PM';
    String hoursTo = buffet?.hours.split(' - ').last ?? '03:00 PM';
    bool isSubmitting = false;

    final types = ['Breakfast', 'Brunch', 'Lunch', 'Dinner', 'Special'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final timeSlots = _generateTimeSlots();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(isEditing ? 'Edit Buffet' : 'Add New Buffet', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                // Form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Buffet Name *'),
                        _buildTextField(nameController, 'e.g., Sunday Brunch'),
                        const SizedBox(height: 16),
                        _buildLabel('Buffet Type *'),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: _inputDecoration(),
                          items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setModalState(() => selectedType = v!),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Available Days *'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: days.map((day) {
                            final isSelected = selectedDays.contains(day);
                            return InkWell(
                              onTap: () => setModalState(() {
                                if (isSelected) {
                                  selectedDays.remove(day);
                                } else {
                                  selectedDays.add(day);
                                }
                              }),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryColor : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(day.substring(0, 3), style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 12)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Hours *'),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('From', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: hoursFrom,
                                    decoration: _inputDecoration(),
                                    isExpanded: true,
                                    items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) => setModalState(() => hoursFrom = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('To', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: hoursTo,
                                    decoration: _inputDecoration(),
                                    isExpanded: true,
                                    items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) => setModalState(() => hoursTo = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Price (₹) *'),
                        _buildTextField(priceController, 'e.g., 999', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (nameController.text.isEmpty || priceController.text.isEmpty || selectedDays.isEmpty) {
                            _showToast('Please fill all required fields', isError: true);
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          final data = {
                            'name': nameController.text,
                            'type': selectedType,
                            'days': selectedDays,
                            'hours': '$hoursFrom - $hoursTo',
                            'price': double.tryParse(priceController.text) ?? 0,
                          };
                          bool success;
                          if (isEditing) {
                            success = await _updateBuffet(buffet.id, data);
                          } else {
                            success = await _addBuffet(data);
                          }
                          if (success) {
                            Navigator.pop(context);
                            _showToast(isEditing ? 'Buffet updated successfully' : 'Buffet added successfully');
                            _loadBuffets();
                          } else {
                            setModalState(() => isSubmitting = false);
                            _showToast('Failed to ${isEditing ? 'update' : 'add'} buffet', isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Update Buffet' : 'Add Buffet'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Buffet buffet) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Buffet'),
          content: Text('Are you sure you want to delete "${buffet.name}"? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: isDeleting ? null : () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: isDeleting ? null : () async {
                setModalState(() => isDeleting = true);
                final success = await _deleteBuffet(buffet.id);
                if (success) {
                  Navigator.pop(context);
                  _showToast('Buffet deleted successfully');
                  _loadBuffets();
                } else {
                  setModalState(() => isDeleting = false);
                  _showToast('Failed to delete buffet', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int i = 0; i < 24 * 60; i += 30) {
      final hours = i ~/ 60;
      final minutes = i % 60;
      final ampm = hours >= 12 ? 'PM' : 'AM';
      final displayHours = hours % 12 == 0 ? 12 : hours % 12;
      slots.add('$displayHours:${minutes.toString().padLeft(2, '0')} $ampm');
    }
    return slots;
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: _inputDecoration(hint: hint),
  );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryColor, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text('Buffet Offerings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddEditModal(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Buffet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Content
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        else if (_error != null)
          Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))))
        else if (_buffets.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No buffets available. Add your first buffet offering!', style: TextStyle(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 850 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _buffets.length,
                itemBuilder: (context, index) => _buildBuffetCard(_buffets[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBuffetCard(Buffet buffet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(buffet.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Text(buffet.type, style: TextStyle(color: Colors.blue[700], fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined, buffet.days.map((d) => d.substring(0, 3)).join(', ')),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time_outlined, buffet.hours),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text('₹${buffet.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: _actionButton('Edit', () => _showAddEditModal(buffet: buffet))),
              const SizedBox(width: 8),
              Expanded(child: _actionButton('Delete', () => _showDeleteDialog(buffet))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey[500]),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
    ],
  );

  Widget _actionButton(String label, VoidCallback onPressed) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
    ),
  );
}

class Buffet {
  final String id;
  final String name;
  final String type;
  final List<String> days;
  final String hours;
  final double price;

  Buffet({required this.id, required this.name, required this.type, required this.days, required this.hours, required this.price});

  factory Buffet.fromJson(Map<String, dynamic> json) => Buffet(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] ?? 'Lunch',
    days: (json['days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    hours: json['hours'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
  );
}
