import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/validation/account_form_types.dart';

class AccountOperationService {
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

  Future<Either<Failure, AccountData>> createAccount(
    CreateAccountParams params,
    AccountFormData formData,
    BuildContext context,
  ) async {
    final Either<Failure, AccountData> result;

    switch (params.accountType) {
      case AccountType.checking:
        result = await _accountUsecase.createStandardAccount(
          name: params.name,
          initialBalance: params.initialBalance,
          currencyType: params.currencyType,
          iconType: params.iconType,
          initDate: params.initDate,
        );
      case AccountType.creditCard:
        result = await _accountUsecase.createCreditCardAccount(
          name: params.name,
          creditLimit: CreditLimit.create(formData.creditLimit!),
          firstBillDueDate: formData.firstBillDueDate!,
          billClosingDay: BillClosingDay.create(formData.billClosingDay),
          paymentAccountId: formData.paymentAccountId!,
          currencyType: params.currencyType,
          iconType: params.iconType,
          initDate: params.initDate,
        );
    }

    result.fold(
      (Failure failure) =>
          logger.e('Error creating account: ${failure.message}'),
      (AccountData account) async {
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
    final Either<Failure, AccountData> result;

    switch (params.accountType) {
      case AccountType.checking:
        result = await _accountUsecase.updateStandardAccount(
          id: params.id,
          name: params.name,
          initialBalance: params.initialBalance,
          currencyType: params.currencyType,
          iconType: params.iconType,
          initDate: params.initDate,
        );
      case AccountType.creditCard:
        result = await _accountUsecase.updateCreditCardAccount(
          id: params.id,
          name: params.name,
          creditLimit: params.creditLimit,
          firstBillDueDate: params.firstBillDueDate,
          billClosingDay: params.billClosingDay,
          paymentAccountId: params.paymentAccountId,
          currencyType: params.currencyType,
          iconType: params.iconType,
          initDate: params.initDate,
        );
    }

    result.fold(
      (Failure failure) =>
          logger.e('Error updating account: ${failure.message}'),
      (AccountData account) async {
        logger.i('Account updated successfully: ${account.name}');
        await accountsBloc.loadGroupedAccounts();
      },
    );

    return result;
  }
}
