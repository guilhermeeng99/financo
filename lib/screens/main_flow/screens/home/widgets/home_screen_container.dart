import 'package:app_widgets/app_widgets.dart';

class HomeScreenContainer extends StatelessWidget {
  const HomeScreenContainer({
    required this.child,
    required this.bottomChild,
    required this.title,
    this.subTitle,
    super.key,
  });

  final Widget child;
  final Widget bottomChild;
  final String title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return CWCardStyled(
      bottomChild: bottomChild,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  subTitle ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const Gap(10),
            const CWDivider(height: 1, width: double.infinity),
            const Gap(30),
            child,
          ],
        ),
      ),
    );
  }
}
