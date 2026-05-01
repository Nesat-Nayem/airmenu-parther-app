import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart' hide WeeklyTimingModel;
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/restaurant_creation_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/create/create_restaurant_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/create/create_restaurant_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/create/create_restaurant_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class EditRestaurantDialog extends StatelessWidget {
  final RestaurantModel restaurant;

  const EditRestaurantDialog({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRestaurantBloc(
        AdminRestaurantsRepository(locator<ApiService>()),
      ),
      child: _EditRestaurantContent(restaurant: restaurant),
    );
  }
}

class _EditRestaurantContent extends StatefulWidget {
  final RestaurantModel restaurant;

  const _EditRestaurantContent({required this.restaurant});

  @override
  State<_EditRestaurantContent> createState() => _EditRestaurantContentState();
}

class _EditRestaurantContentState extends State<_EditRestaurantContent> {
  final _formKey = GlobalKey<FormState>();
  final _locationFieldKey = GlobalKey();

  late final TextEditingController _nameController;
  late final TextEditingController _cuisineController;
  late final TextEditingController _ratingController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _offerController;
  late final TextEditingController _cgstController;
  late final TextEditingController _sgstController;
  late final TextEditingController _serviceChargeController;
  late final TextEditingController _locationController;
  final TextEditingController _placeIdController = TextEditingController();

  int? _minPrice;
  int? _maxPrice;
  String? _priceError;

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  final Map<String, bool> _closedDays = {};
  final Map<String, String> _fromTimes = {};
  final Map<String, String> _toTimes = {};

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  List<String> get _timeSlots {
    final slots = <String>[];
    for (int i = 0; i < 24 * 60; i += 30) {
      final hours = i ~/ 60;
      final minutes = i % 60;
      final ampm = hours >= 12 ? 'PM' : 'AM';
      final displayHours = hours % 12 == 0 ? 12 : hours % 12;
      final displayMinutes = minutes.toString().padLeft(2, '0');
      slots.add('$displayHours:$displayMinutes $ampm');
    }
    return slots;
  }

  List<int> get _priceOptions {
    final options = <int>[];
    for (int i = 100; i <= 5000; i += 100) {
      options.add(i);
    }
    return options;
  }

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;

    _nameController = TextEditingController(text: r.name);
    _cuisineController = TextEditingController(text: r.cuisine);
    _ratingController = TextEditingController(
      text: r.rating > 0 ? r.rating.toString() : '4.0',
    );
    _descriptionController = TextEditingController(text: r.description);
    _offerController = TextEditingController(text: r.offer);
    _cgstController = TextEditingController(
      text: r.cgstRate > 0 ? r.cgstRate.toStringAsFixed(0) : '0',
    );
    _sgstController = TextEditingController(
      text: r.sgstRate > 0 ? r.sgstRate.toStringAsFixed(0) : '0',
    );
    _serviceChargeController = TextEditingController(
      text: r.serviceCharge > 0 ? r.serviceCharge.toStringAsFixed(0) : '0',
    );
    _locationController = TextEditingController(
      text: r.address ?? r.location,
    );

