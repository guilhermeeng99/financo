import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/presentation/cubit/institutions_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Lists the user's custody institutions. See `docs/specs/institutions.md`.
class InstitutionsPage extends StatefulWidget {
  const InstitutionsPage({super.key});

  @override
  State<InstitutionsPage> createState() => _InstitutionsPageState();
}

class _InstitutionsPageState extends State<InstitutionsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<InstitutionsCubit>().load());
  }

  Future<void> _openForm([Institution? existing]) async {
    final route = existing == null
        ? AppRoutes.addInstitution
        : AppRoutes.editInstitution;
    final result = await context.push<bool>(route, extra: existing);
    if (result == true && mounted) {
      unawaited(context.read<InstitutionsCubit>().load(forceRefresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.institutions.title,
        showBack: true,
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'institutions_fab',
          onPressed: _openForm,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<InstitutionsCubit, InstitutionsState>(
        builder: (context, state) {
          if (state is InstitutionsLoading) return const LoadingShimmer();
          if (state is InstitutionsError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () =>
                  context.read<InstitutionsCubit>().load(forceRefresh: true),
            );
          }
          final institutions = state is InstitutionsLoaded
              ? state.institutions
              : const <Institution>[];
          if (institutions.isEmpty) {
            return FeatureEmptyState(
              icon: FontAwesomeIcons.buildingColumns,
              title: t.investing.institutions.emptyTitle,
              message: t.investing.institutions.empty,
              actionLabel: t.investing.institutions.addFirst,
              onAction: _openForm,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: institutions.length,
            itemBuilder: (_, i) => _InstitutionTile(
              institution: institutions[i],
              onTap: () => _openForm(institutions[i]),
            ),
          );
        },
      ),
    );
  }
}

class _InstitutionTile extends StatelessWidget {
  const _InstitutionTile({required this.institution, required this.onTap});

  final Institution institution;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.surfaceVariant,
                  child: FaIcon(
                    FontAwesomeIcons.buildingColumns,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        institution.name,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        institutionKindLabel(institution.kind),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  institution.currency.code,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.onBackgroundLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Localized label for an [InstitutionKind].
String institutionKindLabel(InstitutionKind kind) => switch (kind) {
  InstitutionKind.bank => t.investing.institutions.kinds.bank,
  InstitutionKind.broker => t.investing.institutions.kinds.broker,
  InstitutionKind.internationalBroker =>
    t.investing.institutions.kinds.internationalBroker,
  InstitutionKind.crypto => t.investing.institutions.kinds.crypto,
  InstitutionKind.other => t.investing.institutions.kinds.other,
};
