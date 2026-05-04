import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/constants/access_control.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/web_file_download.dart'
    if (dart.library.js_interop) 'package:financo/core/utils/web_file_download_web.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/profile/domain/usecases/clear_account_data_usecase.dart';
import 'package:financo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:financo/features/profile/presentation/widgets/app_version_footer.dart';
import 'package:financo/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:financo/features/profile/presentation/widgets/profile_language_row.dart';
import 'package:financo/features/profile/presentation/widgets/profile_palette_picker.dart';
import 'package:financo/features/profile/presentation/widgets/profile_row.dart';
import 'package:financo/features/profile/presentation/widgets/profile_section.dart';
import 'package:financo/features/profile/presentation/widgets/profile_theme_row.dart';
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
  @override
  void initState() {
    super.initState();
    unawaited(context.read<ProfileCubit>().loadProfile());
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.auth.signOut),
        content: Text(t.profile.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.auth.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  Future<void> _clearAccountData(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.profile.clearData),
        content: Text(t.profile.clearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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

  Future<void> _importCsv() => showTransactionsCsvImportDialog(context);

  void _downloadApk() =>
      triggerBrowserUrlDownload('financo.apk', 'financo.apk');

  void _onTransactionsState(BuildContext context, TransactionsState state) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(title: t.profile.title),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: _onTransactionsState,
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
              return _ProfileContent(
                userId: state.user.id,
                name: state.user.name,
                email: state.user.email,
                photoUrl: state.user.photoUrl,
                isMaster: isMasterEmail(state.user.email),
                onImportCsv: _importCsv,
                onDownloadApk: _downloadApk,
                onSignOut: _confirmSignOut,
                onClearData: () => _clearAccountData(state.user.id),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.userId,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isMaster,
    required this.onImportCsv,
    required this.onDownloadApk,
    required this.onSignOut,
    required this.onClearData,
  });

  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isMaster;
  final Future<void> Function() onImportCsv;
  final VoidCallback onDownloadApk;
  final VoidCallback onSignOut;
  final VoidCallback onClearData;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ProfileHeaderCard(name: name, email: email, photoUrl: photoUrl),
        const SizedBox(height: 24),
        ProfileSection(
          label: t.profile.sectionYourData,
          children: [
            ProfileRow(
              icon: FontAwesomeIcons.buildingColumns,
              title: t.profile.accounts,
              onTap: () => context.push(AppRoutes.accounts),
            ),
            ProfileRow(
              icon: FontAwesomeIcons.tags,
              title: t.profile.categories,
              accent: context.appColors.income,
              onTap: () => context.push(AppRoutes.categories),
            ),
            ProfileRow(
              icon: FontAwesomeIcons.fileArrowUp,
              title: t.transactions.importCsv,
              accent: context.appColors.warning,
              onTap: () => unawaited(onImportCsv()),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ProfileSection(
          label: t.profile.sectionPreferences,
          children: const [
            ProfileThemeRow(),
            ProfilePalettePicker(),
            ProfileLanguageRow(),
          ],
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 20),
          ProfileSection(
            label: t.profile.sectionGetTheApp,
            children: [
              ProfileRow(
                icon: FontAwesomeIcons.android,
                title: t.profile.downloadApk,
                subtitle: t.profile.downloadApkDescription,
                accent: context.appColors.success,
                trailing: FaIcon(
                  FontAwesomeIcons.download,
                  size: 14,
                  color: context.appColors.onBackgroundLight,
                ),
                onTap: onDownloadApk,
              ),
            ],
          ),
        ],
        if (isMaster) ...[
          const SizedBox(height: 20),
          ProfileSection(
            label: t.profile.sectionMaster,
            children: [
              ProfileRow(
                icon: FontAwesomeIcons.shieldHalved,
                title: t.profile.masterPanel,
                subtitle: t.profile.masterPanelDescription,
                accent: context.appColors.primary,
                onTap: () => context.push(AppRoutes.masterPanel),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        ProfileSection(
          label: t.profile.sectionAccount,
          children: [
            ProfileRow(
              icon: FontAwesomeIcons.rightFromBracket,
              title: t.auth.signOut,
              accent: context.appColors.onBackgroundLight,
              onTap: onSignOut,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ProfileSection(
          label: t.profile.sectionDangerZone,
          children: [
            ProfileRow(
              icon: FontAwesomeIcons.triangleExclamation,
              title: t.profile.clearData,
              subtitle: t.profile.clearDataDescription,
              destructive: true,
              onTap: onClearData,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const AppVersionFooter(),
        const SizedBox(height: 60),
      ],
    );
  }
}
