import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<ProfileCubit>().loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.profile.title),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) return const LoadingShimmer();
          if (state is ProfileError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () =>
                  context.read<ProfileCubit>().loadProfile(forceRefresh: true),
            );
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: _ProfileAvatar(
                    name: user.name,
                    photoUrl: user.photoUrl,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.name,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                _ProfileTile(
                  icon: FontAwesomeIcons.buildingColumns,
                  title: t.profile.accounts,
                  onTap: () => context.push(AppRoutes.accounts),
                ),
                _ProfileTile(
                  icon: FontAwesomeIcons.tags,
                  title: t.profile.categories,
                  onTap: () => context.push(AppRoutes.categories),
                ),
                const Divider(),
                _ThemeSelector(),
                const Divider(),
                const SizedBox(height: 24),
                FinancoButton(
                  label: t.auth.signOut,
                  isOutlined: true,
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthSignOutRequested());
                  },
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return SwitchListTile(
          secondary: FaIcon(
            isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
          ),
          title: Text(t.profile.theme),
          subtitle: Text(
            isDark ? t.profile.themeDark : t.profile.themeLight,
          ),
          value: isDark,
          onChanged: (value) => unawaited(
            context.read<ThemeCubit>().setThemeMode(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final FaIconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(icon),
      title: Text(title),
      trailing: const FaIcon(FontAwesomeIcons.chevronRight),
      onTap: onTap,
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final showImage = widget.photoUrl != null && !_imageError;

    return CircleAvatar(
      radius: 48,
      backgroundColor: context.colorScheme.primaryContainer,
      backgroundImage: showImage ? NetworkImage(widget.photoUrl!) : null,
      onBackgroundImageError: showImage
          ? (error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _imageError = true);
              });
            }
          : null,
      child: !showImage
          ? Text(
              widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
