import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class FinancoTextField extends StatelessWidget {
  const FinancoTextField({
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.hintText,
    this.textInputAction,
    this.subdued = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final String? hintText;
  final TextInputAction? textInputAction;

  /// When true, mutes the label and hint to `onBackgroundLight` so the
  /// field reads as "secondary" — same visual weight as the placeholder
  /// in `FinancoPickerField`. Used for low-importance inputs (notes,
  /// transaction description) so they don't compete with primary fields
  /// like amount/account/category.
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final mutedColor = context.appColors.onBackgroundLight;
    final mutedStyle = TextStyle(color: mutedColor);
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: subdued ? mutedStyle : null,
        floatingLabelStyle: subdued ? mutedStyle : null,
        hintStyle: subdued ? mutedStyle : null,
      ),
    );
  }
}
