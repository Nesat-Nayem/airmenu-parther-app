import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class OffersTab extends StatefulWidget {
  final String hotelId;

  const OffersTab({super.key, required this.hotelId});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  static const _primaryColor = Color(0xFFC52031);

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _error;

  List<Map<String, dynamic>> _preBookOffers = [];
  List<Map<String, dynamic>> _walkInOffers = [];
  List<Map<String, dynamic>> _bankBenefits = [];


  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelOffersData(widget.hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _preBookOffers = List<Map<String, dynamic>>.from(data['data']['preBookOffers'] ?? []);
            _walkInOffers = List<Map<String, dynamic>>.from(data['data']['walkInOffers'] ?? []);
            _bankBenefits = List<Map<String, dynamic>>.from(data['data']['bankBenefits'] ?? []);
            _isLoading = false;
          });
        } else {
          setState(() {
            _preBookOffers = [];
            _walkInOffers = [];
            _bankBenefits = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load offers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOffers() async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelOffersData(widget.hotelId),
        type: RequestType.put,
        params: {
          'preBookOffers': _preBookOffers,
          'walkInOffers': _walkInOffers,
          'bankBenefits': _bankBenefits,
        },
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess) {
        _showToast('Offers updated successfully');
        setState(() => _isEditing = false);
      } else {
        _showToast('Failed to update offers', isError: true);
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
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

  void _addPreBookOffer() {
    setState(() {
      _preBookOffers.add({
        'title': '',
        'description': '',
        'slots': 'Mon, Tue, 06:00 PM - 08:00 PM',
        'buttonText': 'Book Now',
      });
    });
  }

  void _addWalkInOffer() {
    setState(() {
      _walkInOffers.add({
        'title': '',
        'description': '',
        'validTime': '',
        'icon': 'discount',
      });
    });
  }

  void _addBankBenefit() {
    setState(() {
      _bankBenefits.add({
        'bankName': '',
        'description': '',
        'code': '',
        'bgColor': '#3B82F6',
      });
    });
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
        // Header
        Row(
          children: [
            const Text('Restaurant Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const Spacer(),
            if (_isEditing) ...[
              TextButton(
                onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOffers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Offers'),
              ),
            ] else
              ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Edit Offers'),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Pre-Book Offers Section
        _buildSection(
          title: 'Pre-Book Offers',
          items: _preBookOffers,
          onAdd: _isEditing ? _addPreBookOffer : null,
          emptyMessage: 'No pre-book offers available',
          itemBuilder: (index, item) => _buildPreBookOfferCard(index, item),
        ),
        const SizedBox(height: 24),

        // Walk-In Offers Section
        _buildSection(
          title: 'Walk-In Offers',
          items: _walkInOffers,
          onAdd: _isEditing ? _addWalkInOffer : null,
          emptyMessage: 'No walk-in offers available',
          itemBuilder: (index, item) => _buildWalkInOfferCard(index, item),
        ),
        const SizedBox(height: 24),

        // Bank Benefits Section
        _buildSection(
          title: 'Bank Benefits',
          items: _bankBenefits,
          onAdd: _isEditing ? _addBankBenefit : null,
          emptyMessage: 'No bank benefits available',
          itemBuilder: (index, item) => _buildBankBenefitCard(index, item),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> items,
    VoidCallback? onAdd,
    required String emptyMessage,
    required Widget Function(int, Map<String, dynamic>) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (onAdd != null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(foregroundColor: _primaryColor),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emptyMessage, style: TextStyle(color: Colors.grey[600]))),
          )
        else
          ...items.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: itemBuilder(e.key, e.value),
          )),
      ],
    );
  }

  Widget _buildPreBookOfferCard(int index, Map<String, dynamic> offer) {
    if (_isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Title', offer['title'] ?? '', (v) => setState(() => _preBookOffers[index]['title'] = v)),
            const SizedBox(height: 12),
            _buildTextField('Description', offer['description'] ?? '', (v) => setState(() => _preBookOffers[index]['description'] = v), maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField('Available Slots', offer['slots'] ?? '', (v) => setState(() => _preBookOffers[index]['slots'] = v)),
            const SizedBox(height: 12),
            _buildTextField('Button Text', offer['buttonText'] ?? '', (v) => setState(() => _preBookOffers[index]['buttonText'] = v)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _preBookOffers.removeAt(index)),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Text(offer['description'] ?? '', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Available: ', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(offer['slots'] ?? '', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(offer['buttonText'] ?? 'Book Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkInOfferCard(int index, Map<String, dynamic> offer) {
    if (_isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Title', offer['title'] ?? '', (v) => setState(() => _walkInOffers[index]['title'] = v)),
            const SizedBox(height: 12),
            _buildTextField('Description', offer['description'] ?? '', (v) => setState(() => _walkInOffers[index]['description'] = v), maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField('Valid Time', offer['validTime'] ?? '', (v) => setState(() => _walkInOffers[index]['validTime'] = v)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _walkInOffers.removeAt(index)),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(50)),
            child: Icon(Icons.local_offer, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(offer['description'] ?? '', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(offer['validTime'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankBenefitCard(int index, Map<String, dynamic> benefit) {
    final borderColor = _parseColor(benefit['bgColor'] ?? '#3B82F6');

    if (_isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Bank Name', benefit['bankName'] ?? '', (v) => setState(() => _bankBenefits[index]['bankName'] = v)),
            const SizedBox(height: 12),
            _buildTextField('Description', benefit['description'] ?? '', (v) => setState(() => _bankBenefits[index]['description'] = v), maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField('Promo Code', benefit['code'] ?? '', (v) => setState(() => _bankBenefits[index]['code'] = v)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _bankBenefits.removeAt(index)),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(benefit['bankName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(benefit['description'] ?? '', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
            child: Text(benefit['code'] ?? '', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primaryColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
