import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:financo/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.auth.createAccount,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontSize: 28,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.1, end: 0, duration: 350.ms),
                  const SizedBox(height: 6),
                  Text(
                    t.auth.signUpSubtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                  const SizedBox(height: 28),
                  FinancoFormSection(
                    label: t.auth.signUp,
                    children: [
                      FinancoTextField(
                        controller: _nameController,
                        label: t.auth.name,
                        hintText: t.auth.nameHint,
                        validator: Validators.requiredField,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      FinancoTextField(
                        controller: _emailController,
                        label: t.auth.email,
                        hintText: t.auth.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      FinancoTextField(
                        controller: _passwordController,
                        label: t.auth.password,
                        hintText: t.auth.passwordHint,
                        obscureText: true,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 350.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 200.ms,
                        duration: 350.ms,
                      ),
                  const SizedBox(height: 24),
                  const AuthOrDivider()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 350.ms),
                  const SizedBox(height: 24),
                  const GoogleSignInButton()
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 350.ms),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signIn),
                    child: Text(
                      t.auth.hasAccount,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => FinancoSubmitBar(
            label: t.auth.createAccount,
            isLoading: state is AuthLoading,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          ),
        );
    }
  }
}
