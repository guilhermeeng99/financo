import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FinancoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FinancoAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: showBack
          ? IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
    );
  }
}
