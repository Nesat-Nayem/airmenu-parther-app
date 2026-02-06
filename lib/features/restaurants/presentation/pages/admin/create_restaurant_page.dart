import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final _ratingController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _offerController = TextEditingController();
  final _mainImageController = TextEditingController();
  final _priceController = TextEditingController();
  final _distanceController = TextEditingController();
  final _vendorIdController = TextEditingController();

  // Tax & Charges
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _serviceChargeController = TextEditingController();

  // Location
  final _locationController = TextEditingController();
  final _placeIdController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _ratingController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _offerController.dispose();
    _mainImageController.dispose();
    _priceController.dispose();
    _distanceController.dispose();
    _vendorIdController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _serviceChargeController.dispose();
    _locationController.dispose();
    _placeIdController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    _hideOverlay();
    super.dispose();
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
                      _addressController.text = suggestion.description;
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
                hint: 'e.g. Petpooja Kitchen',
                prefixIcon: Icons.store,
                isRequired: true,
              ),
              _buildTextField(
                label: 'Cuisine',
                controller: _cuisineController,
                hint: 'e.g. North Indian, Chinese',
                prefixIcon: Icons.restaurant_menu,
                isRequired: true,
              ),
            ], isTwoColumn),
            const SizedBox(height: 20),
            _buildRow([
              _buildTextField(
                label: 'Restaurant Type',
                controller: _typeController,
                hint: 'on/off',
                prefixIcon: Icons.category,
              ),
              _buildTextField(
                label: 'Price Range',
                controller: _priceController,
                hint: '₹100 - ₹200',
                prefixIcon: Icons.payments,
                isRequired: true,
              ),
            ], isTwoColumn),
            const SizedBox(height: 20),
            _buildRow([
              _buildTextField(
                label: 'Main Image URL',
                controller: _mainImageController,
                hint: 'https://...',
                prefixIcon: Icons.image,
                isRequired: true,
              ),
              _buildTextField(
                label: 'Vendor ID',
                controller: _vendorIdController,
                hint: 'Required',
                prefixIcon: Icons.person,
                isRequired: true,
              ),
            ], isTwoColumn),
            const SizedBox(height: 20),
            _buildRow([
              _buildTextField(
                label: 'Rating',
                controller: _ratingController,
                hint: 'e.g. 4.5',
                prefixIcon: Icons.star,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: 'Distance',
                controller: _distanceController,
                hint: 'e.g. 2.5 km',
                prefixIcon: Icons.directions_walk,
                isRequired: true,
              ),
            ], isTwoColumn),
          ],
        );
      },
    );
  }

  Widget _buildTaxGrid() {
    return _buildRow([
      _buildTextField(
        label: 'CGST (%)',
        controller: _cgstController,
        keyboardType: TextInputType.number,
        prefixIcon: Icons.percent,
      ),
      _buildTextField(
        label: 'SGST (%)',
        controller: _sgstController,
        keyboardType: TextInputType.number,
        prefixIcon: Icons.percent,
      ),
      _buildTextField(
        label: 'Service Charge (%)',
        controller: _serviceChargeController,
        keyboardType: TextInputType.number,
        prefixIcon: Icons.percent,
      ),
    ], true);
  }

  Widget _buildLocationGrid(BuildContext context) {
    return Column(
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: _buildTextField(
            key: _locationFieldKey,
            label: 'Location / Address',
            controller: _locationController,
            hint: 'Search for address...',
            prefixIcon: Icons.search,
            isRequired: true,
            onChanged: (val) {
              context.read<CreateRestaurantBloc>().add(
                UpdateAutocompleteQuery(val),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildRow([
          _buildTextField(
            label: 'Latitude',
            controller: _latController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.gps_fixed,
          ),
          _buildTextField(
            label: 'Longitude',
            controller: _lngController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.gps_fixed,
          ),
        ], true),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      children: [
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Enter restaurant description...',
          maxLines: 4,
          prefixIcon: Icons.notes,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Special Offer',
          controller: _offerController,
          hint: 'e.g. 20% OFF on all orders',
          prefixIcon: Icons.local_offer,
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
    if (_formKey.currentState!.validate()) {
      final request = RestaurantCreateRequestModel(
        name: _nameController.text,
        cuisine: _cuisineController.text,
        rating: double.tryParse(_ratingController.text),
        description: _descriptionController.text,
        offer: _offerController.text.isNotEmpty ? _offerController.text : null,
        mainImage: _mainImageController.text.isNotEmpty
            ? _mainImageController.text
            : null,
        galleryImages: [], // Simplified for now
        location: _locationController.text,
        googlePlaceId: _placeIdController.text.isNotEmpty
            ? _placeIdController.text
            : null,
        coordinates:
            (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
            ? CoordinatesModel(
                coordinates: [
                  double.tryParse(_lngController.text) ?? 0.0,
                  double.tryParse(_latController.text) ?? 0.0,
                ],
                address: _addressController.text.isEmpty
                    ? _locationController.text
                    : _addressController.text,
              )
            : null,
        distance: _distanceController.text,
        price: _priceController.text,
        weeklyTimings: _getDefaultTimings(),
        menuCategories: _getDefaultMenuCategories(),
        buffets: [],
        reviews: [],
        preBookOffers: [],
        walkInOffers: [],
        bankBenefits: [],
        aboutInfo: null,
        vendorId: _vendorIdController.text.isNotEmpty
            ? _vendorIdController.text
            : null,
        mallId: null,
        cgstRate: num.tryParse(_cgstController.text),
        sgstRate: num.tryParse(_sgstController.text),
        serviceCharge: num.tryParse(_serviceChargeController.text),
      );

      context.read<CreateRestaurantBloc>().add(SubmitRestaurant(request));
    }
  }

  List<WeeklyTimingModel> _getDefaultTimings() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days
        .map((day) => WeeklyTimingModel(day: day, hours: '12:00 AM - 10:00 PM'))
        .toList();
  }

  List<MenuCategoryModel> _getDefaultMenuCategories() {
    return [
      MenuCategoryModel(
        name: 'Starters',
        image: 'https://example.com/cat.jpg',
        items: [],
      ),
    ];
  }
}
