import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: context.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: t.general.ok,
                  textColor: context.colorScheme.onError,
                  onPressed: () {},
                ),
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go(AppRoutes.onboarding),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    t.auth.welcomeBack,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.signInSubtitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FinancoTextField(
                    controller: _emailController,
                    label: t.auth.email,
                    hintText: t.auth.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  FinancoTextField(
                    controller: _passwordController,
                    label: t.auth.password,
                    hintText: t.auth.passwordHint,
                    obscureText: true,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return FinancoButton(
                        label: t.auth.signIn,
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      );
                    },
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
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthGoogleSignInRequested(),
                              ),
                        icon: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const FaIcon(FontAwesomeIcons.google, size: 20),
                        label: Text(t.auth.continueWithGoogle),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signUp),
                    child: Text(
                      t.auth.noAccount,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
