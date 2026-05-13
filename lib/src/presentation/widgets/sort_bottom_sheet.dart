import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';

Future<void> showSortBottomSheet(
  BuildContext context,
  WidgetRef ref,
  SortPreferenceContext sortContext,
  String Function(ContentSortOption) labelBuilder,
) async {
  final currentOption = ref.watch(
    sortPreferenceForContextProvider(sortContext),
  );

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort Options',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...ContentSortOption.values.map((option) {
              return RadioListTile<ContentSortOption>(
                title: Text(labelBuilder(option)),
                value: option,
                groupValue: currentOption,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortPreferencesProvider.notifier).setPreference(
                          sortContext,
                          value,
                        );
                    Navigator.pop(context);
                  }
                },
              );
            }),
          ],
        ),
      );
    },
  );
}
