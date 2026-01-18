import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AirMenuColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: loading ? null : onTap,
      child: Text(
        loading ? "Loading..." : text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
