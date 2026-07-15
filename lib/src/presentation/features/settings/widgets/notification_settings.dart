import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';

void showNotificationSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Notifications',
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text('Notification settings coming soon.'),
      ),
    ),
  );
}
