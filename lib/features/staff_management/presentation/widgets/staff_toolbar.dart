import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class StaffToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddStaff;

  const StaffToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddStaff,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        if (isMobile) {
          return _buildMobileToolbar();
        }
        return _buildDesktopToolbar();
      },
    );
  }

  Widget _buildMobileToolbar() {
    return Column(
      children: [
        // Search field full width
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: AirMenuTextStyle.normal,
          decoration: InputDecoration(
            hintText: 'Search staff...',
            hintStyle: AirMenuTextStyle.normal.withColor(Colors.grey.shade400),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        // Add button full width
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddStaff,
            icon: const Icon(Icons.add, size: 20),
            label: Text('Add Staff', style: AirMenuTextStyle.normal.bold600()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        // Search field
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: AirMenuTextStyle.normal,
            decoration: InputDecoration(
              hintText: 'Search staff...',
              hintStyle: AirMenuTextStyle.normal.withColor(
                Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        // Add Staff button
        ElevatedButton.icon(
          onPressed: onAddStaff,
          icon: const Icon(Icons.add, size: 20),
          label: Text('Add Staff', style: AirMenuTextStyle.normal.bold600()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
