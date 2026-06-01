import 'package:financo/app/theme/app_theme.dart';
import 'package:financo/app/widgets/financo_date_field.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _ToggleMode { expense, income, transfer }

void main() {
  testWidgets('FinancoPillToggle keeps long option labels inside segments', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 382,
              child: FinancoPillToggle<_ToggleMode>(
                selected: _ToggleMode.expense,
                onChanged: (_) {},
                options: const [
                  FinancoPillToggleOption(
                    value: _ToggleMode.expense,
                    label: 'Despesa',
                    icon: FontAwesomeIcons.arrowUp,
                  ),
                  FinancoPillToggleOption(
                    value: _ToggleMode.income,
                    label: 'Receita',
                    icon: FontAwesomeIcons.arrowDown,
                  ),
                  FinancoPillToggleOption(
                    value: _ToggleMode.transfer,
                    label: 'Transferência',
                    icon: FontAwesomeIcons.arrowRightArrowLeft,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('FinancoDateField keeps BR dates on a single line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              child: FinancoDateField(
                label: 'Data',
                value: DateTime(2026, 6),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final dateText = tester.widget<Text>(find.text('01/06/2026'));
    expect(dateText.maxLines, 1);
    expect(dateText.softWrap, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FinancoDialog actions share shape and keep long labels inline', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: FinancoDialog(
            icon: FontAwesomeIcons.calendarCheck,
            title: 'Aplicar a quais ocorrências?',
            message: 'Mensagem curta',
            actions: [
              FinancoDialogAction(label: 'Apenas esta', onPressed: () {}),
              FinancoDialogAction(
                label: 'Esta e as subsequentes',
                kind: FinancoDialogActionKind.primary,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final outlined = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    final outlinedShape = outlined.style?.shape?.resolve(<WidgetState>{});
    final filledShape = filled.style?.shape?.resolve(<WidgetState>{});

    expect(outlinedShape, isA<RoundedRectangleBorder>());
    expect(filledShape, isA<RoundedRectangleBorder>());
    expect(
      (outlinedShape! as RoundedRectangleBorder).borderRadius,
      (filledShape! as RoundedRectangleBorder).borderRadius,
    );

    final longLabel = tester.widget<Text>(
      find.text('Esta e as subsequentes'),
    );
    expect(longLabel.maxLines, 1);
    expect(longLabel.softWrap, isFalse);
    expect(tester.takeException(), isNull);
  });
}
