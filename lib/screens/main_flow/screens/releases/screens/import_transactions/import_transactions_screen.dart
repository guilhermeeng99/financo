import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/import_transactions/import_transactions_model.dart';

class ImportTransactionsPopUp extends StatelessWidget {
  const ImportTransactionsPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return CWPopUp(
      title: context.t.transactions.import_transactions,
      centerContent: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          spacing: 30,
          children: [
            _Button(
              onTap: () => importTransactionsModel
                  .onTapDownloadDefaultExcelTransactions(context),
              title: context.t.common.actions.download_example,
              icon: Icons.download,
            ),
            _Button(
              onTap: () =>
                  importTransactionsModel.onTapUploadExcelTransactions(context),
              title: context.t.common.actions.choose_file,
              icon: Icons.upload,
              backgroundColor: Theme.of(context).customColors.button01,
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.title,
    required this.onTap,
    required this.icon,
    this.backgroundColor,
  });

  final String title;
  final void Function() onTap;
  final IconData icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Theme.of(context).scaffoldBackgroundColor),
      label: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).scaffoldBackgroundColor,
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
