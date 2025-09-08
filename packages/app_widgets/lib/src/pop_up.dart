import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWPopUp extends StatelessWidget {
  const CWPopUp({
    required this.centerContent,
    required this.title,
    this.bottomContent,
    this.padding,
    super.key,
  });

  final Widget centerContent;
  final Widget? bottomContent;
  final EdgeInsetsGeometry? padding;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.opacityX(0.5),
      body: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(onTap: PopUpManager.pop),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: CWCard(
                  child: Column(
                    children: [
                      Padding(
                        padding: padding ??
                            const EdgeInsets.only(
                              top: 10,
                              left: 30,
                              right: 10,
                            ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(title),
                                InkWell(
                                  onTap: PopUpManager.pop,
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: centerContent,
                            ),
                          ],
                        ),
                      ),
                      if (bottomContent != null) ...[
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).customColors.fourth,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: bottomContent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class PopupMenuAction<T> {
  String getLabel(BuildContext context);
  IconData getIcon();
  void execute(T item);
  bool isVisible(T item) => true;
}

class CWPopupMenuButton<T, A extends PopupMenuAction<T>>
    extends StatelessWidget {
  const CWPopupMenuButton({
    required this.item,
    required this.actions,
    super.key,
  });

  final T item;
  final List<A> actions;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).dividerColor;

    return PopupMenuButton<A>(
      color: Theme.of(context).customColors.third,
      onSelected: (A action) {
        action.execute(item);
      },
      itemBuilder: (BuildContext context) => actions
          .where((action) => action.isVisible(item))
          .map(
            (action) => PopupMenuItem<A>(
              value: action,
              child: Row(
                spacing: 8,
                children: [
                  Icon(action.getIcon(), color: color, size: 16),
                  Text(
                    action.getLabel(context),
                    style: TextStyle(color: color, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.all(5),
        child: const Icon(Icons.more_vert, size: 25),
      ),
    );
  }
}

class CWPopUpItemTitle extends StatelessWidget {
  const CWPopUpItemTitle({
    required this.child,
    this.title,
    this.titleSpacing = 0,
    this.error = '',
    this.errorOffset = const Offset(0, 10),
    super.key,
  });

  final Widget child;
  final String? title;
  final String error;
  final double titleSpacing;
  final Offset errorOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).customColors.secondaryTextColor,
          ),
        ),
        Gap(titleSpacing),
        child,
        Transform.translate(
          offset: errorOffset,
          child: Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class CWPopUpUnderLine extends StatelessWidget {
  const CWPopUpUnderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: Theme.of(context).dividerColor);
  }
}
