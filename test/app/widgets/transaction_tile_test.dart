import 'package:financo/app/theme/app_theme.dart';
import 'package:financo/app/widgets/settle_button.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../harness/factories/transaction_factory.dart';

void main() {
  setUpAll(() async {
    // The subtitle renders DateFormat.Md — flutter_localizations loads the
    // date symbols in the app; a bare widget test must load them itself.
    await initializeDateFormatting();
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    required TransactionEntity transaction,
    VoidCallback? onSettle,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: TransactionTile(
            transaction: transaction,
            showSettlementStatus: true,
            onSettle: onSettle,
          ),
        ),
      ),
    );
  }

  final pendingExpense = TransactionFactory.expense(
    settlementStatus: TransactionSettlementStatus.pending,
    dueDate: DateTime(2030, 5, 10),
  );

  group('TransactionTile settle action', () {
    testWidgets('offers the button on a pending row and fires the callback', (
      tester,
    ) async {
      var settled = 0;
      await pumpTile(
        tester,
        transaction: pendingExpense,
        onSettle: () => settled++,
      );

      expect(find.byType(SettleButton), findsOneWidget);
      await tester.tap(find.byType(SettleButton));
      expect(settled, 1);
    });

    testWidgets('hides the button on an already settled row', (tester) async {
      await pumpTile(
        tester,
        transaction: TransactionFactory.expense(),
        onSettle: () {},
      );

      expect(find.byType(SettleButton), findsNothing);
    });

    testWidgets('hides the button on a transfer leg', (tester) async {
      // SettleTransactionUseCase rejects transfers outright, so the tile must
      // not offer an action that can only fail.
      await pumpTile(
        tester,
        transaction: TransactionFactory.expense(
          settlementStatus: TransactionSettlementStatus.pending,
          dueDate: DateTime(2030, 5, 10),
          linkedTransactionId: 'tx-other-leg',
        ),
        onSettle: () {},
      );

      expect(find.byType(SettleButton), findsNothing);
    });

    testWidgets('hides the button on pages that pass no settle action', (
      tester,
    ) async {
      await pumpTile(tester, transaction: pendingExpense);

      expect(find.byType(SettleButton), findsNothing);
    });
  });
}
