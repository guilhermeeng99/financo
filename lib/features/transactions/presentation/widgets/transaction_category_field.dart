import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Read-only picker field on the transaction form showing the currently
/// selected category (resolved by id from [CategoriesCubit]) and opening
/// the category picker via [onTap].
class TransactionCategoryField extends StatelessWidget {
  const TransactionCategoryField({
    required this.selectedId,
    required this.onTap,
    super.key,
  });

  final String selectedId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categories = context.watch<CategoriesCubit>().state.categoriesOrEmpty;
    final selected = selectedId.isEmpty
        ? null
        : categories.where((c) => c.id == selectedId).firstOrNull;
    return FinancoPickerField(
      label: t.transactions.category,
      // Subcategories render as "Parent › Child" so the user sees where
      // the bucket lives (e.g. "Moradia › Aluguel").
      value: selected?.displayPath(categories),
      placeholder: t.payablesReceivables.pickCategory,
      leading: selected != null
          ? FinancoCategoryAvatar(
              category: selected,
              allCategories: categories,
              size: 28,
            )
          : FaIcon(
              FontAwesomeIcons.tag,
              size: 14,
              color: colors.onBackgroundLight,
            ),
      onTap: onTap,
    );
  }
}
