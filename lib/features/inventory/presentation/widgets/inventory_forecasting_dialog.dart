import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/forecasting_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/create_po_dialog.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class InventoryForecastingDialog extends StatelessWidget {
  const InventoryForecastingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForecastingCubit(),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 1100,
        height: isMobile ? MediaQuery.of(context).size.height * 0.9 : 800,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header & Banner
            const _HeaderSection(),

            if (isMobile)
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _KPIGrid(),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            _ReorderScheduleList(),
                            SizedBox(height: 24),
                            _StockProjectionPanel(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // KPIs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _KPIGrid(),
              ),

              // Main Split View
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel: Reorder Schedule
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const _ReorderScheduleList(),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Panel: Charts
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const _StockProjectionPanel(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          // Top Row: Title & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Inventory Forecasting',
                                style: AirMenuTextStyle.headingH4.withColor(
                                  const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI-powered predictions for stock depletion and reorder timing',
                        style: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _TimeRangeDropdown(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inventory Forecasting',
                                style: AirMenuTextStyle.headingH4.withColor(
                                  const Color(0xFF111827),
                                ),
                              ),
                              Text(
                                'AI-powered predictions for stock depletion and reorder timing',
                                style: AirMenuTextStyle.small
                                    .medium500()
                                    .withColor(const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const _TimeRangeDropdown(),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // Urgent Banner
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 0,
            ).copyWith(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: InventoryColors.primaryRed,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Urgent: 2 items need reorder now',
                              style: AirMenuTextStyle.normal
                                  .bold700()
                                  .withColor(const Color(0xFFB91C1C)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _UrgentChip(label: 'Paneer - 2d left'),
                          _UrgentChip(label: 'Chicken - 3d left'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const CreatePurchaseOrderDialog(),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                          ),
                          label: const Text('Create Urgent PO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InventoryColors.primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Urgent: 2 items need reorder now',
                        style: AirMenuTextStyle.normal.bold700().withColor(
                          const Color(0xFFB91C1C),
                        ),
                      ),
                      const Spacer(),
                      const _UrgentChip(label: 'Paneer - 2d left'),
                      const SizedBox(width: 8),
                      const _UrgentChip(label: 'Chicken - 3d left'),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const CreatePurchaseOrderDialog(),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: const Text('Create Urgent PO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Custom Dropdown from Screenshot
class _TimeRangeDropdown extends StatelessWidget {
  const _TimeRangeDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForecastingCubit, ForecastingState>(
      builder: (context, state) {
        final current = (state as ForecastingInitial).selectedTimeRange;
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            _buildItem(context, 'Next 7 Days', current == 'Next 7 Days'),
            _buildItem(context, 'Next 14 Days', current == 'Next 14 Days'),
            _buildItem(context, 'Next 30 Days', current == 'Next 30 Days'),
          ],
          onSelected: (value) =>
              context.read<ForecastingCubit>().selectTimeRange(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  current,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildItem(
    BuildContext context,
    String text,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF2F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, size: 14, color: Color(0xFFEF4444)),
              ),
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentChip extends StatelessWidget {
  final String label;
  const _UrgentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFECACA).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.tiny.bold700().withColor(
          const Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _KPIGrid extends StatelessWidget {
  const _KPIGrid();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _KPI(
                  label: 'Critical (≤3 days)',
                  value: '2',
                  color: const Color(0xFFFEF2F2),
                  textColor: const Color(0xFFB91C1C),
                  borderColor: const Color(0xFFFECACA),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KPI(
                  label: 'Warning (4-5 days)',
                  value: '1',
                  color: const Color(0xFFFFFBEB),
                  textColor: const Color(0xFFB45309),
                  borderColor: const Color(0xFFFDE68A),
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KPI(
                  label: 'Healthy (>5 days)',
                  value: '2',
                  color: const Color(0xFFECFDF5),
                  textColor: const Color(0xFF047857),
                  borderColor: const Color(0xFFA7F3D0),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KPI(
                  label: 'Avg Confidence',
                  value: '90%',
                  color: const Color(0xFFFEF2F2),
                  textColor: const Color(0xFFB91C1C),
                  borderColor: const Color(0xFFFECACA),
                  icon: Icons.auto_awesome,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _KPI(
            label: 'Critical (≤3 days)',
            value: '2',
            color: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFB91C1C),
            borderColor: const Color(0xFFFECACA),
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPI(
            label: 'Warning (4-5 days)',
            value: '1',
            color: const Color(0xFFFFFBEB),
            textColor: const Color(0xFFB45309),
            borderColor: const Color(0xFFFDE68A),
            icon: Icons.access_time,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPI(
            label: 'Healthy (>5 days)',
            value: '2',
            color: const Color(0xFFECFDF5),
            textColor: const Color(0xFF047857),
            borderColor: const Color(0xFFA7F3D0),
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPI(
            label: 'Avg Confidence',
            value: '90%',
            color: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFB91C1C),
            borderColor: const Color(0xFFFECACA),
            icon: Icons.auto_awesome,
          ),
        ),
      ],
    );
  }
}

class _KPI extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  const _KPI({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AirMenuTextStyle.headingH2.bold700().withColor(textColor),
          ),
        ],
      ),
    );
  }
}

class _ReorderScheduleList extends StatelessWidget {
  const _ReorderScheduleList();

  @override
  Widget build(BuildContext context) {
    final scheduleItems = Column(
      children: const [
        _ScheduleItem(
          id: 'paneer',
          name: 'Paneer',
          daysLeft: '2d left',
          stock: '2 kg',
          use: '1.2 kg',
          reorder: 'Today',
          conf: '92%',
          isCritical: true,
        ),
        SizedBox(height: 12),
        _ScheduleItem(
          id: 'chicken',
          name: 'Chicken',
          daysLeft: '3d left',
          stock: '8 kg',
          use: '2.5 kg',
          reorder: 'Tomorrow',
          conf: '88%',
          isWarning: true,
        ),
        SizedBox(height: 12),
        _ScheduleItem(
          id: 'cream',
          name: 'Fresh Cream',
          daysLeft: '4d left',
          stock: '3 L',
          use: '0.8 L',
          reorder: 'In 2 days',
          conf: '85%',
          isWarning: true,
        ),
        SizedBox(height: 12),
        _ScheduleItem(
          id: 'rice',
          name: 'Basmati Rice',
          daysLeft: '8d left',
          stock: '25 kg',
          use: '3.2 kg',
          reorder: 'In 5 days',
          conf: '90%',
          isHealthy: true,
        ),
        SizedBox(height: 12),
        _ScheduleItem(
          id: 'oil',
          name: 'Cooking Oil',
          daysLeft: '8d left',
          stock: '12 L',
          use: '1.5 L',
          reorder: 'In 5 days',
          conf: '94%',
          isHealthy: true,
        ),
        SizedBox(height: 24),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Reorder Schedule',
            style: AirMenuTextStyle.headingH3.withColor(
              const Color(0xFF111827),
            ),
          ),
        ),
        Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: scheduleItems,
              )
            : Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  child: scheduleItems,
                ),
              ),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String id;
  final String name;
  final String daysLeft;
  final String stock;
  final String use;
  final String reorder;
  final String conf;
  final bool isCritical;
  final bool isWarning;
  final bool isHealthy;

  const _ScheduleItem({
    required this.id,
    required this.name,
    required this.daysLeft,
    required this.stock,
    required this.use,
    required this.reorder,
    required this.conf,
    this.isCritical = false,
    this.isWarning = false,
    this.isHealthy = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForecastingCubit, ForecastingState>(
      builder: (context, state) {
        final isSelected = (state as ForecastingInitial).selectedItemId == id;

        Color bg = Colors.white;
        Color border = const Color(0xFFE5E7EB);
        if (isCritical) {
          bg = const Color(0xFFFEF2F2);
          border = const Color(0xFFFECACA);
        } else if (isWarning) {
          bg = const Color(0xFFFFFBEB);
          border = const Color(0xFFFDE68A);
        } else if (isHealthy) {
          bg = const Color(0xFFECFDF5);
          border = const Color(0xFFA7F3D0);
        }

        // Selection Override style slightly if selected (border gets thicker/darker)
        if (isSelected) {
          border = isCritical
              ? const Color(0xFFEF4444)
              : (isWarning ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
        }

        return GestureDetector(
          onTap: () => context.read<ForecastingCubit>().selectItem(id),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: isSelected ? 2 : 1),
                boxShadow: isSelected
                    ? [BoxShadow(color: border.withOpacity(0.3), blurRadius: 8)]
                    : [],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: AirMenuTextStyle.normal.bold600().withColor(
                              const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            daysLeft,
                            style: AirMenuTextStyle.small.bold600().withColor(
                              isCritical
                                  ? const Color(0xFFDC2626)
                                  : (isWarning
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF059669)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatColumn(label: 'Stock', value: stock),
                          _StatColumn(label: 'Daily Use', value: use),
                          _StatColumn(
                            label: 'Reorder',
                            value: reorder,
                            isValueColor: true,
                            color: isCritical
                                ? const Color(0xFFDC2626)
                                : (isWarning
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF059669)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      LayoutBuilder(
                        builder: (context, constraints) {
                          Color barColor = isCritical
                              ? const Color(0xFFEF4444)
                              : (isWarning
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981));
                          return Stack(
                            children: [
                              Container(
                                height: 4,
                                width:
                                    constraints.maxWidth *
                                    0.8, // leave space for text
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                height: 4,
                                width:
                                    constraints.maxWidth * 0.4, // Mock progress
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$conf conf.',
                          style: AirMenuTextStyle.tiny.medium500().withColor(
                            const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      right: -10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Icon(Icons.arrow_right, color: border, size: 24),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isValueColor;
  final Color? color;

  const _StatColumn({
    required this.label,
    required this.value,
    this.isValueColor = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.medium500().withColor(
            const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: isValueColor && color != null
              ? AirMenuTextStyle.small.bold600().withColor(color!)
              : AirMenuTextStyle.small.bold600().withColor(
                  const Color(0xFF111827),
                ),
        ),
      ],
    );
  }
}

class _StockProjectionPanel extends StatelessWidget {
  const _StockProjectionPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForecastingCubit, ForecastingState>(
      builder: (context, state) {
        final itemId = (state as ForecastingInitial).selectedItemId;
        final itemNames = {
          'paneer': 'Paneer',
          'chicken': 'Chicken',
          'cream': 'Fresh Cream',
          'rice': 'Basmati Rice',
          'oil': 'Cooking Oil',
        };
        final itemName = itemNames[itemId] ?? 'Paneer';

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Projection',
                      style: AirMenuTextStyle.headingH3.withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      itemName,
                      style: AirMenuTextStyle.normal.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_down,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ), // Decreasing
                      const SizedBox(width: 4),
                      Text(
                        'decreasing',
                        style: AirMenuTextStyle.small.bold600().withColor(
                          const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mock Chart
            Container(
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                ), // Placeholder for chart
              ),
              child: CustomPaint(
                painter: _ForecastingChartPainter(),
                child: Stack(
                  children: [
                    Positioned(
                      left: 100,
                      top: 80,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day 1',
                              style: AirMenuTextStyle.normal.bold600(),
                            ),
                            Text(
                              'Stock : 0.8 kg',
                              style: AirMenuTextStyle.small
                                  .medium500()
                                  .withColor(const Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Recommendation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Recommendation',
                        style: AirMenuTextStyle.large.bold600().withColor(
                          const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on 92% confidence analysis of 30-day consumption patterns, we recommend ordering 9 kg of $itemName by Today to maintain optimal stock levels and avoid stockouts.',
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (Responsive.isMobile(context)) {
          return Padding(padding: const EdgeInsets.all(24), child: content);
        } else {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(child: content),
          );
        }
      },
    );
  }
}

class _ForecastingChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid with dash lines
    final paintGrid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashWidth = 4;
    final dashSpace = 4;

    // Vertical lines
    for (int i = 0; i <= 6; i++) {
      double x = i * (size.width / 6);
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, startY + dashWidth),
          paintGrid,
        );
        startY += dashWidth + dashSpace;
      }
    }

    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      double y = i * (size.height / 4);
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + dashWidth, y),
          paintGrid,
        );
        startX += dashWidth + dashSpace;
      }
    }

    // Draw curve - High to Zero
    final paintLine = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, 0); // Start Top Left (High stock)
    path.lineTo(
      size.width * 0.3,
      size.height,
    ); // Hits zero at 30% width (Day 2)
    path.lineTo(size.width, size.height); // Stays at zero

    canvas.drawPath(path, paintLine);

    // Fill below curve
    final paintFill = Paint()
      ..color = const Color(0xFFDC2626).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final pathFill = Path();
    pathFill.moveTo(0, 0);
    pathFill.lineTo(size.width * 0.3, size.height);
    pathFill.lineTo(0, size.height);
    pathFill.close();
    canvas.drawPath(pathFill, paintFill);

    // Dot at start
    canvas.drawCircle(
      const Offset(0, 0),
      4,
      Paint()..color = const Color(0xFFDC2626),
    );
    // Dot at Day 1
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.5),
      4,
      Paint()..color = const Color(0xFFDC2626),
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.5),
      2,
      Paint()..color = Colors.white,
    );

    // Axis Labels (Mocked manually)
    // Not drawing text manually to keep simple, standard widget composition usually handles this better, but this is a bg painter.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
