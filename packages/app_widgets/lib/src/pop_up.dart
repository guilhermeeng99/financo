import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWPopUp extends StatelessWidget {
  const CWPopUp({
    required this.centerContent,
    required this.bottomContent,
    required this.title,
    this.padding,
    super.key,
  });

  final Widget centerContent;
  final Widget bottomContent;
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SvgPicture.asset(
                                      svgs.x,
                                      width: 20,
                                      height: 20,
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
