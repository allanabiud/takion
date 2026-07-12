import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_week_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedWeek extends _$SelectedWeek {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }

  void nextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void previousWeek() {
    state = state.subtract(const Duration(days: 7));
  }
}
