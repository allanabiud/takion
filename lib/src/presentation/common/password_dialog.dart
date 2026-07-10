import 'package:flutter/material.dart';

enum PasswordDialogMode { create, restore, master }

Future<String?> showPasswordDialog({
  required BuildContext context,
  required PasswordDialogMode mode,
}) {
  final controller = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var obscure = true;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isCreate = mode == PasswordDialogMode.create || mode == PasswordDialogMode.master;

          return AlertDialog(
            title: Text(
              mode == PasswordDialogMode.create
                  ? 'Set Backup Password'
                  : mode == PasswordDialogMode.master
                      ? 'Set Master Backup Password'
                      : 'Enter Backup Password',
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mode == PasswordDialogMode.create
                          ? 'This password will be used to encrypt your backup. '
                              'You will need it to restore.'
                          : mode == PasswordDialogMode.master
                              ? 'This password will be used to encrypt automatic cloud backups. '
                                  'You will need it to restore your backups on other devices.'
                              : 'Enter the password used when this backup was created.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => obscure = !obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (isCreate && v.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    if (isCreate) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        validator: (v) {
                          if (v != controller.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(controller.text);
                  }
                },
                child: Text(
                  mode == PasswordDialogMode.create
                      ? 'Create Backup'
                      : mode == PasswordDialogMode.master
                          ? 'Set Password'
                          : 'Decrypt',
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
