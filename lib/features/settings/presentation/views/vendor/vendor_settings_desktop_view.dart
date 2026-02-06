import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import '../../bloc/vendor_settings_bloc.dart';
import '../../bloc/vendor_settings_event.dart';
import '../../bloc/vendor_settings_state.dart';
import '../../widgets/vendor_settings_widgets.dart';
import '../../widgets/billing_widgets.dart';

class VendorSettingsDesktopView extends StatelessWidget {
  const VendorSettingsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorSettingsBloc, VendorSettingsState>(
      builder: (context, state) {
        if (state.status == VendorSettingsStatus.loading) {
          return const VendorSettingsShimmer();
        }

        if (state.status == VendorSettingsStatus.failure) {
          return Center(child: Text('Error: ${state.errorMessage}'));
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
                          _SidebarItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Alert sounds and preferences',
                            isSelected: state.currentTabIndex == 2,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(2),
                            ),
                          ),
                          _SidebarItem(
                            icon: Icons.print_outlined,
                            title: 'Printers',
                            subtitle: 'Kitchen printer configuration',
                            isSelected: state.currentTabIndex == 3,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(3),
                            ),
                          ),
                          _SidebarItem(
                            icon: Icons.location_on_outlined,
                            title: 'Delivery',
                            subtitle: 'Radius and timing settings',
                            isSelected: state.currentTabIndex == 4,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(4),
                            ),
                          ),
                          _SidebarItem(
                            icon: Icons.credit_card_outlined,
                            title: 'Billing',
                            subtitle: 'Subscription and payments',
                            isSelected: state.currentTabIndex == 5,
                            onTap: () => context.read<VendorSettingsBloc>().add(
                              const ChangeSettingsTab(5),
                            ),
                          ),
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
                              if (state.currentTabIndex != 5) ...[
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.save_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Save Changes'),
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

  Widget _buildRestaurantInfo(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Restaurant Information'),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'Restaurant Name',
                initialValue: data['restaurantName'] ?? '',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsTextField(
                label: 'Phone',
                initialValue: data['phone'] ?? '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'Email',
                initialValue: data['email'] ?? '',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsTextField(
                label: 'Category',
                initialValue: data['category'] ?? '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsTextField(
          label: 'Address',
          initialValue: data['address'] ?? '',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                label: 'GSTIN',
                initialValue: data['gstin'] ?? '',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SettingsTextField(
                label: 'FSSAI License',
                initialValue: data['fssai'] ?? '',
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
