import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investments/presentation/widgets/add_subclass_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Empty state shown on the asset-class detail page when the class has
/// no subclasses yet — explains the concept and offers an [AddSubclassButton]
/// wired to [onAdd].
class AssetSubclassEmptyState extends StatelessWidget {
  const AssetSubclassEmptyState({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.layerGroup,
            size: 24,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(height: 12),
          Text(
            t.investments.detailNoSubclassesTitle,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.investments.detailNoSubclassesBody,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 16),
          AddSubclassButton(onPressed: onAdd),
        ],
      ),
    );
  }
}
