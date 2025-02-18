import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isEnabled; // New parameter
  final DateTime initialDate;

  const CustomDateField({
    super.key,
    required this.label,
    required this.controller,
    this.isEnabled = true, // Default is enabled
    required this.initialDate,
  });

  @override
  _CustomDateFieldState createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  Future<void> _selectDate(BuildContext context) async {


    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          widget.controller.text =
              DateFormat('yyyy-MM-dd').format(selectedDate);
        });
      }
      return null;
    });

    // if (pickedDate != null) {
    //   setState(() {
    //     widget.controller.text = "${pickedDate.toLocal()}".split(' ')[0];
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.isEnabled, // Enable/Disable input
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }
}
