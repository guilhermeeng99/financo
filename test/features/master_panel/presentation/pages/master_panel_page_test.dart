import 'package:bloc_test/bloc_test.dart';
import 'package:financo/app/theme/app_theme.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_cubit.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_state.dart';
import 'package:financo/features/master_panel/presentation/pages/master_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _MockMasterPanelCubit extends MockCubit<MasterPanelState>
    implements MasterPanelCubit {}

void main() {
  late _MockMasterPanelCubit cubit;
  late MockAuthBloc authBloc;

  setUpAll(() async {
    // The allowlist tab renders DateFormat timestamps.
    await initializeDateFormatting();
  });

  setUp(() {
    cubit = _MockMasterPanelCubit();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(Authenticated(UserFactory.entity()));
    when(cubit.load).thenAnswer((_) async {});
  });

  Future<void> pumpPanel(WidgetTester tester, MasterPanelState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<MasterPanelCubit>.value(value: cubit),
          ],
          child: const MasterPanelPage(),
        ),
      ),
    );
  }

  group('MasterPanelPage busy state', () {
    testWidgets('blocks the panel with a spinner while a delete runs', (
      tester,
    ) async {
      // Regression: deleting a user is a multi-second server cascade over 12
      // collections plus Auth. `busy` was emitted but only read to disable the
      // allowlist FAB, so on the users tab pressing Delete changed nothing on
      // screen and read as "the button did nothing".
      await pumpPanel(
        tester,
        const MasterPanelLoaded(users: [], allowedEmails: [], busy: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no spinner once the panel is idle', (tester) async {
      await pumpPanel(
        tester,
        const MasterPanelLoaded(users: [], allowedEmails: []),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
