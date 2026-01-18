import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class RememberForgotRow extends StatelessWidget {
  final bool remember;
  final Function(bool) onChanged;
  final VoidCallback onForgot;

  const RememberForgotRow({
    super.key,
    required this.remember,
    required this.onChanged,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: remember,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AirMenuColors.primary,
            ),
            const Text("Remember me"),
          ],
        ),
        GestureDetector(
          onTap: onForgot,
          child: const Text(
            "Forgot Password?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AirMenuColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
