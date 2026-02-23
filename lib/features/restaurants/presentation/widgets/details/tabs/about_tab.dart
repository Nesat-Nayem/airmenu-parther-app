import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class AboutTab extends StatefulWidget {
  final String hotelId;

  const AboutTab({super.key, required this.hotelId});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  static const _primaryColor = Color(0xFFC52031);

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _error;

  String _established = '';
  String _location = '';
  String _priceForTwo = '';
  List<String> _cuisineTypes = [];
  List<String> _facilities = [];
  String _featuredInTitle = '';
  String _featuredInImage = '';

  final TextEditingController _newCuisineController = TextEditingController();
  final TextEditingController _newFacilityController = TextEditingController();

  final List<String> _priceRanges = [
    'Under ₹500',
    '₹500 - ₹1000',
    '₹1000 - ₹1500',
    '₹1500 - ₹2500',
    'Above ₹2500',
  ];

  @override
  void initState() {
    super.initState();
    _loadAboutInfo();
  }

  @override
  void dispose() {
    _newCuisineController.dispose();
    _newFacilityController.dispose();
    super.dispose();
  }

  Future<void> _loadAboutInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelAboutInfo(widget.hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final aboutData = data['data'];
          setState(() {
            _established = aboutData['established'] ?? '';
            _location = aboutData['location'] ?? '';
            _priceForTwo = aboutData['priceForTwo'] ?? '';
            _cuisineTypes = List<String>.from(aboutData['cuisineTypes'] ?? []);
            _facilities = List<String>.from(aboutData['facilities'] ?? []);
            _featuredInTitle = aboutData['featuredIn']?['title'] ?? '';
            _featuredInImage = aboutData['featuredIn']?['image'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() {
          _error = 'Failed to load about info';
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

  Future<void> _saveAboutInfo() async {
    setState(() => _isSaving = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.hotelAboutInfo(widget.hotelId),
        type: RequestType.put,
        params: {
          'aboutInfo': {
            'established': _established,
            'location': _location,
            'priceForTwo': _priceForTwo,
            'cuisineTypes': _cuisineTypes,
            'facilities': _facilities,
            'featuredIn': {
              'title': _featuredInTitle,
              'image': _featuredInImage,
            },
          },
        },
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess) {
        _showToast('About info updated successfully');
        setState(() => _isEditing = false);
      } else {
        _showToast('Failed to update about info', isError: true);
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

  void _addCuisineType() {
    final text = _newCuisineController.text.trim();
    if (text.isNotEmpty && !_cuisineTypes.contains(text)) {
      setState(() {
        _cuisineTypes.add(text);
        _newCuisineController.clear();
      });
    }
  }

  void _addFacility() {
    final text = _newFacilityController.text.trim();
    if (text.isNotEmpty && !_facilities.contains(text)) {
      setState(() {
        _facilities.add(text);
        _newFacilityController.clear();
      });
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
        // Header
        Row(
          children: [
            const Text('About Restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const Spacer(),
            if (_isEditing) ...[
              TextButton(
                onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAboutInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Information'),
              ),
            ] else
              ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Edit Information'),
              ),
          ],
        ),
        const SizedBox(height: 24),

        if (_isEditing) _buildEditForm() else _buildViewMode(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Established', _established, (v) => setState(() => _established = v), hint: 'e.g., 2020-01-15'),
          const SizedBox(height: 16),
          _buildTextField('Location', _location, (v) => setState(() => _location = v), hint: 'e.g., Downtown, City Center'),
          const SizedBox(height: 16),
          _buildDropdown('Price for Two', _priceForTwo, _priceRanges, (v) => setState(() => _priceForTwo = v ?? '')),
          const SizedBox(height: 16),
          _buildChipsSection('Cuisine Types', _cuisineTypes, _newCuisineController, _addCuisineType, (i) => setState(() => _cuisineTypes.removeAt(i)), Colors.blue),
          const SizedBox(height: 16),
          _buildChipsSection('Facilities', _facilities, _newFacilityController, _addFacility, (i) => setState(() => _facilities.removeAt(i)), Colors.green),
          const SizedBox(height: 16),
          const Text('Featured In', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Title', _featuredInTitle, (v) => setState(() => _featuredInTitle = v), hint: 'e.g., Food Magazine'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Image URL', _featuredInImage, (v) => setState(() => _featuredInImage = v), hint: 'https://...'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final hasData = _established.isNotEmpty || _location.isNotEmpty || _priceForTwo.isNotEmpty || _cuisineTypes.isNotEmpty || _facilities.isNotEmpty;

    if (!hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("No about information available. Click 'Edit Information' to add details.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      children: [
        // Info Cards
        Row(
          children: [
            Expanded(child: _buildInfoCard('Established', _established.isNotEmpty ? _formatDate(_established) : 'N/A')),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Location', _location.isNotEmpty ? _location : 'N/A')),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Price for Two', _priceForTwo.isNotEmpty ? _priceForTwo : 'N/A')),
          ],
        ),
        const SizedBox(height: 16),

        // Cuisine Types
        if (_cuisineTypes.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cuisine Types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cuisineTypes.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                    child: Text(c, style: TextStyle(color: Colors.blue[800])),
                  )).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Facilities
        if (_facilities.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Facilities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _facilities.map((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                    child: Text(f, style: TextStyle(color: Colors.green[800])),
                  )).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Featured In
        if (_featuredInTitle.isNotEmpty || _featuredInImage.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Featured In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_featuredInImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _featuredInImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Text(_featuredInTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
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
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value.isNotEmpty && options.contains(value) ? value : null,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select Price Range',
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

  Widget _buildChipsSection(String label, List<String> items, TextEditingController controller, VoidCallback onAdd, Function(int) onRemove, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.value, style: TextStyle(color: color.withOpacity(0.8))),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => onRemove(e.key),
                    child: Icon(Icons.close, size: 16, color: _primaryColor),
                  ),
                ],
              ),
            )).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add a ${label.toLowerCase().replaceAll('s', '')}',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)), borderSide: const BorderSide(color: _primaryColor, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
