import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import '../../bloc/vendor_settings_bloc.dart';
import '../../bloc/vendor_settings_event.dart';
import '../../bloc/vendor_settings_state.dart';
import '../../widgets/vendor_settings_widgets.dart';
import '../../widgets/billing_widgets.dart';
// Actually better to duplicate the _buildContent methods or make them static mixins to avoid large imports.
// I will duplicate specific build methods here to assume "Mobile" specific tweaks might be needed (like dense padding).

class VendorSettingsMobileView extends StatelessWidget {
  const VendorSettingsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorSettingsBloc, VendorSettingsState>(
      builder: (context, state) {
        if (state.status == VendorSettingsStatus.loading) {
          return const VendorSettingsMobileShimmer();
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Column(
            children: [
              // Mobile Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Horizontal Scrollable Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _MobileTab(
                            title: 'Info',
                            isSelected: state.currentTabIndex == 0,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(0),
                            ),
                          ),
                          _MobileTab(
                            title: 'Timings',
                            isSelected: state.currentTabIndex == 1,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(1),
                            ),
                          ),
                          _MobileTab(
                            title: 'Alerts',
                            isSelected: state.currentTabIndex == 2,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(2),
                            ),
                          ),
                          _MobileTab(
                            title: 'Printers',
                            isSelected: state.currentTabIndex == 3,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(3),
                            ),
                          ),
                          _MobileTab(
                            title: 'Delivery',
                            isSelected: state.currentTabIndex == 4,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(4),
                            ),
                          ),
                          _MobileTab(
                            title: 'Billing',
                            isSelected: state.currentTabIndex == 5,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Re-implementing simplified content builders for mobile
                      if (state.currentTabIndex == 0)
                        _buildRestaurantInfo(state.data),
                      if (state.currentTabIndex == 1)
                        _buildTimings(context, state.data),
                      if (state.currentTabIndex == 2)
                        _buildNotifications(state.data),
                      if (state.currentTabIndex == 3)
                        _buildPrinters(state.data),
                      if (state.currentTabIndex == 4)
                        _buildDelivery(state.data),
                      if (state.currentTabIndex == 5) _buildBilling(state.data),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AirMenuColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Mobile Specific Content Builders ---

  Widget _buildRestaurantInfo(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTextField(
          label: 'Restaurant Name',
          initialValue: data['restaurantName'] ?? '',
        ),
        const SizedBox(height: 16),
        SettingsTextField(label: 'Phone', initialValue: data['phone'] ?? ''),
        const SizedBox(height: 16),
        SettingsTextField(label: 'Email', initialValue: data['email'] ?? ''),
        const SizedBox(height: 16),
        SettingsTextField(
          label: 'Category',
          initialValue: data['category'] ?? '',
        ),
        const SizedBox(height: 16),
        SettingsTextField(
          label: 'Address',
          initialValue: data['address'] ?? '',
        ),
        const SizedBox(height: 16),
        SettingsTextField(label: 'GSTIN', initialValue: data['gstin'] ?? ''),
        const SizedBox(height: 16),
        SettingsTextField(
          label: 'FSSAI License',
          initialValue: data['fssai'] ?? '',
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
      children: days.map((day) {
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
                UpdateTiming(day: day, endTime: picked.format(context)),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildNotifications(Map<String, dynamic> data) {
    final prefs = data['notifications'] as Map<String, dynamic>? ?? {};
    return Column(
      children: [
        SettingsToggleRow(
          title: 'New Order Alerts',
          subtitle: 'Sound notification',
          value: prefs['newOrder'] ?? true,
          onChanged: (v) {},
        ),
        SettingsToggleRow(
          title: 'Kitchen Ready',
          subtitle: 'Alert when ready',
          value: prefs['kitchenReady'] ?? true,
          onChanged: (v) {},
        ),
        SettingsToggleRow(
          title: 'Low Stock',
          subtitle: 'Inventory warning',
          value: prefs['lowStock'] ?? false,
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildPrinters(Map<String, dynamic> data) {
    return Column(
      children: [
        const PrinterCard(
          name: 'Kitchen',
          location: 'Main',
          ip: '192.168.1.101',
          isConnected: true,
        ),
        const PrinterCard(
          name: 'Bar',
          location: 'Bar',
          ip: '192.168.1.102',
          isConnected: true,
        ),
      ],
    );
  }

  Widget _buildDelivery(Map<String, dynamic> data) {
    final d = data['delivery'] as Map<String, dynamic>? ?? {};
    return Column(
      children: [
        SettingsTextField(
          label: 'Radius (km)',
          initialValue: d['radius'] ?? '10',
        ),
        const SizedBox(height: 16),
        SettingsTextField(
          label: 'Min Order',
          initialValue: d['minOrder'] ?? '200',
        ),
        const SizedBox(height: 16),
        SettingsDropdown(
          label: 'Avg. Delivery Time',
          value: d['avgTime'],
          items: const ['20-30 mins', '30-45 mins', '45-60 mins'],
          onChanged: (val) {},
        ),
        const SizedBox(height: 16),
        SettingsDropdown(
          label: 'Delivery Partner',
          value: d['partner'], // Ensure value matches items
          items: const ['Internal Fleet', 'Shadowfax', 'Dunzo', 'Porter'],
          onChanged: (val) {},
        ),
        const SizedBox(height: 16),
        SettingsToggleRow(
          title: 'Enable Delivery',
          subtitle: 'Accept orders',
          value: d['enabled'] ?? true,
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildBilling(Map<String, dynamic> data) {
    // Mock data
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
      children: [
        const SettingsSectionHeader(title: 'Subscription'),
        SubscriptionPlanCard(data: billingData),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'Payment Method'),
        PaymentMethodCard(data: billingData),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'History'),
        BillingHistoryList(history: history),
      ],
    );
  }
}

class _MobileTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AirMenuColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AirMenuColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.0 : 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
