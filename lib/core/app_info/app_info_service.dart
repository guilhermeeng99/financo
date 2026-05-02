import 'package:financo/core/app_info/app_version.dart';

/// Reads runtime app metadata (version, build number) from the host
/// platform. Wraps `package_info_plus` so the rest of the codebase
/// depends on this abstraction, not on the third-party API.
abstract class AppInfoService {
  Future<AppVersion> getAppVersion();
}
