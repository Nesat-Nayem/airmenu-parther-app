import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/delivery_partner_models.dart';
import '../bloc/delivery_partner_bloc.dart';
import '../bloc/delivery_partner_event.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class AddPartnerDialog extends StatefulWidget {
  const AddPartnerDialog({super.key});

  @override
  State<AddPartnerDialog> createState() => _AddPartnerDialogState();
}

class _AddPartnerDialogState extends State<AddPartnerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _webhookController = TextEditingController();
  final _costController = TextEditingController();
  final _coverageController = TextEditingController();

  String? _selectedType;
  final List<String> _partnerTypes = [
    'Hyperlocal',
    'Bike Delivery',
    'Multi-mode',
    'Heavy Delivery',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _webhookController.dispose();
    _costController.dispose();
    _coverageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Delivery Partner',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Partner Name
              Text(
                'Partner Name *',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Shadowfax',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter partner name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Partner Type
              Text(
                'Partner Type *',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  hintText: 'Select type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _partnerTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select partner type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // API Key
              Text(
                'API Key *',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: 'Enter API key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter API key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Webhook URL
              Text(
                'Webhook URL',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _webhookController,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cost per KM and Coverage
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cost per KM',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g., 8',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coverage (cities)',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _coverageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g., 12',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add Partner'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final partner = DeliveryPartner(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType!,
        costPerKm: double.tryParse(_costController.text) ?? 0.0,
        avgTimeMinutes: 30, // Default
        slaScore: 0.0, // Default
        activeRiders: 0, // Default
        coverage: '${_coverageController.text} cities',
        totalDeliveries: 0,
        status: 'pending',
        apiStatus: 'pending',
        webhookUrl: _webhookController.text.isEmpty
            ? null
            : _webhookController.text,
        apiKey: _apiKeyController.text,
      );

      context.read<DeliveryPartnerBloc>().add(AddDeliveryPartner(partner));
      Navigator.pop(context);
    }
  }
}
