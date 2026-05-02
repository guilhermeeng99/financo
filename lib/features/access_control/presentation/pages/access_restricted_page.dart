import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Shown when the user authenticated with Google successfully but is not
/// in `allowed_emails`. The "Voltar" button signs out and returns the
/// user to the sign-in page.
class AccessRestrictedPage extends StatelessWidget {
  const AccessRestrictedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => current is AccessDenied,
          builder: (context, state) {
            final email = state is AccessDenied ? state.email : '';
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  _Icon(color: colors.warning),
                  const SizedBox(height: 24),
                  Text(
                    t.accessControl.restrictedTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 350.ms),
                  const SizedBox(height: 12),
                  Text(
                    t.accessControl.restrictedBody,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      email,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  const Spacer(flex: 2),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested()),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        t.accessControl.restrictedBack,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(FontAwesomeIcons.lock, size: 32, color: color),
        ),
      ),
    );
  }
}
