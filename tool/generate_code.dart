import 'package:build_runner/build_runner.dart';
import 'package:build_runner_core/build_runner_core.dart';

Future<void> main(List<String> args) async {
  await build(
    [applyToRoot(const JsonSerializableBuilder())],
    deleteFilesByDefault: true,
  );
} 