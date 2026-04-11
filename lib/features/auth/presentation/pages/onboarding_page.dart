import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              FaIcon(
                FontAwesomeIcons.wallet,
                size: 80,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                t.app.name,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.onboarding.tagline,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FinancoButton(
                label: t.auth.signIn,
                onPressed: () => context.go(AppRoutes.signIn),
              ),
              const SizedBox(height: 12),
              FinancoButton(
                label: t.auth.createAccount,
                isOutlined: true,
                onPressed: () => context.go(AppRoutes.signUp),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      t.general.or,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(
                  const AuthGoogleSignInRequested(),
                ),
                icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                label: Text(t.auth.continueWithGoogle),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
