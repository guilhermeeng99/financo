import 'package:financo/core/app_info/app_version.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Small, low-emphasis label at the bottom of the profile screen showing
/// the running app version + build number. Lets the user confirm at a
/// glance whether they're on the latest release. The same widget renders
/// on web and mobile because `package_info_plus` resolves both.
class AppVersionFooter extends StatelessWidget {
  const AppVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final version = GetIt.I<AppVersion>();
    return Center(
      child: Text(
        '${t.profile.version} ${version.display}',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.appColors.onBackgroundLight,
        ),
      ),
    );
  }
}
