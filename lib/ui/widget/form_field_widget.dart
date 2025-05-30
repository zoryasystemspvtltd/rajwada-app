import 'package:flutter/material.dart';

class FormFieldItem extends StatelessWidget {
  final int index;
  final String fieldKey;
  final String label;
  final  TextEditingController controller;
  final Function(String) onChanged;
  final bool isEnabled; // New parameter

  const FormFieldItem({
    super.key,
    required this.index,
    required this.fieldKey,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.isEnabled = true, // Default is enabled
  });

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;

    // Set the keyboard type based on fieldKey
    if (fieldKey == "quantity" || fieldKey == "price") {
      keyboardType = const TextInputType.numberWithOptions(decimal: false); // Numbers only
    } else if (fieldKey == "email") {
      keyboardType = TextInputType.emailAddress;
    } else if (fieldKey == "phone") {
      keyboardType = TextInputType.phone;
    } else {
      keyboardType = TextInputType.text;
    }

    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        fillColor: isEnabled ? Colors.white : Colors.white, // Set background color when disabled
        filled: true, // Makes sure the fill color is applied
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isEnabled ? Colors.black : Colors.black54, // Change label color when disabled
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onChanged: onChanged,
    );
  }
}
