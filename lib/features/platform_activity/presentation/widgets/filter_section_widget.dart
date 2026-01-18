import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/bloc/platform_activity_bloc.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class FilterSectionWidget extends StatefulWidget {
  final bool isVertical;

  const FilterSectionWidget({super.key, this.isVertical = false});

  @override
  State<FilterSectionWidget> createState() => _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends State<FilterSectionWidget> {
  String? selectedRole;
  String? selectedAction;
  String? selectedEntityType;
  int selectedLimit = 20;

  final List<String> roles = ['All', 'admin', 'vendor', 'user'];
  final List<String> actions = ['All', 'create', 'update', 'delete', 'restore'];
  final List<String> entityTypes = [
    'All',
    'restaurant',
    'menu_category',
    'menu_item',
    'buffet',
    'offer',
    'about_info',
  ];
  final List<int> limits = [10, 20, 50];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformActivityBloc, PlatformActivityState>(
      builder: (context, state) {
        if (state is PlatformActivityLoaded) {
          selectedRole = state.actorRole;
          selectedAction = state.action;
          selectedEntityType = state.entityType;
          selectedLimit = state.limit;
        }

        if (widget.isVertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoleFilter(),
              const SizedBox(height: 12),
              _buildActionFilter(),
              const SizedBox(height: 12),
              _buildEntityTypeFilter(),
              const SizedBox(height: 12),
              _buildLimitFilter(),
              const SizedBox(height: 16),
              _buildClearFiltersButton(),
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 180, child: _buildRoleFilter()),
            SizedBox(width: 180, child: _buildActionFilter()),
            SizedBox(width: 200, child: _buildEntityTypeFilter()),
            SizedBox(width: 150, child: _buildLimitFilter()),
            _buildClearFiltersButton(),
          ],
        );
      },
    );
  }

  Widget _buildRoleFilter() {
    return _buildDropdown(
      label: 'Role',
      value: selectedRole ?? 'All',
      items: roles,
      onChanged: (value) {
        setState(() {
          selectedRole = value == 'All' ? null : value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildActionFilter() {
    return _buildDropdown(
      label: 'Action',
      value: selectedAction ?? 'All',
      items: actions,
      onChanged: (value) {
        setState(() {
          selectedAction = value == 'All' ? null : value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildEntityTypeFilter() {
    return _buildDropdown(
      label: 'Entity Type',
      value: selectedEntityType ?? 'All',
      items: entityTypes,
      onChanged: (value) {
        setState(() {
          selectedEntityType = value == 'All' ? null : value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildLimitFilter() {
    return _buildDropdown(
      label: 'Per Page',
      value: selectedLimit.toString(),
      items: limits.map((e) => e.toString()).toList(),
      onChanged: (value) {
        setState(() {
          selectedLimit = int.parse(value!);
        });
        _applyFilters();
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.secondary.shade5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AirMenuColors.secondary.shade8, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    _formatLabel(item),
                    style: AirMenuTextStyle.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    final hasFilters =
        selectedRole != null ||
        selectedAction != null ||
        selectedEntityType != null;

    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          selectedRole = null;
          selectedAction = null;
          selectedEntityType = null;
          selectedLimit = 20;
        });
        context.read<PlatformActivityBloc>().add(ClearFilters());
      },
      icon: const Icon(Icons.clear, size: 18),
      label: const Text('Clear Filters'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AirMenuColors.secondary.shade3,
        foregroundColor: AirMenuColors.secondary.shade8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _applyFilters() {
    context.read<PlatformActivityBloc>().add(
      ApplyFilters(
        actorRole: selectedRole,
        action: selectedAction,
        entityType: selectedEntityType,
        limit: selectedLimit,
      ),
    );
  }

  String _formatLabel(String value) {
    if (value == 'All') return value;
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
