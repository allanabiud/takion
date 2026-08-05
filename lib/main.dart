import 'dart:async';

import 'package:takion/bootstrap.dart';
import 'package:takion/src/app.dart';
import 'package:takion/src/core/logging/talker_setup.dart';

void main() async {
  runZonedGuarded(
    () async {
      await bootstrap(() => const TakionApp());
    },
    (error, stack) {
      talker.handle(error, stack);
    },
  );
}
