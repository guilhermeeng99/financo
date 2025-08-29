import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_model.dart';

enum TransactionMenuAction implements PopupMenuAction<TransactionData> {
  edit('edit'),
  pay('pay'),
  unPay('unPay'),
  clone('clone'),
  delete('delete');

  const TransactionMenuAction(this.value);

  final String value;

  @override
  String getLabel(BuildContext context) {
    switch (this) {
      case TransactionMenuAction.edit:
        return context.t.common.actions.edit;
      case TransactionMenuAction.pay:
        return context.t.common.actions.pay;
      case TransactionMenuAction.unPay:
        return context.t.common.actions.unpay;
      case TransactionMenuAction.clone:
        return context.t.common.actions.clone;
      case TransactionMenuAction.delete:
        return context.t.common.actions.delete;
    }
  }

  @override
  IconData getIcon() {
    switch (this) {
      case TransactionMenuAction.edit:
        return Icons.edit;
      case TransactionMenuAction.delete:
        return Icons.delete;
      case TransactionMenuAction.pay:
        return Icons.check;
      case TransactionMenuAction.unPay:
        return Icons.close;
      case TransactionMenuAction.clone:
        return Icons.copy;
    }
  }

  @override
  void execute(TransactionData transaction) {
    switch (this) {
      case TransactionMenuAction.edit:
        releasesModel.onTapOpenTransaction(transaction);
      case TransactionMenuAction.delete:
        releasesModel.onTapDeleteTransaction(transaction);
      case TransactionMenuAction.clone:
        releasesModel.onTapCloneTransaction(transaction);
      case TransactionMenuAction.pay:
        releasesModel.onTapPayTransaction(transaction);
      case TransactionMenuAction.unPay:
        releasesModel.onTapUnPayTransaction(transaction);
    }
  }

  @override
  bool isVisible(TransactionData transaction) {
    switch (this) {
      case TransactionMenuAction.pay:
        return transaction.paymentStatus == TransactionPaymentStatus.paid;
      case TransactionMenuAction.unPay:
        return transaction.paymentStatus == TransactionPaymentStatus.unpaid;
      case TransactionMenuAction.edit:
      case TransactionMenuAction.clone:
      case TransactionMenuAction.delete:
        return true;
    }
  }
}
