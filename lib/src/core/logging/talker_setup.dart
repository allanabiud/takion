import 'package:talker_flutter/talker_flutter.dart';

final Talker talker = TalkerFlutter.init(
  logger: TalkerLogger(
    settings: TalkerLoggerSettings(level: LogLevel.debug),
  ),
);
