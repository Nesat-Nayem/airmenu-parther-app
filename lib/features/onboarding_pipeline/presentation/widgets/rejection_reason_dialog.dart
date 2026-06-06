import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog that captures a structured rejection reason from the admin.
///
/// The admin picks which field(s) need correction, optionally writes a note
/// per field, and may add a general note. The returned value is a
/// `Map<String, String>` suitable to be sent as `adminComments` to the
/// backend `PUT /kyc/review/:id` endpoint.
///
/// Known keys (kept in sync with `MyKycPage`):
/// * `aadhaar`, `gst`, `fssai`, `bank`, `address`, `restaurant`, `general`.
class RejectionReasonDialog extends StatefulWidget {
  const RejectionReasonDialog({super.key});

  /// Convenience helper — opens the dialog and returns the map (or null).
  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const RejectionReasonDialog(),
    );
  }

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  static const _fields = <_RejectField>[
    _RejectField(key: 'aadhaar', label: 'Aadhaar details'),
    _RejectField(key: 'gst', label: 'GST details'),
    _RejectField(key: 'fssai', label: 'FSSAI details'),
    _RejectField(key: 'bank', label: 'Bank details'),
    _RejectField(key: 'address', label: 'Address details'),
    _RejectField(key: 'restaurant', label: 'Restaurant information'),
  ];

  final Set<String> _selected = {};
  final Map<String, TextEditingController> _fieldNotes = {};
  final TextEditingController _generalCtrl = TextEditingController();

  bool get _canSubmit {
    if (_selected.isEmpty) return false;
    for (final key in _selected) {
      if ((_fieldNotes[key]?.text.trim() ?? '').isEmpty) return false;
    }
    return true;
  }

  void _onFormChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _fieldNotes[f.key] = TextEditingController()
        ..addListener(_onFormChanged);
    }
    _generalCtrl.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    for (final c in _fieldNotes.values) {
      c.dispose();
    }
    _generalCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one field and provide a reason for each selected field.',
          ),
        ),
      );
      return;
    }

    final out = <String, String>{};
    for (final key in _selected) {
      out[key] = _fieldNotes[key]!.text.trim();
    }
    final general = _generalCtrl.text.trim();
    if (general.isNotEmpty) out['general'] = general;

    Navigator.of(context).pop(out);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.report_gmailerrorred_rounded,
                      color: AirMenuColors.error, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reject KYC Submission',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select at least one field and explain why each selected field '
                'needs correction. The vendor can only edit those fields when resubmitting.',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Fields that need correction *',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._fields.map(_buildFieldTile),
                      const SizedBox(height: 12),
                      Text(
                        'Additional note (optional)',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _generalCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Overall documents are unclear — please reupload.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _canSubmit ? _submit : null,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Rejection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AirMenuColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTile(_RejectField field) {
    final isSelected = _selected.contains(field.key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selected.remove(field.key);
                } else {
                  _selected.add(field.key);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(field.key);
                      } else {
                        _selected.remove(field.key);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    field.label,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 4, bottom: 6),
              child: TextField(
                controller: _fieldNotes[field.key],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Why is this incorrect? *',
                  isDense: true,
                  errorText: (_fieldNotes[field.key]?.text.trim().isEmpty ?? true)
                      ? 'Reason is required'
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RejectField {
  final String key;
  final String label;
  const _RejectField({required this.key, required this.label});
}
