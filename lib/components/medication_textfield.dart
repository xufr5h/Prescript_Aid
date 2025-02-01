import 'package:flutter/material.dart';

class MedicationTextfield extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String labelText;
  final Widget? prefixIcon;

  const MedicationTextfield({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.labelText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3))
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
              border: InputBorder.none,
              labelText: labelText,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: prefixIcon,
                      ),
                    )
                  : null),
        ),
      ),
    );
  }
}
