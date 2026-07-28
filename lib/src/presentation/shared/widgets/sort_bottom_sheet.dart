import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';

import 'package:takion/src/presentation/shared/widgets/components.dart';

Future<void> showSortBottomSheet(
  BuildContext context,
  WidgetRef ref,
  SortPreferenceContext sortContext,
  String Function(ContentSortOption) labelBuilder,
) async {
  final currentOption = ref.watch(
    sortPreferenceForContextProvider(sortContext),
  );

  await TakionBottomSheet.show(
    context: context,
    title: 'Sort Options',
    child: RadioGroup<ContentSortOption>(
      groupValue: currentOption,
      onChanged: (value) {
        if (value != null) {
          ref
              .read(sortPreferencesProvider.notifier)
              .setPreference(sortContext, value);
          Navigator.pop(context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ContentSortOption.values.map((option) {
          return RadioListTile<ContentSortOption>(
            title: Text(labelBuilder(option)),
            value: option,
          );
        }).toList(),
      ),
    ),
  );
}
