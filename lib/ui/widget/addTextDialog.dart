import 'package:flutter/material.dart';

class AddTextDialog extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const AddTextDialog({
    Key? key,
    required this.textController,
    required this.onCancel,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Text'),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'Enter your text here'),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

void _showAddTextDialog(Map<String, dynamic> iconData, BuildContext context, Function(String) onTextAdded) {
  TextEditingController textController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddTextDialog(
        textController: textController,
        onCancel: () {
          Navigator.pop(context);
        },
        onAdd: () {
          onTextAdded(textController.text);
          Navigator.pop(context);
        },
      );
    },
  );
}