import "package:flutter/material.dart";

Future<String?> showManualUpcDialog(BuildContext context) async {
  final controller = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Enter UPC"),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "e.g. 759606207237",
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("CANCEL"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text("SEARCH"),
        ),
      ],
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  return result;
}
