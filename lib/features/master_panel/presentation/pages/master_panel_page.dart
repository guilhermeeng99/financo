import 'dart:async';

import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/constants/access_control.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_cubit.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_state.dart';
import 'package:financo/features/master_panel/presentation/widgets/add_allowed_email_dialog.dart';
import 'package:financo/features/master_panel/presentation/widgets/delete_user_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MasterPanelPage extends StatefulWidget {
  const MasterPanelPage({super.key});

  @override
  State<MasterPanelPage> createState() => _MasterPanelPageState();
}

class _MasterPanelPageState extends State<MasterPanelPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<MasterPanelCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(t.masterPanel.title),
          bottom: TabBar(
            tabs: [
              Tab(text: t.masterPanel.tabUsers),
              Tab(text: t.masterPanel.tabAllowlist),
            ],
          ),
        ),
        body: BlocConsumer<MasterPanelCubit, MasterPanelState>(
          listenWhen: (previous, current) => current is MasterPanelError,
          listener: (context, state) {
            if (state is MasterPanelError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is MasterPanelInitial || state is MasterPanelLoading) {
              return const LoadingShimmer();
            }
            if (state is MasterPanelError) {
              return ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<MasterPanelCubit>().load(),
              );
            }
            final loaded = state as MasterPanelLoaded;
            final currentUid = _currentUid(context);
            return TabBarView(
              children: [
                _UsersTab(users: loaded.users, currentUid: currentUid),
                _AllowlistTab(allowedEmails: loaded.allowedEmails),
              ],
            );
          },
        ),
        floatingActionButton: BlocBuilder<MasterPanelCubit, MasterPanelState>(
          builder: (context, state) {
            final controller = DefaultTabController.maybeOf(context);
            if (controller == null) return const SizedBox.shrink();
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.index != 1) return const SizedBox.shrink();
                return FloatingActionButton(
                  onPressed: state is MasterPanelLoaded && !state.busy
                      ? () => _addEmail(context)
                      : null,
                  child: const FaIcon(FontAwesomeIcons.plus),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _currentUid(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    return auth is Authenticated ? auth.user.id : '';
  }

  Future<void> _addEmail(BuildContext context) async {
    final result = await showAddAllowedEmailDialog(context);
    if (result == null || !context.mounted) return;
    final cubit = context.read<MasterPanelCubit>();
    final outcome = await cubit.addEmail(
      email: result.email,
      note: result.note,
    );
    if (!context.mounted) return;
    outcome.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.masterPanel.addEmailSuccess)),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.users, required this.currentUid});

  final List<UserEntity> users;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(child: Text(t.masterPanel.usersEmpty));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        final isMaster = isMasterEmail(user.email);
        final isSelf = user.id == currentUid;
        return _UserTile(
          user: user,
          isMaster: isMaster,
          canDelete: !isMaster && !isSelf,
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isMaster,
    required this.canDelete,
  });

  final UserEntity user;
  final bool isMaster;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.surfaceVariant,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(_initials(user.name))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isMaster) ...[
                        const SizedBox(width: 8),
                        _MasterBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
              ),
            ),
            if (canDelete)
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.trash,
                  size: 16,
                  color: colors.error,
                ),
                onPressed: () => _confirmDelete(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteUserDialog(
      context,
      targetEmail: user.email,
      targetName: user.name,
    );
    if (!confirmed || !context.mounted) return;
    final cubit = context.read<MasterPanelCubit>();
    final result = await cubit.deleteUser(user.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.masterPanel.deleteUserSuccess)),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty
        ? parts.last[0]
        : '';
    return (first + last).toUpperCase();
  }
}

class _MasterBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        t.masterPanel.masterBadge,
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AllowlistTab extends StatelessWidget {
  const _AllowlistTab({required this.allowedEmails});

  final List<AllowedEmailEntity> allowedEmails;

  @override
  Widget build(BuildContext context) {
    if (allowedEmails.isEmpty) {
      return Center(child: Text(t.masterPanel.allowlistEmpty));
    }
    final formatter = DateFormat.yMMMd().add_jm();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: allowedEmails.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = allowedEmails[index];
        return _AllowedEmailTile(entry: entry, formatter: formatter);
      },
    );
  }
}

class _AllowedEmailTile extends StatelessWidget {
  const _AllowedEmailTile({required this.entry, required this.formatter});

  final AllowedEmailEntity entry;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    formatter.format(entry.addedAt),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.trash,
                size: 16,
                color: colors.error,
              ),
              onPressed: () => _confirmRemove(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.masterPanel.removeEmailTitle),
        content: Text(
          t.masterPanel.removeEmailBody(email: entry.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.appColors.error,
            ),
            child: Text(t.masterPanel.removeEmailConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result =
        await context.read<MasterPanelCubit>().removeEmail(entry.email);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.masterPanel.removeEmailSuccess)),
      ),
    );
  }
}
