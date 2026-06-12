import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Full-width primary action used by both the "no subclasses" empty
/// state and the trailing CTA under the subclass list. Mirrors the
/// dimensions of `FinancoSubmitBar` (52 high, 14px radius, primary
/// fill, white text) so it reads as a real submit and not a
/// decoration.
class AddSubclassButton extends StatelessWidget {
  const AddSubclassButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
        label: Text(
          t.investments.addSubclass,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
