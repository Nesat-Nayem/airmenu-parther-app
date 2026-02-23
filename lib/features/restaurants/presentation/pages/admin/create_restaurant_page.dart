import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import '../../../data/models/admin/restaurant_creation_models.dart';
import '../../../data/repositories/admin_restaurants_repository.dart';
import '../../../../../utils/injectible.dart';
import '../../../../../utils/typography/airmenu_typography.dart';
import '../../bloc/create/create_restaurant_bloc.dart';
import '../../bloc/create/create_restaurant_event.dart';
import '../../bloc/create/create_restaurant_state.dart';

class CreateRestaurantPage extends StatefulWidget {
  const CreateRestaurantPage({super.key});

  @override
  State<CreateRestaurantPage> createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationFieldKey = GlobalKey();

  // Basic Info
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.0');
  final _descriptionController = TextEditingController();
  final _offerController = TextEditingController();

  // Tax & Charges
  final _cgstController = TextEditingController(text: '0');
  final _sgstController = TextEditingController(text: '0');
  final _serviceChargeController = TextEditingController(text: '0');

  // Location
  final _locationController = TextEditingController();
  final _placeIdController = TextEditingController();

  // Price Range
  int? _minPrice;
  int? _maxPrice;

  // Image
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  // Weekly Timings
  final Map<String, bool> _closedDays = {};
  final Map<String, String> _fromTimes = {};
  final Map<String, String> _toTimes = {};

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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
    // Initialize weekly timings with defaults
    for (final day in _weekDays) {
      _closedDays[day] = false;
      _fromTimes[day] = '9:00 AM';
      _toTimes[day] = '10:00 PM';
    }
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
        if (!kIsWeb) {
          _selectedImage = File(image.path);
        }
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
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    title: Text(
                      suggestion.description,
                      style: AirMenuTextStyle.normal.copyWith(fontSize: 14),
                    ),
                    onTap: () {
                      _locationController.text = suggestion.description;
                      _placeIdController.text = suggestion.placeId;
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

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: _buildSectionHeader(title, icon),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRestaurantBloc(
        AdminRestaurantsRepository(locator<ApiService>()),
      ),
      child: BlocListener<CreateRestaurantBloc, CreateRestaurantState>(
        listener: (context, state) {
          if (state.submissionStatus == SubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage ?? 'Success')),
            );
            context.pop(true);
          } else if (state.submissionStatus == SubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Error'),
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
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: _buildAppBar(context),
          body: Builder(
            builder: (context) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Form(
                key: _formKey,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardSection(
                          title: 'Basic Information',
                          icon: Icons.restaurant,
                          child: _buildBasicInfoGrid(),
                        ),
                        const SizedBox(height: 24),
                        _buildCardSection(
                          title: 'Taxes & Charges',
                          icon: Icons.receipt_long,
                          child: _buildTaxGrid(),
                        ),
                        const SizedBox(height: 24),
                        _buildCardSection(
                          title: 'Location Details',
                          icon: Icons.location_on,
                          child: _buildLocationGrid(context),
                        ),
                        const SizedBox(height: 24),
                        _buildCardSection(
                          title: 'Description & Offer',
                          icon: Icons.description,
                          child: _buildDescriptionSection(),
                        ),
                        const SizedBox(height: 24),
                        _buildCardSection(
                          title: 'Main Image',
                          icon: Icons.image,
                          child: _buildImagePicker(),
                        ),
                        const SizedBox(height: 24),
                        _buildCardSection(
                          title: 'Weekly Timings',
                          icon: Icons.schedule,
                          child: _buildWeeklyTimings(),
                        ),
                        const SizedBox(height: 40),
                        _buildSubmitButton(context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Add New Restaurant',
        style: AirMenuTextStyle.headingH4.copyWith(
          color: const Color(0xFF111827),
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC52031).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFC52031), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AirMenuTextStyle.headingH4.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth > 600;
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
                hint: 'e.g. Italian, Indian, Chinese',
                prefixIcon: Icons.restaurant_menu,
                isRequired: true,
              ),
            ], isTwoColumn),
            const SizedBox(height: 20),
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
                onChanged: (val) => setState(() => _minPrice = val),
                prefix: '₹',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: _maxPrice,
                hint: 'Max Price',
                items: _priceOptions,
                onChanged: (val) => setState(() => _maxPrice = val),
                prefix: '₹',
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
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
        final isThreeColumn = constraints.maxWidth > 600;
        if (isThreeColumn) {
          return _buildRow([
            _buildTextField(
              label: 'CGST Rate (%)',
              controller: _cgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g., 9',
            ),
            _buildTextField(
              label: 'SGST Rate (%)',
              controller: _sgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g., 9',
            ),
            _buildTextField(
              label: 'Service Charge (%)',
              controller: _serviceChargeController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              hint: 'e.g., 5',
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
            const SizedBox(height: 16),
            _buildTextField(
              label: 'SGST Rate (%)',
              controller: _sgstController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
            const SizedBox(height: 16),
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
        const SizedBox(height: 20),
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
    final hasImage = _selectedImageBytes != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? Image.memory(
                    _selectedImageBytes!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library, size: 18),
              label: Text(hasImage ? 'Change Image' : 'Choose Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _selectedImage = null;
                  _selectedImageBytes = null;
                  _selectedImagePath = null;
                }),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Main image is required *',
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
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
          'Select opening and closing hours for each day. Check "Closed" if the restaurant is not open on a particular day.',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildDayTimingRow(String day) {
    final isClosed = _closedDays[day] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    day,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeDropdown(
                    value: _fromTimes[day]!,
                    enabled: !isClosed,
                    onChanged: (val) => setState(() => _fromTimes[day] = val!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'to',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTimeDropdown(
                    value: _toTimes[day]!,
                    enabled: !isClosed,
                    onChanged: (val) => setState(() => _toTimes[day] = val!),
                  ),
                ),
                const SizedBox(width: 12),
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
              const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'to',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(8),
          items: _timeSlots.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(
                time,
                style: AirMenuTextStyle.normal.copyWith(
                  fontSize: 13,
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
          width: 20,
          height: 20,
          child: Checkbox(
            value: isClosed,
            onChanged: (val) => setState(() => _closedDays[day] = val ?? false),
            activeColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Closed',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> children, bool isMultiColumn) {
    if (!isMultiColumn) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (e) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator:
              validator ??
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
                ? Icon(prefixIcon, size: 20, color: const Color(0xFF9CA3AF))
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFFC52031),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<CreateRestaurantBloc, CreateRestaurantState>(
      builder: (context, state) {
        final isLoading = state.submissionStatus == SubmissionStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC52031),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Create Restaurant',
                    style: AirMenuTextStyle.normal.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context) {
    _hideOverlay();

    // Validate image
    if (_selectedImageBytes == null || _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a main image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate price range
    if (_minPrice == null && _maxPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a price range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate location
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Build price string
      String priceString;
      if (_minPrice != null && _maxPrice != null) {
        priceString = '₹$_minPrice - ₹$_maxPrice';
      } else if (_minPrice != null) {
        priceString = 'Above ₹$_minPrice';
      } else {
        priceString = 'Under ₹$_maxPrice';
      }

      // Build weekly timings
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
        SubmitRestaurantWithImage(
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
          imagePath: _selectedImagePath!,
        ),
      );
    }
  }
}
