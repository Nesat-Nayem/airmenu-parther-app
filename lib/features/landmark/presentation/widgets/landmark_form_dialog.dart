import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

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
        // Optionally append coords to location text if empty
        if (_locationController.text.isEmpty) {
          _locationController.text =
              '${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),
                      _buildLocationField(),
                      const SizedBox(height: 20),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            isEditing ? 'Edit Landmark' : 'Add Landmark',
            style: AirMenuTextStyle.headingH4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Mall Name ',
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('Enter mall name'),
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
        Text(
          'Description',
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: _inputDecoration('Enter description'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: _inputDecoration('Enter location address').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                Icons.location_on_outlined,
                color: _latitude != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFC52031),
              ),
              onPressed: _pickLocation,
              tooltip: 'Pick location on map',
            ),
          ),
          maxLines: 2,
        ),
        if (_latitude != null && _longitude != null) ...[
          const SizedBox(height: 4),
          Text(
            'Selected Coordinates: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF10B981),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePicker() {
    final hasImage =
        _imagePath != null || (widget.mall?.mainImage.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Image',
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImagePreview(hasImage),
          ),
        ),
      ],
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
          child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cloud_upload_outlined,
          size: 32,
          color: Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 8),
        Text(
          'Click to upload image',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                      isEditing ? 'Update' : 'Create',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC52031), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
