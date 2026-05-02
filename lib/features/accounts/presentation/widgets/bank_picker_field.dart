import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/widgets/bank_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Inline form tile that previews the currently selected bank
/// (avatar + label) and opens [showBankPicker] on tap. Replaces the old
/// 2-option pill toggle now that the catalog has 20+ banks.
class BankPickerField extends StatelessWidget {
  const BankPickerField({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final BankType selected;
  final ValueChanged<BankType> onChanged;

  Future<void> _open(BuildContext context) async {
    final picked = await showBankPicker(context: context, selected: selected);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brand = BankBrand.of(selected);
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              BankAvatar(bank: selected, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.accounts.bank,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      brand.label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
