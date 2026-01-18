import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/repositories/staff_repository_interface.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_stats_row.dart';
import '../widgets/staff_toolbar.dart';
import '../widgets/staff_filter_chips.dart';
import '../widgets/staff_data_table.dart';
import '../widgets/add_staff_dialog.dart';
import '../widgets/edit_staff_dialog.dart';
import '../../data/models/staff_model.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StaffBloc(repository: GetIt.I<StaffRepository>())
            ..add(const LoadStaff()),
      child: const StaffManagementView(),
    );
  }
}

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final _searchController = TextEditingController();

  // TODO: Replace with actual hotelId from user/vendor context
  // This is a placeholder - needs to come from vendor's selected hotel
  String get _hotelId => _getHotelIdFromContext();

  String _getHotelIdFromContext() {
    // In production, this would come from:
    // 1. Vendor's user session
    // 2. Selected hotel in dropdown
    // For now, return placeholder to allow testing
    return '-'; // Shows "-" to indicate missing data
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStaffDialog() {
    if (_hotelId == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hotel ID not available. Please select a hotel first.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: AddStaffDialog(hotelId: _hotelId),
      ),
    );
  }

  void _showEditStaffDialog(StaffModel staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: EditStaffDialog(staff: staff),
      ),
    );
  }

  void _showDeleteConfirmation(String staffId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Staff Member',
          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this staff member? This action cannot be undone.',
          style: GoogleFonts.sora(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.sora(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<StaffBloc>().add(DeleteStaff(staffId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete', style: GoogleFonts.sora()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF059669),
              ),
            );
          } else if (state is StaffActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is! StaffActionSuccess && current is! StaffActionFailure,
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC2626)),
            );
          }

          if (state is StaffError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.sora(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<StaffBloc>().add(const LoadStaff()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is StaffLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StaffBloc>().add(const RefreshStaff());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    StaffStatsRow(stats: state.stats),
                    const SizedBox(height: 24),

                    // Toolbar (Search + Add Button)
                    StaffToolbar(
                      searchController: _searchController,
                      onSearchChanged: (query) {
                        context.read<StaffBloc>().add(SearchStaff(query));
                      },
                      onAddStaff: _showAddStaffDialog,
                    ),
                    const SizedBox(height: 20),

                    // Filter Chips
                    StaffFilterChips(
                      selectedRole: state.selectedRole,
                      onRoleSelected: (role) {
                        context.read<StaffBloc>().add(FilterByRole(role));
                      },
                    ),
                    const SizedBox(height: 24),

                    // Data Table
                    StaffDataTable(
                      staff: state.filteredStaff,
                      loadingIds: state.loadingIds,
                      onEdit: _showEditStaffDialog,
                      onToggleStatus: (id) {
                        context.read<StaffBloc>().add(ToggleStaffStatus(id));
                      },
                      onDelete: _showDeleteConfirmation,
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
