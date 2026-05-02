import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Google-only sign-in landing. The app has no email/password path and
/// no public sign-up — accounts are admitted via the master allowlist.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  t.auth.welcomeBack,
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontSize: 30,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.1, end: 0, duration: 350.ms),
                const SizedBox(height: 12),
                Text(
                  t.auth.signInSubtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                const Spacer(flex: 2),
                const GoogleSignInButton()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 350.ms)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: 200.ms,
                      duration: 350.ms,
                    ),
                const SizedBox(height: 16),
                Text(
                  t.auth.accessByInviteOnly,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Material(
            color: colors.surfaceVariant,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => context.go(AppRoutes.onboarding),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    size: 13,
                    color: colors.onBackground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.failure.message),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
    }
  }
}
