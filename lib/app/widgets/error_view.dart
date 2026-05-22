import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Full-screen error state with a retry action. Takes the domain [Failure]
/// directly and localises it at render time via [localizedFailure], so call
/// sites never hand-build (or forget to translate) the message.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              localizedFailure(failure),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
              label: Text(t.general.retry),
            ),
          ],
        ),
      ),
    );
  }
}
