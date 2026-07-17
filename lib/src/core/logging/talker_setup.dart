import 'package:talker/talker.dart';

final Talker talker = Talker(
  logger: TalkerLogger(
    settings: TalkerLoggerSettings(level: LogLevel.info),
  ),
);
