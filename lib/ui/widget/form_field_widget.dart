import 'package:flutter/material.dart';

class FormFieldItem extends StatelessWidget {
  final int index;
  final String fieldKey;
  final String label;
  final  TextEditingController controller;
  final Function(String) onChanged;

  const FormFieldItem({
    Key? key,
    required this.index,
    required this.fieldKey,
    required this.label,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onChanged: onChanged,
    );
  }
}
