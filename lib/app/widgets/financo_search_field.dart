import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// App-wide search input. Used by every "search-as-you-type" sheet
/// (category picker, icon picker, etc.) so they all share the same
/// styling, hit area, and clear-button behavior.
///
/// The lookup itself is the caller's responsibility — this widget only
/// owns the visual + the `xmark` button to clear the field.
class FinancoSearchField extends StatelessWidget {
  const FinancoSearchField({
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 4),
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  /// Outer padding around the field. Defaults match the icon-picker
  /// sheet (where this style was originally born); category picker
  /// sheets pass a tighter padding to align with their list rows.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          // Fixed-width prefix wrapper centers the icon vertically and
          // horizontally — using bare Padding leaves the glyph drifting
          // toward the top of the input on tall content paddings.
          prefixIcon: SizedBox(
            width: 44,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 14,
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 14,
                  color: colors.onBackgroundLight,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
          filled: true,
          fillColor: colors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
