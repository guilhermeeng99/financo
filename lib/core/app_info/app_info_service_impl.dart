import 'package:financo/core/app_info/app_info_service.dart';
import 'package:financo/core/app_info/app_version.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoServiceImpl implements AppInfoService {
  @override
  Future<AppVersion> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(version: info.version);
  }
}
