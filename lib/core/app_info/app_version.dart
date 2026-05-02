import 'package:equatable/equatable.dart';

/// Immutable snapshot of the running app's semver, taken from
/// `pubspec.yaml` at build time (e.g. `1.0.1`).
class AppVersion extends Equatable {
  const AppVersion({required this.version});

  final String version;

  /// What we render in the UI. Today this is just `version`; kept as a
  /// dedicated getter so the formatting can evolve (e.g. add a build
  /// number for debug builds) without touching the call sites.
  String get display => version;

  @override
  List<Object> get props => [version];
}
