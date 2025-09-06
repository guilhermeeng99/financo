import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:flutter/services.dart';

class CWTextField extends HookWidget {
  const CWTextField({
    required this.hintText,
    required this.onChanged,
    super.key,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.title,
    this.error = '',
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? title;
  final String error;

  @override
  Widget build(BuildContext context) {
    final internalController = useTextEditingController(text: initialValue);
    final effectiveController = controller ?? internalController;

    useEffect(
      () {
        if (controller == null &&
            initialValue != null &&
            effectiveController.text != initialValue) {
          effectiveController.text = initialValue!;
        }
        return null;
      },
      [initialValue],
    );

    final textField = TextField(
      controller: effectiveController,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: Theme.of(context).textTheme.titleMedium?.color,
      cursorHeight: 22,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 10),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).customColors.secondaryTextColor,
          fontSize: 16,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CWPopUpItemTitle(
        title: title,
        spacing: 21,
        error: error,
        child: textField,
      ),
    );
  }
}
