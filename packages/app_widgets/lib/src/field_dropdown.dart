import 'package:app_widgets/app_widgets.dart';

class CWDropdownField<T> extends StatelessWidget {
  const CWDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.title,
    super.key,
    this.textStyle,
    this.isExpanded = false,
  });

  final String? title;
  final T value;
  final List<T> items;
  final void Function(T?) onChanged;
  final Widget Function(T item, BuildContext context) itemBuilder;
  final TextStyle? textStyle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: title,
      child: DropdownButton<T>(
        value: value,
        onChanged: onChanged,
        isExpanded: isExpanded,
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        style: textStyle ?? const TextStyle(fontSize: 18),
        underline: const CWPopUpUnderLine(),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: itemBuilder(item, context),
          );
        }).toList(),
      ),
    );
  }
}
