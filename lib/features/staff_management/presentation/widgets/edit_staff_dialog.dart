import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/staff_model.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';

class EditStaffDialog extends StatefulWidget {
  final StaffModel staff;

  const EditStaffDialog({super.key, required this.staff});

  @override
  State<EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<EditStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  late String _selectedRole;
  late String _selectedShift;
  late StaffPermissions _permissions;

  final List<String> _roles = [
    'Manager',
    'Head Chef',
    'Kitchen Staff',
    'Waiter',
    'Cashier',
    'Delivery',
  ];

  final List<String> _shifts = ['Morning', 'Evening', 'All Day'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.name);
    _phoneController = TextEditingController(text: widget.staff.phone);
    _emailController = TextEditingController(text: widget.staff.email);
    _selectedRole = widget.staff.staffRole ?? 'Waiter';
    _selectedShift = widget.staff.shift ?? 'Morning';
    _permissions = widget.staff.permissions;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<StaffBloc>().add(
        UpdateStaff(
          id: widget.staff.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          staffRole: _selectedRole,
          shift: _selectedShift,
          permissions: _permissions,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Staff Member',
                      style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name & Phone Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Full Name *',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Phone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  label: 'Email *',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role & Shift Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Role',
                        value: _selectedRole,
                        items: _roles,
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Shift',
                        value: _selectedShift,
                        items: _shifts,
                        onChanged: (v) => setState(() => _selectedShift = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Permissions
                Text(
                  'Permissions',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPermissionTile(
                  title: 'Orders',
                  subtitle: 'View and manage orders',
                  value: _permissions.orders,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(orders: v);
                  }),
                ),
                _buildPermissionTile(
                  title: 'Menu',
                  subtitle: 'Edit menu items and categories',
                  value: _permissions.menu,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(menu: v);
                  }),
                ),
                _buildPermissionTile(
                  title: 'Inventory',
                  subtitle: 'Manage stock and ingredients',
                  value: _permissions.inventory,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(inventory: v);
                  }),
                ),
                _buildPermissionTile(
                  title: 'Staff',
                  subtitle: 'Manage staff members',
                  value: _permissions.staff,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(staff: v);
                  }),
                ),
                _buildPermissionTile(
                  title: 'Reports',
                  subtitle: 'View analytics and reports',
                  value: _permissions.reports,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(reports: v);
                  }),
                ),
                _buildPermissionTile(
                  title: 'Settings',
                  subtitle: 'Change restaurant settings',
                  value: _permissions.settings,
                  onChanged: (v) => setState(() {
                    _permissions = _permissions.copyWith(settings: v);
                  }),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.sora(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.sora(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: value
              ? const Color(0xFFDC2626).withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(10),
        color: value ? const Color(0xFFDC2626).withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }
}
