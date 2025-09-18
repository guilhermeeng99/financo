import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';

class CWAFilteredReleasesScreenAccount extends StatelessWidget {
  const CWAFilteredReleasesScreenAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const  CWCard(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          spacing: 25,
          children: [ CWAccountsArea(),  CWAccountsResults()],
        ),
      ),
    );
  }
}