    _parsePriceRange(r.price);
    _initWeeklyTimings();
  }

  void _parsePriceRange(String price) {
    if (price.isEmpty) return;
    final rangeMatch = RegExp(r'₹?(\d+)\s*-\s*₹?(\d+)').firstMatch(price);
    if (rangeMatch != null) {
      _minPrice = int.tryParse(rangeMatch.group(1) ?? '');
      _maxPrice = int.tryParse(rangeMatch.group(2) ?? '');
      return;
    }
    final aboveMatch = RegExp(r'Above\s*₹?(\d+)').firstMatch(price);
    if (aboveMatch != null) {
      _minPrice = int.tryParse(aboveMatch.group(1) ?? '');
      return;
    }
    final underMatch = RegExp(r'Under\s*₹?(\d+)').firstMatch(price);
    if (underMatch != null) {
      _maxPrice = int.tryParse(underMatch.group(1) ?? '');
      return;
    }
    final singleMatch = RegExp(r'₹?(\d+)').firstMatch(price);
    if (singleMatch != null) {
      _minPrice = int.tryParse(singleMatch.group(1) ?? '');
    }
  }

  void _initWeeklyTimings() {
    for (final day in _weekDays) {
      _closedDays[day] = false;
      _fromTimes[day] = '9:00 AM';
      _toTimes[day] = '10:00 PM';
    }

    for (final timing in widget.restaurant.weeklyTimings) {
      final day = timing.day;
      if (!_weekDays.contains(day)) continue;
      final hours = timing.hours;
      if (hours.toLowerCase() == 'closed') {
        _closedDays[day] = true;
      } else {
        final parts = hours.split(' - ');
        if (parts.length == 2) {
          final from = _normalizeTime(parts[0].trim());
          final to = _normalizeTime(parts[1].trim());
          if (_timeSlots.contains(from)) _fromTimes[day] = from;
          if (_timeSlots.contains(to)) _toTimes[day] = to;
        }
      }
    }
  }

  String _normalizeTime(String time) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return time;
    final h = match.group(1)!;
    final m = match.group(2)!;
    final ap = match.group(3)!.toUpperCase();
    return '$h:$m $ap';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    _offerController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _serviceChargeController.dispose();
    _locationController.dispose();
    _placeIdController.dispose();
    _hideOverlay();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImagePath = image.path;
        if (!kIsWeb) _selectedImage = File(image.path);
      });
    }
  }

  void _showOverlay(
    BuildContext context,
    List<PlaceAutocompleteModel> suggestions,
  ) {
    _hideOverlay();
    final RenderBox? renderBox =
        _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                itemBuilder: (_, index) {
                  final s = suggestions[index];
                  return ListTile(
                    title: Text(
                      s.description,
                      style: AirMenuTextStyle.normal.copyWith(fontSize: 14),
                    ),
                    onTap: () {
                      _locationController.text = s.description;
                      _placeIdController.text = s.placeId;
                      _hideOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _submitForm(BuildContext context) {
    _hideOverlay();
    final formValid = _formKey.currentState!.validate();

    if (_minPrice == null && _maxPrice == null) {
      setState(() => _priceError = 'Please select a price range');
    }

    if (!formValid || (_minPrice == null && _maxPrice == null)) return;

    String priceString;
    if (_minPrice != null && _maxPrice != null) {
      priceString = '₹$_minPrice - ₹$_maxPrice';
    } else if (_minPrice != null) {
      priceString = 'Above ₹$_minPrice';
    } else {
      priceString = 'Under ₹$_maxPrice';
    }

    final weeklyTimings = <WeeklyTimingModel>[];
    for (final day in _weekDays) {
      if (_closedDays[day] == true) {
        weeklyTimings.add(WeeklyTimingModel(day: day, hours: 'Closed'));
      } else {
        final from = _fromTimes[day] ?? '9:00 AM';
        final to = _toTimes[day] ?? '10:00 PM';
        weeklyTimings.add(WeeklyTimingModel(day: day, hours: '$from - $to'));
      }
    }

    context.read<CreateRestaurantBloc>().add(
      UpdateRestaurantWithImage(
        restaurantId: widget.restaurant.id,
        name: _nameController.text,
        cuisine: _cuisineController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        googlePlaceId: _placeIdController.text.isNotEmpty
            ? _placeIdController.text
            : null,
        price: priceString,
        rating: double.tryParse(_ratingController.text),
        offer: _offerController.text.isNotEmpty ? _offerController.text : null,
        cgstRate: num.tryParse(_cgstController.text),
        sgstRate: num.tryParse(_sgstController.text),
        serviceCharge: num.tryParse(_serviceChargeController.text),
        weeklyTimings: weeklyTimings,
        imagePath: _selectedImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateRestaurantBloc, CreateRestaurantState>(
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state.submissionStatus == SubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Update failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.suggestions.isNotEmpty) {
          _showOverlay(context, state.suggestions);
        } else {
          _hideOverlay();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 880),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildDialogHeader(context),
              Expanded(
                child: BlocBuilder<CreateRestaurantBloc, CreateRestaurantState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildCardSection(
                              title: 'Basic Information',
                              icon: Icons.restaurant,
                              child: _buildBasicInfoGrid(),
                            ),
                            const SizedBox(height: 20),
                            _buildCardSection(
                              title: 'Taxes & Charges',
                              icon: Icons.receipt_long,
                              child: _buildTaxGrid(),
                            ),
                            const SizedBox(height: 20),
                            _buildCardSection(
                              title: 'Location Details',
                              icon: Icons.location_on,
                              child: Builder(
                                builder: (ctx) => _buildLocationGrid(ctx),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildCardSection(
                              title: 'Description & Offer',
                              icon: Icons.description,
                              child: _buildDescriptionSection(),
                            ),
                            const SizedBox(height: 20),
                            _buildCardSection(
                              title: 'Main Image',
                              icon: Icons.image,
                              child: _buildImagePicker(),
                            ),
                            const SizedBox(height: 20),
                            _buildCardSection(
                              title: 'Weekly Timings',
                              icon: Icons.schedule,
                              child: _buildWeeklyTimings(),
                            ),
                            const SizedBox(height: 24),
                            _buildFooterButtons(context, state),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Restaurant',
                  style: AirMenuTextStyle.headingH4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  widget.restaurant.name,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC52031).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: const Color(0xFFC52031), size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildBasicInfoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth > 500;
        return Column(
          children: [
            _buildRow([
              _buildTextField(
                label: 'Restaurant Name',
                controller: _nameController,
                hint: 'e.g. Royal Kitchen',
                prefixIcon: Icons.store,
                isRequired: true,
              ),
              _buildTextField(
                label: 'Cuisine',
                controller: _cuisineController,
                hint: 'e.g. Italian, Indian',
                prefixIcon: Icons.restaurant_menu,
                isRequired: true,
              ),
            ], isTwoColumn),
            const SizedBox(height: 16),
            _buildRow([
              _buildPriceRangeSelector(),
              _buildTextField(
                label: 'Rating',
                controller: _ratingController,
                hint: 'e.g. 4.5',
                prefixIcon: Icons.star,
                keyboardType: TextInputType.number,
              ),
            ], isTwoColumn),
          ],
        );
      },
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Price Range',
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              fontSize: 13,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFC52031)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _minPrice,
                hint: 'Min Price',
                items: _priceOptions,
                onChanged: (val) => setState(() {
                  _minPrice = val;
                  _priceError = null;
                }),
                prefix: '₹',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdown(
                value: _maxPrice,
                hint: 'Max Price',
                items: _priceOptions,
                onChanged: (val) => setState(() {
                  _maxPrice = val;
                  _priceError = null;
                }),
                prefix: '₹',
              ),
            ),
          ],
        ),
        if (_priceError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _priceError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<int> items,
    required void Function(int?) onChanged,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              hint,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(10),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item,
              child: Text(
                prefix != null ? '$prefix$item' : item.toString(),
                style: AirMenuTextStyle.normal.copyWith(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTaxGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        if (isWide) {
          return _buildRow([
            _buildTextField(
              label: 'CGST Rate (%)',
              controller: _cgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g. 9',
            ),
            _buildTextField(
              label: 'SGST Rate (%)',
              controller: _sgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g. 9',
            ),
            _buildTextField(
              label: 'Service Charge (%)',
              controller: _serviceChargeController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g. 5',
            ),
          ], true);
        }
        return Column(
          children: [
            _buildTextField(
              label: 'CGST Rate (%)',
              controller: _cgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'SGST Rate (%)',
              controller: _sgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Service Charge (%)',
              controller: _serviceChargeController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationGrid(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: _buildTextField(
        key: _locationFieldKey,
        label: 'Location',
        controller: _locationController,
        hint: 'Start typing to search for a location...',
        prefixIcon: Icons.location_on,
        isRequired: true,
        onChanged: (val) {
          context.read<CreateRestaurantBloc>().add(
            UpdateAutocompleteQuery(val),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      children: [
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Describe the restaurant, its ambiance, specialties, etc.',
          maxLines: 4,
          prefixIcon: Icons.notes,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Current Offer (optional)',
          controller: _offerController,
          hint: 'e.g. 20% off on weekdays',
          prefixIcon: Icons.local_offer,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final hasNewImage = _selectedImageBytes != null;
    final existingImageUrl = widget.restaurant.mainImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasNewImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? Image.memory(
                    _selectedImageBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _selectedImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 12),
        ] else if (existingImageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: existingImageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 180,
                color: const Color(0xFFF3F4F6),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image_not_supported, size: 48, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library, size: 16),
              label: Text(
                hasNewImage
                    ? 'Change Image'
                    : existingImageUrl.isNotEmpty
                        ? 'Replace Image'
                        : 'Choose Image',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (hasNewImage) ...[
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _selectedImage = null;
                  _selectedImageBytes = null;
                  _selectedImagePath = null;
                }),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Leave unchanged to keep the current image.',
          style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildWeeklyTimings() {
    return Column(
      children: [
        ..._weekDays.map((day) => _buildDayTimingRow(day)),
        const SizedBox(height: 8),
        Text(
          'Select opening and closing hours for each day.',
          style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildDayTimingRow(String day) {
    final isClosed = _closedDays[day] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 480;
          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    day,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeDropdown(
                    value: _fromTimes[day]!,
                    enabled: !isClosed,
                    onChanged: (val) => setState(() => _fromTimes[day] = val!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('to',
                    style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9CA3AF)),
                  ),
                ),
                Expanded(
                  child: _buildTimeDropdown(
                    value: _toTimes[day]!,
                    enabled: !isClosed,
                    onChanged: (val) => setState(() => _toTimes[day] = val!),
                  ),
                ),
                const SizedBox(width: 8),
                _buildClosedCheckbox(day, isClosed),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  _buildClosedCheckbox(day, isClosed),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeDropdown(
                      value: _fromTimes[day]!,
                      enabled: !isClosed,
                      onChanged: (val) => setState(() => _fromTimes[day] = val!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('to',
                      style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                  Expanded(
                    child: _buildTimeDropdown(
                      value: _toTimes[day]!,
                      enabled: !isClosed,
                      onChanged: (val) => setState(() => _toTimes[day] = val!),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeDropdown({
    required String value,
    required bool enabled,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          borderRadius: BorderRadius.circular(8),
          items: _timeSlots.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(
                time,
                style: AirMenuTextStyle.normal.copyWith(
                  fontSize: 12,
                  color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildClosedCheckbox(String day, bool isClosed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: isClosed,
            onChanged: (val) => setState(() => _closedDays[day] = val ?? false),
            activeColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Closed',
          style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> children, bool isMultiColumn) {
    if (!isMultiColumn) {
      return Column(
        children: children
            .map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: e))
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (e) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: e,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextField({
    Key? key,
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    IconData? prefixIcon,
    bool isRequired = false,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              fontSize: 13,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFC52031)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator ??
              (isRequired
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null),
          onChanged: onChanged,
          style: AirMenuTextStyle.normal.copyWith(
            fontSize: 14,
            color: const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: const Color(0xFF9CA3AF))
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC52031), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButtons(BuildContext context, CreateRestaurantState state) {
    final isLoading = state.submissionStatus == SubmissionStatus.loading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => _submitForm(context),
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 16),
          label: Text(isLoading ? 'Saving...' : 'Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
