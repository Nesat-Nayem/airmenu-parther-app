import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Form dialog for creating/editing a landmark
class LandmarkFormDialog extends StatefulWidget {
  final MallModel? mall; // null for create, non-null for edit
  final Function(CreateMallRequest request, String? imagePath) onCreate;
  final Function(String id, UpdateMallRequest request, String? imagePath)?
  onUpdate;

  const LandmarkFormDialog({
    super.key,
    this.mall,
    required this.onCreate,
    this.onUpdate,
  });

  @override
  State<LandmarkFormDialog> createState() => _LandmarkFormDialogState();
}

class _LandmarkFormDialogState extends State<LandmarkFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  String? _imagePath;
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  bool get isEditing => widget.mall != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mall?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.mall?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.mall?.displayAddress ?? '',
    );

    _latitude = widget.mall?.latitude;
    _longitude = widget.mall?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickLocation() async {
    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
      }
      return;
    }

    // Get current location or default to Dubai (as mostly airmenu is there) or 0,0
    LatLng initialCenter = const LatLng(25.2048, 55.2708); // Dubai
    if (_latitude != null && _longitude != null) {
      initialCenter = LatLng(_latitude!, _longitude!);
    } else {
      try {
        final position = await Geolocator.getCurrentPosition();
        initialCenter = LatLng(position.latitude, position.longitude);
      } catch (e) {
        // Fallback to default
      }
    }

    if (!mounted) return;

    final LatLng? selected = await showDialog<LatLng>(
      context: context,
      builder: (ctx) => _MapPickerDialog(initialCenter: initialCenter),
    );

    if (selected != null) {
      setState(() {
        _latitude = selected.latitude;
        _longitude = selected.longitude;
      });

      // Fetch address
      if (mounted) {
        final address = await _getAddressFromLatLng(
          selected.latitude,
          selected.longitude,
        );
        if (address != null && mounted) {
          setState(() {
            _locationController.text = address;
          });
        }
      }
    }
  }

  Future<String?> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AirMenuPartnerApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] as String?;
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 16),
                      _buildNameField(),
                      const SizedBox(height: 24),
                      _buildDescriptionField(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Location & Media'),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 24),
                      _buildImagePicker(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AirMenuTextStyle.subheadingH5.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing
                  ? Icons.edit_location_alt_rounded
                  : Icons.add_business_rounded,
              color: const Color(0xFFC52031),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Landmark' : 'Add Landmark',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEditing
                    ? 'Update mall details below'
                    : 'Create a new mall or food court',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF9CA3AF),
              hoverColor: const Color(0xFFF3F4F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Mall Name', isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w500),
          decoration: _inputDecoration('e.g. Dubai Mall, Downtown').copyWith(
            prefixIcon: const Icon(
              Icons.business_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Mall name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Description'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: AirMenuTextStyle.normal,
          decoration: _inputDecoration(
            'Brief description of the landmark...',
          ).copyWith(alignLabelWithHint: true),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Location Address'),
            if (_latitude != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          style: AirMenuTextStyle.normal,
          decoration: _inputDecoration('Enter full address').copyWith(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _pickLocation,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.map_rounded,
                      color: Color(0xFFC52031),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final hasImage =
        _imagePath != null || (widget.mall?.mainImage.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Cover Image'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImagePreview(hasImage),
                if (hasImage)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.0,
                      ), // Hover effect could go here
                    ),
                  ),
                if (hasImage)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AirMenuTextStyle.small.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
          fontSize: 13,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildImagePreview(bool hasImage) {
    if (_imagePath != null) {
      if (kIsWeb) {
        return Image.network(_imagePath!, fit: BoxFit.cover);
      } else {
        return Image.file(File(_imagePath!), fit: BoxFit.cover);
      }
    } else if (widget.mall?.mainImage.isNotEmpty ?? false) {
      return Image.network(
        widget.mall!.mainImage,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 32,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            size: 32,
            color: Color(0xFFC52031),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            text: 'Click to upload',
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFFC52031),
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: ' or drag and drop',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SVG, PNG, JPG or GIF (max. 800x400px)',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              foregroundColor: const Color(0xFF6B7280),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC52031),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
              shadowColor: const Color(0xFFC52031).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing ? 'Save Changes' : 'Create Landmark',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AirMenuTextStyle.normal.copyWith(
        color: const Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC52031), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (isEditing && widget.onUpdate != null) {
      final request = UpdateMallRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        // Assuming location input IS address for now, or use _locationController.text as address
        address: _locationController.text.trim(),
      );
      widget.onUpdate!(widget.mall!.id, request, _imagePath);
    } else {
      final request = CreateMallRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        address: _locationController.text.trim(),
      );
      widget.onCreate(request, _imagePath);
    }

    Navigator.of(context).pop();
  }
}

class _MapPickerDialog extends StatefulWidget {
  final LatLng initialCenter;

  const _MapPickerDialog({required this.initialCenter});

  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  late LatLng _currentCenter;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialCenter;
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pick Location', style: AirMenuTextStyle.headingH4),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.initialCenter,
                      initialZoom: 13,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _currentCenter = point;
                        });
                      },
                      onLongPress: (tapPosition, point) {
                        // Also support long press for mobile
                        setState(() {
                          _currentCenter = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.airmenu.partner',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentCenter,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFC52031),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Instruction overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tap on the map to select location',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _currentCenter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC52031),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Confirm Location (${_currentCenter.latitude.toStringAsFixed(4)}, ${_currentCenter.longitude.toStringAsFixed(4)})',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
