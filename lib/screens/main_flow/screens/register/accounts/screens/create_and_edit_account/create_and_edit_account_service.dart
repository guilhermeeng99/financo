import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_bloc.dart';

import 'validation/account_form_types.dart';

class AccountOperationService {
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

  Future<Either<Failure, AccountData>> createAccount(
    CreateAccountParams params,
    AccountFormData formData,
    BuildContext context,
  ) async {
    final result = await _accountUsecase.createAccount(
      name: params.name,
      accountType: params.accountType,
      initialBalance: params.initialBalance,
      currencyType: params.currencyType,
      iconType: params.iconType,
      initDate: params.initDate,
    );

    result.fold(
      (failure) => logger.e('Error creating account: ${failure.message}'),
      (account) async {
        logger.i('Account created successfully: ${account.name}');
        await accountsBloc.loadGroupedAccounts();
      },
    );

    return result;
  }

  Future<Either<Failure, AccountData>> updateAccount(
    UpdateAccountParams params,
    AccountFormData formData,
    BuildContext context,
  ) async {
    final result = await _accountUsecase.updateAccount(
      id: params.id,
      name: params.name,
      accountType: params.accountType,
      initialBalance: params.initialBalance,
      currencyType: params.currencyType,
      iconType: params.iconType,
      initDate: params.initDate,
    );

    result.fold(
      (failure) => logger.e('Error updating account: ${failure.message}'),
      (account) async {
        logger.i('Account updated successfully: ${account.name}');
        await accountsBloc.loadGroupedAccounts();
      },
    );

    return result;
  }
}
