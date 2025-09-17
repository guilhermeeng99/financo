import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_model.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/widgets/releases_screen_account_area.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/widgets/releases_screen_transaction_area.dart';

class ReleasesScreen extends StatelessWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const _FloatingActionButton(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            spacing: 20,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: const Column(
                  spacing: 10,
                  children: [
                    CWACalendarNavigator(),
                    CWAReleasesScreenAccount(),
                  ],
                ),
              ),
              const CWAReleasesScreenTransactions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingActionButton extends HookWidget {
  const _FloatingActionButton();

  @override
  Widget build(BuildContext context) {
    final showSecondButton = useState(false);

    return MouseRegion(
      onEnter: (_) => showSecondButton.value = true,
      onExit: (_) => showSecondButton.value = false,
      child: Container(
        width: 80,
        height: 170,
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: CWFloatingActionButton(
                tooltipMessage: context.t.transactions.new_transaction,
                onTap: releasesModel.onTapFloatingActionButton,
              ),
            ),
            if (showSecondButton.value)
              Positioned(
                bottom: 70,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showSecondButton.value ? 1.0 : 0.0,
                  child: CWFloatingActionButton(
                    icon: Icons.upload,
                    size: 40,
                    tooltipMessage: context.t.transactions.import_transactions,
                    onTap: releasesModel.onTapImportPopUp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
