import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/screens/create_and_edit_transaction/create_and_edit_transaction_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/screens/create_and_edit_transaction/create_and_edit_transaction_screen.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/screens/import_transactions/import_transactions_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/screens/import_transactions/import_transactions_screen.dart';

ReleasesModel get releasesModel => Modular.get<ReleasesModel>();

class ReleasesModel {
  void onTapFloatingActionButton() {
    PopUpManager.showDialog(
      builder: (c) => WidgetModuleProvider(
        module: CreateAndEditTransactionModule(),
        child: () => CreateAndEditTransactionPopUp(
          CreateAndEditTransactionPopUpArgs(
            type: CreateAndEditTransactionPopUpType.create,
          ),
        ),
      ),
    );
  }

  void onTapImportPopUp() => PopUpManager.showDialog(
    builder: (c) => WidgetModuleProvider(
      module: ImportTransactionsModule(),
      child: ImportTransactionsPopUp.new,
    ),
  );
}
