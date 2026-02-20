import 'package:takion/bootstrap.dart';
import 'package:takion/src/app.dart';

/// The entry point for the application.
void main() async {
  await bootstrap(() => const TakionApp());
}
