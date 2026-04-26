import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/web_file_download.dart'
    if (dart.library.js_interop)
        'package:financo/core/utils/web_file_download_web.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/profile/domain/usecases/clear_account_data_usecase.dart';
import 'package:financo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/widgets/transactions_csv_import_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _clearAccountData(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.profile.clearData),
        content: Text(t.profile.clearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.general.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await GetIt.I<ClearAccountDataUseCase>()(userId);
    if (!mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        unawaited(
          context.read<CategoriesCubit>().loadCategories(forceRefresh: true),
        );
        unawaited(
          context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.profile.clearDataSuccess)),
        );
      },
    );
  }

  Future<void> _importCsv() async {
    await showTransactionsCsvImportDialog(context);
  }

  void _downloadApk() {
    triggerBrowserUrlDownload('financo.apk', 'financo.apk');
  }

  @override
  void initState() {
    super.initState();
    unawaited(context.read<ProfileCubit>().loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.profile.title),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state is TransactionsImported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  t.transactions.importSuccess(
                    imported: state.importedCount,
                    skipped: state.skippedCount,
                  ),
                ),
              ),
            );

            final filter = context.read<DateFilterCubit>().state;
            context.read<DashboardBloc>().add(
              DashboardLoadRequested(
                year: filter.year,
                month: filter.month,
                forceRefresh: true,
              ),
            );
            context.read<TransactionsBloc>().add(
              TransactionsLoadRequested(
                year: filter.year,
                month: filter.month,
                forceRefresh: true,
              ),
            );
          }

          if (state is TransactionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) return const LoadingShimmer();
            if (state is ProfileError) {
              return ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<ProfileCubit>().loadProfile(
                  forceRefresh: true,
                ),
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
                  _ProfileTile(
                    icon: FontAwesomeIcons.fileInvoiceDollar,
                    title: t.profile.bills,
                    onTap: () => context.push(AppRoutes.bills),
                  ),
                  _ProfileTile(
                    icon: FontAwesomeIcons.fileArrowUp,
                    title: t.transactions.importCsv,
                    onTap: _importCsv,
                  ),
                  if (kIsWeb)
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.android),
                      title: Text(t.profile.downloadApk),
                      subtitle: Text(t.profile.downloadApkDescription),
                      trailing: const FaIcon(FontAwesomeIcons.download),
                      onTap: _downloadApk,
                    ),
                  const Divider(),
                  _ThemeSelector(),
                  const Divider(),
                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Colors.red,
                    ),
                    title: Text(
                      t.profile.clearData,
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(t.profile.clearDataDescription),
                    onTap: () => _clearAccountData(user.id),
                  ),
                  const Divider(),
                  const SizedBox(height: 24),
                  FinancoButton(
                    label: t.auth.signOut,
                    isOutlined: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      );
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        // ThemeMode.system follows the OS, so resolve it to the actual
        // brightness — otherwise the switch can appear "off" while the app
        // is already rendering in dark mode, making the first toggle look
        // like a no-op.
        final isDark = switch (themeMode) {
          ThemeMode.dark => true,
          ThemeMode.light => false,
          ThemeMode.system =>
            MediaQuery.platformBrightnessOf(context) == Brightness.dark,
        };
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
