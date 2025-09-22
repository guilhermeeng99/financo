import 'package:app_widgets/app_widgets.dart';

class HomeScreenContainer extends StatelessWidget {
  const HomeScreenContainer({
    required this.child,
    required this.bottomChild,
    required this.title,
    super.key,
  });

  final Widget child;
  final Widget bottomChild;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CWCardStyled(
        bottomChild: bottomChild,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
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
      ),
    );
  }
}
