import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import '../../bloc/vendor_settings_bloc.dart';
import '../../bloc/vendor_settings_event.dart';
import '../../bloc/vendor_settings_state.dart';
import '../../widgets/vendor_settings_widgets.dart';
import '../../widgets/billing_widgets.dart';

class VendorSettingsDesktopView extends StatefulWidget {
  const VendorSettingsDesktopView({super.key});

  @override
  State<VendorSettingsDesktopView> createState() =>
      _VendorSettingsDesktopViewState();
}

class _VendorSettingsDesktopViewState
    extends State<VendorSettingsDesktopView> {
  final _nameCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _fssaiCtrl = TextEditingController();
  final _cgstCtrl = TextEditingController();
  final _sgstCtrl = TextEditingController();
  final _serviceChargeCtrl = TextEditingController();

  bool _controllersInitialized = false;
  Timer? _locationDebounce;
  final _imagePicker = ImagePicker();

  void _syncControllers(Map<String, dynamic> data) {
    _setIfChanged(_nameCtrl, data['restaurantName'] ?? '');
    _setIfChanged(_cuisineCtrl, data['cuisine'] ?? data['category'] ?? '');
    _setIfChanged(_locationCtrl, data['address'] ?? '');
    _setIfChanged(_distanceCtrl, data['distance'] ?? '');
    _setIfChanged(_minPriceCtrl, (data['minPrice'] ?? '').toString());
    _setIfChanged(_maxPriceCtrl, (data['maxPrice'] ?? '').toString());
    _setIfChanged(_ratingCtrl, (data['rating'] ?? '').toString());
    _setIfChanged(_descriptionCtrl, data['description'] ?? '');
    _setIfChanged(_gstinCtrl, data['gstin'] ?? '');
    _setIfChanged(_fssaiCtrl, data['fssai'] ?? '');
    _setIfChanged(_cgstCtrl, (data['cgstRate'] ?? '0').toString());
    _setIfChanged(_sgstCtrl, (data['sgstRate'] ?? '0').toString());
    _setIfChanged(_serviceChargeCtrl, (data['serviceCharge'] ?? '0').toString());
    _controllersInitialized = true;
  }

  void _setIfChanged(TextEditingController ctrl, String value) {
    if (ctrl.text != value) ctrl.text = value;
  }

  void _dispatchFieldUpdate(BuildContext context, String key, String value) {
    context.read<VendorSettingsBloc>().add(
      UpdateRestaurantField(key: key, value: value),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cuisineCtrl.dispose();
    _locationCtrl.dispose();
    _distanceCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _ratingCtrl.dispose();
    _descriptionCtrl.dispose();
    _gstinCtrl.dispose();
    _fssaiCtrl.dispose();
    _cgstCtrl.dispose();
    _sgstCtrl.dispose();
    _serviceChargeCtrl.dispose();
    _locationDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VendorSettingsBloc, VendorSettingsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Re-sync controllers with updated data from server response
          _controllersInitialized = false;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _syncControllers(state.data),
          );
        }
        if (state.errorMessage != null &&
            state.status != VendorSettingsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == VendorSettingsStatus.loading) {
          _controllersInitialized = false;
          return const VendorSettingsShimmer();
        }

        if (state.status == VendorSettingsStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<VendorSettingsBloc>()
                      .add(const LoadVendorSettings()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Sync controllers when data loads (only once or on reload)
        if (state.status == VendorSettingsStatus.success &&
            !_controllersInitialized) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _syncControllers(state.data),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar
                    SizedBox(
                      width: 250,
                      child: Column(
                        children: [
                          _SidebarItem(
                            icon: Icons.storefront,
                            title: 'Restaurant Info',
                            subtitle: 'Name, address, GST, FSSAI',
                            isSelected: state.currentTabIndex == 0,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(0),
                            ),
                          ),
                          _SidebarItem(
                            icon: Icons.access_time_rounded,
                            title: 'Timings',
                            subtitle: 'Operating hours and holidays',
                            isSelected: state.currentTabIndex == 1,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(1),
                            ),
                          ),
                          // _SidebarItem(
                          //   icon: Icons.notifications_outlined,
                          //   title: 'Notifications',
                          //   subtitle: 'Alert sounds and preferences',
                          //   isSelected: state.currentTabIndex == 2,
                          //   onTap: () => context.read<VendorSettingsBloc>().add(
                          //     const ChangeSettingsTab(2),
                          //   ),
                          // ),
                          // _SidebarItem(
                          //   icon: Icons.print_outlined,
                          //   title: 'Printers',
                          //   subtitle: 'Kitchen printer configuration',
                          //   isSelected: state.currentTabIndex == 3,
                          //   onTap: () => context.read<VendorSettingsBloc>().add(
                          //     const ChangeSettingsTab(3),
                          //   ),
                          // ),
                          // _SidebarItem(
                          //   icon: Icons.location_on_outlined,
                          //   title: 'Delivery',
                          //   subtitle: 'Radius and timing settings',
                          //   isSelected: state.currentTabIndex == 4,
                          //   onTap: () => context.read<VendorSettingsBloc>().add(
                          //     const ChangeSettingsTab(4),
                          //   ),
                          // ),
                          // _SidebarItem(
                          //   icon: Icons.credit_card_outlined,
                          //   title: 'Billing',
                          //   subtitle: 'Subscription and payments',
                          //   isSelected: state.currentTabIndex == 5,
                          //   onTap: () => context.read<VendorSettingsBloc>().add(
                          //     const ChangeSettingsTab(5),
                          //   ),
                          // ),
                       
                       
                       
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Content Area
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildContent(
                                context,
                                state.currentTabIndex,
                                state.data,
                              ),
                              if (state.currentTabIndex == 0 ||
                                  state.currentTabIndex == 1) ...[
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: state.isSaving
                                      ? null
                                      : () {
                                          if (state.currentTabIndex == 0) {
                                            context
                                                .read<VendorSettingsBloc>()
                                                .add(const SaveRestaurantInfo());
                                          } else {
                                            context
                                                .read<VendorSettingsBloc>()
                                                .add(const SaveTimings());
                                          }
                                        },
                                  icon: state.isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                          size: 18,
                                        ),
                                  label: Text(
                                    state.isSaving ? 'Saving...' : 'Save Changes',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AirMenuColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    int index,
    Map<String, dynamic> data,
  ) {
    switch (index) {
      case 0:
        return _buildRestaurantInfo(data);
      case 1:
        return _buildTimings(context, data);
      case 2:
        return _buildNotifications(data);
      case 3:
        return _buildPrinters(data);
      case 4:
        return _buildDelivery(data);
      case 5:
        return _buildBilling(data);
      default:
        return const SizedBox();
    }
  }

  // Price options matching Next.js: 100, 200, 300, ..., 5000
  static final _priceOptions = List.generate(50, (i) => (i + 1) * 100);

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<VendorSettingsBloc>().add(
        UploadMainImage(filePath: image.path),
      );
    }
  }

  Widget _buildRestaurantInfo(Map<String, dynamic> data) {
    final bloc = context.read<VendorSettingsBloc>();
    final state = bloc.state;
    final suggestions = state.locationSuggestions;
    final isSearching = state.isSearchingLocation;
    final isUploading = state.isUploadingImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Restaurant Information'),
        Row(
          children: [
            Expanded(
              child: _EditableField(
                label: 'Restaurant Name',
                controller: _nameCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'restaurantName', v),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'Cuisine',
                controller: _cuisineCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'cuisine', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Location with autocomplete (matching Next.js LocationInput)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AirMenuColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationCtrl,
                    onChanged: (v) {
                      _dispatchFieldUpdate(context, 'address', v);
                      _locationDebounce?.cancel();
                      _locationDebounce = Timer(const Duration(milliseconds: 300), () {
                        bloc.add(SearchLocation(query: v));
                      });
                    },
                    style: AirMenuTextStyle.normal,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AirMenuColors.primary),
                      ),
                      hintText: 'Start typing to search for a location...',
                      hintStyle: AirMenuTextStyle.normal.copyWith(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                    ),
                  ),
                  // Suggestions dropdown
                  if (suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: suggestions.length,
                        itemBuilder: (ctx, idx) {
                          final place = suggestions[idx];
                          final mainText = place['structured_formatting']?['main_text'] ?? place['description'] ?? '';
                          final secondaryText = place['structured_formatting']?['secondary_text'] ?? '';
                          return InkWell(
                            onTap: () {
                              final desc = (place['description'] ?? '').toString();
                              _locationCtrl.text = desc;
                              bloc.add(SelectLocationSuggestion(description: desc));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade500),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(mainText.toString(), style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w500)),
                                        if (secondaryText.toString().isNotEmpty)
                                          Text(secondaryText.toString(), style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
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
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'Distance',
                controller: _distanceCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'distance', v),
                hint: 'e.g., 2.5 km from city center',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price Range — dropdown selects matching Next.js (100 to 5000 step 100)
        Row(
          children: [
            Expanded(
              child: _PriceDropdown(
                label: 'Min Price',
                value: data['minPrice']?.toString() ?? '',
                options: _priceOptions,
                onChanged: (v) => _dispatchFieldUpdate(context, 'minPrice', v),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _PriceDropdown(
                label: 'Max Price',
                value: data['maxPrice']?.toString() ?? '',
                options: _priceOptions,
                onChanged: (v) => _dispatchFieldUpdate(context, 'maxPrice', v),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'Rating (0–5)',
                controller: _ratingCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'rating', v),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _EditableField(
          label: 'Description',
          controller: _descriptionCtrl,
          onChanged: (v) => _dispatchFieldUpdate(context, 'description', v),
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Main Image — display current + upload button (matching Next.js)
        Text(
          'Main Image',
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if ((data['mainImage'] ?? '').toString().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: data['mainImage'].toString(),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                ),
              ),
            ),
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No image uploaded', style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isUploading ? null : _pickAndUploadImage,
            icon: isUploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined, size: 18),
            label: Text(isUploading ? 'Uploading...' : 'Change Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AirMenuColors.primary,
              side: const BorderSide(color: AirMenuColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Leave empty to keep the current image',
            style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade500, fontSize: 11),
          ),
        ),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'Tax & Charges'),
        Row(
          children: [
            Expanded(
              child: _EditableField(
                label: 'CGST Rate (%)',
                controller: _cgstCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'cgstRate', v),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'SGST Rate (%)',
                controller: _sgstCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'sgstRate', v),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'Service Charge (%)',
                controller: _serviceChargeCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'serviceCharge', v),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Central and State GST rates (0-100%). Service charge as a percentage of subtotal.',
            style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade500, fontSize: 11),
          ),
        ),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'Compliance'),
        Row(
          children: [
            Expanded(
              child: _EditableField(
                label: 'GSTIN',
                controller: _gstinCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'gstin', v),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _EditableField(
                label: 'FSSAI License No.',
                controller: _fssaiCtrl,
                onChanged: (v) => _dispatchFieldUpdate(context, 'fssai', v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimings(BuildContext context, Map<String, dynamic> data) {
    final timings = data['timings'] as Map<String, dynamic>? ?? {};
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Operating Hours'),
        ...days.map(
          (day) {
            final dayData = timings[day] as Map<String, dynamic>? ?? {};
            return TimingRow(
              day: day,
              start: dayData['start'] ?? '11:00 AM',
              end: dayData['end'] ?? '11:00 PM',
              enabled: dayData['enabled'] ?? false,
              onToggle: (val) {
                context.read<VendorSettingsBloc>().add(
                  UpdateTiming(day: day, isEnabled: val),
                );
              },
              onStartTimeTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 11, minute: 0),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AirMenuColors.primary,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AirMenuColors.textPrimary,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AirMenuColors.primary,
                          ),
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          dialHandColor: AirMenuColors.primary,
                          hourMinuteColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary.withOpacity(0.1)
                                : Colors.grey.shade100,
                          ),
                          hourMinuteTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary
                                : AirMenuColors.textPrimary,
                          ),
                          dayPeriodBorderSide: const BorderSide(
                            color: AirMenuColors.primary,
                          ),
                          dayPeriodColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          dayPeriodTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary
                                : AirMenuColors.textSecondary,
                          ),
                          dialBackgroundColor: Colors.grey.shade50,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  context.read<VendorSettingsBloc>().add(
                    UpdateTiming(day: day, startTime: picked.format(context)),
                  );
                }
              },
              onEndTimeTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 23, minute: 0),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary:
                              AirMenuColors.primary, // Red header/dial selector
                          onPrimary: Colors.white, // Text on red background
                          surface: Colors.white, // Dialog background
                          onSurface:
                              AirMenuColors.textPrimary, // Body text color
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                AirMenuColors.primary, // Button text color
                          ),
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          dialHandColor: AirMenuColors.primary,
                          hourMinuteColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary.withOpacity(0.1)
                                : Colors.grey.shade100,
                          ),
                          hourMinuteTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary
                                : AirMenuColors.textPrimary,
                          ),
                          dayPeriodBorderSide: const BorderSide(
                            color: AirMenuColors.primary,
                          ),
                          dayPeriodColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          dayPeriodTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AirMenuColors.primary
                                : AirMenuColors.textSecondary,
                          ),
                          dialBackgroundColor: Colors.grey.shade50,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  context.read<VendorSettingsBloc>().add(
                    UpdateTiming(day: day, endTime: picked.format(context)),
                  );
                }
              },
            );
          },
        ), // Note: context might need to be captured if inside a builder that doesn't provide it directly, but in this structure it should be fine as it's within _buildTimings which is called from build()
      ],
    );
  }

  Widget _buildNotifications(Map<String, dynamic> data) {
    final prefs = data['notifications'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Notification Preferences'),
        SettingsToggleRow(
          title: 'New Order Alerts',
          subtitle: 'Sound notification for new orders',
          value: prefs['newOrder'] ?? true,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Kitchen Ready',
          subtitle: 'Alert when order is ready',
          value: prefs['kitchenReady'] ?? true,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Low Stock Alerts',
          subtitle: 'Inventory warnings',
          value: prefs['lowStock'] ?? false,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Feedback Notifications',
          subtitle: 'New customer reviews',
          value: prefs['feedback'] ?? false,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Staff Login Alerts',
          subtitle: 'Notify when staff logs in',
          value: prefs['staffLogin'] ?? false,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Delivery Updates',
          subtitle: 'Rider assignment and status',
          value: prefs['deliveryUpdates'] ?? true,
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildPrinters(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kitchen Printers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Printer'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const PrinterCard(
          name: 'Kitchen Printer',
          location: 'Main Kitchen',
          ip: '192.168.1.101',
          isConnected: true,
        ),
        const PrinterCard(
          name: 'Bar Printer',
          location: 'Bar',
          ip: '192.168.1.102',
          isConnected: true,
        ),
        const PrinterCard(
          name: 'Billing Printer',
          location: 'Cashier',
          ip: '192.168.1.103',
          isConnected: false,
        ),
      ],
    );
  }

  Widget _buildDelivery(Map<String, dynamic> data) {
    final delivery = data['delivery'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Delivery Settings'),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'Delivery Radius (km)',
                initialValue: delivery['radius'] ?? '10',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsTextField(
                label: 'Minimum Order Value (₹)',
                initialValue: delivery['minOrder'] ?? '200',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'Base Delivery Fee (₹)',
                initialValue: delivery['baseFee'] ?? '30',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsTextField(
                label: 'Free Delivery Above (₹)',
                initialValue: delivery['freeAbove'] ?? '500',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SettingsDropdown(
                label: 'Avg. Delivery Time',
                value:
                    delivery['avgTime'], // Make sure this matches one of the items exactly
                items: const ['20-30 mins', '30-45 mins', '45-60 mins'],
                onChanged: (val) {
                  // Update state logic would go here
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsDropdown(
                label: 'Delivery Partner',
                value: delivery['partner'],
                items: const ['Internal Fleet', 'Shadowfax', 'Dunzo', 'Porter'],
                onChanged: (val) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsToggleRow(
          title: 'Enable Delivery',
          subtitle: 'Accept delivery orders',
          value: delivery['enabled'] ?? true,
          onChanged: (val) {},
        ),
        SettingsToggleRow(
          title: 'Peak Hour Surge',
          subtitle: 'Increase delivery fee during peak hours',
          value: delivery['peakSurge'] ?? false,
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildBilling(Map<String, dynamic> data) {
    // Mock data for now, or extract from 'data' if available
    // In a real app, this would come from the BLoC state
    final billingData = {
      'planName': 'Premium',
      'price': '₹2,999/month',
      'renewalDate': 'Dec 15, 2024',
      'last4': '4532',
      'expiry': '12/26',
    };

    final history = [
      {'date': 'Nov 15, 2024', 'amount': '₹2,999'},
      {'date': 'Oct 15, 2024', 'amount': '₹2,999'},
      {'date': 'Sep 15, 2024', 'amount': '₹2,999'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Subscription & Billing'),
        SubscriptionPlanCard(data: billingData),
        const SizedBox(height: 32),
        const SettingsSectionHeader(title: 'Payment Method'),
        PaymentMethodCard(data: billingData),
        const SizedBox(height: 32),
        const SettingsSectionHeader(title: 'Billing History'),
        BillingHistoryList(history: history),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final String? hint;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AirMenuTextStyle.normal,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AirMenuColors.primary),
            ),
            hintText: hint,
            hintStyle: AirMenuTextStyle.normal.copyWith(
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AirMenuColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? null
            : Border.all(
                color: Colors.grey.shade300.withOpacity(0.40),
                width: 1.5,
              ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AirMenuColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : AirMenuColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AirMenuTextStyle.normal.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AirMenuColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AirMenuTextStyle.small.copyWith(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AirMenuColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}

class _PriceDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<int> options;
  final ValueChanged<String> onChanged;

  const _PriceDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Match the current value to an option
    final intVal = int.tryParse(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: (intVal != null && options.contains(intVal)) ? intVal : null,
          onChanged: (v) => onChanged(v?.toString() ?? ''),
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AirMenuColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: Text('Select', style: AirMenuTextStyle.normal.copyWith(color: Colors.grey.shade400)),
          items: options.map((p) => DropdownMenuItem<int>(
            value: p,
            child: Text('₹$p', style: AirMenuTextStyle.normal),
          )).toList(),
        ),
      ],
    );
  }
}
