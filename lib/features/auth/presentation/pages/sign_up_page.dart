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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
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
                    t.auth.createAccount,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.signUpSubtitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FinancoTextField(
                    controller: _nameController,
                    label: t.auth.name,
                    hintText: t.auth.nameHint,
                    validator: Validators.requiredField,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
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
                        label: t.auth.createAccount,
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signIn),
                    child: Text(t.auth.hasAccount),
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
