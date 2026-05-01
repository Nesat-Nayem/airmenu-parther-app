import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/zone_model.dart';
import '../bloc/tables_bloc.dart';

class ZoneManagerDialog extends StatefulWidget {
  const ZoneManagerDialog({super.key});

  @override
  State<ZoneManagerDialog> createState() => _ZoneManagerDialogState();
}

class _ZoneManagerDialogState extends State<ZoneManagerDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  ZoneModel? _editingZone;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _startEdit(ZoneModel zone) {
    setState(() {
      _editingZone = zone;
      _nameController.text = zone.name;
      _descController.text = zone.description;
      _errorText = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingZone = null;
      _nameController.clear();
      _descController.clear();
      _errorText = null;
    });
  }

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Zone name is required');
      return;
    }
    setState(() => _errorText = null);

    if (_editingZone != null) {
      context.read<TablesBloc>().add(UpdateZone(
        id: _editingZone!.id,
        name: name,
        description: _descController.text.trim(),
        isActive: _editingZone!.isActive,
      ));
    } else {
      context.read<TablesBloc>().add(CreateZone(
        name: name,
        description: _descController.text.trim(),
      ));
    }
    _cancelEdit();
  }

  void _confirmDelete(BuildContext context, ZoneModel zone) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Zone',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to delete "${zone.name}"? Tables assigned to this zone will keep the zone name.',
          style: GoogleFonts.sora(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.sora(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<TablesBloc>().add(DeleteZone(zone.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Delete', style: GoogleFonts.sora()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Flexible(
              child: BlocConsumer<TablesBloc, TablesState>(
                listenWhen: (prev, curr) => curr.zoneError != null && curr.zoneError != prev.zoneError,
                listener: (context, state) {
                  if (state.zoneError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.zoneError!.replaceFirst('Exception: ', '')),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildForm(context, state),
                        const SizedBox(height: 24),
                        _buildZoneList(context, state),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Zones',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Create and organize seating zones',
                style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Icon(Icons.close, size: 22, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, TablesState state) {
    final isEditing = _editingZone != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEditing ? const Color(0xFFFFF7ED) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEditing ? const Color(0xFFFED7AA) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Zone' : 'Add New Zone',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isEditing ? const Color(0xFFEA580C) : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Zone name (e.g., Rooftop, VIP Section)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.sora(fontSize: 14),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(context),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText: 'Description (optional)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.sora(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isEditing) ...[
                TextButton(
                  onPressed: _cancelEdit,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.sora(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: state.isLoadingZones ? null : () => _submit(context),
                icon: state.isLoadingZones
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEditing ? Icons.check : Icons.add, size: 16),
                label: Text(
                  isEditing ? 'Update' : 'Add Zone',
                  style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? const Color(0xFFEA580C) : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneList(BuildContext context, TablesState state) {
    if (state.isLoadingZones && state.zones.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Color(0xFFDC2626)),
        ),
      );
    }

    if (state.zones.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.layers_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No zones yet',
              style: GoogleFonts.sora(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a zone above to organize your tables',
              style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Zones (${state.zones.length})',
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        ...state.zones.map((zone) => _buildZoneTile(context, zone, state)),
      ],
    );
  }

  Widget _buildZoneTile(BuildContext context, ZoneModel zone, TablesState state) {
    final isBeingEdited = _editingZone?.id == zone.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isBeingEdited ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBeingEdited ? const Color(0xFFFED7AA) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: zone.isActive
                ? const Color(0xFFDC2626).withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.layers_rounded,
            size: 18,
            color: zone.isActive ? const Color(0xFFDC2626) : Colors.grey.shade400,
          ),
        ),
        title: Text(
          zone.name,
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: zone.isActive ? const Color(0xFF111827) : Colors.grey.shade400,
          ),
        ),
        subtitle: zone.description.isNotEmpty
            ? Text(
                zone.description,
                style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!zone.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Inactive',
                  style: GoogleFonts.sora(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: state.isLoadingZones ? null : () => _startEdit(zone),
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: isBeingEdited ? const Color(0xFFEA580C) : Colors.grey.shade500,
              ),
              tooltip: 'Edit',
              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              onPressed: state.isLoadingZones ? null : () => _confirmDelete(context, zone),
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade300),
              tooltip: 'Delete',
              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
