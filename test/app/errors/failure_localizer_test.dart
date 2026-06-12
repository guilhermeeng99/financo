import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Pin the locale so expectations read from the same translation tree
    // localizedFailure resolves through, regardless of host machine locale.
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('localizedFailure', () {
    test('null falls back to the generic unexpected message', () {
      expect(localizedFailure(null), t.errors.unexpected);
    });

    test('ValidationFailure passes its own (already localized) message '
        'through verbatim', () {
      const failure = ValidationFailure('Pick a category first.');
      expect(localizedFailure(failure), 'Pick a category first.');
    });

    test('maps the simple failure types to their t.errors entries', () {
      expect(localizedFailure(const AuthFailure()), t.errors.auth);
      expect(localizedFailure(const AiFailure()), t.errors.ai);
      expect(localizedFailure(const ServerFailure()), t.errors.server);
      expect(localizedFailure(const EmptyNameFailure()), t.errors.emptyName);
      expect(
        localizedFailure(const NegativeAmountFailure()),
        t.errors.negativeAmount,
      );
      expect(
        localizedFailure(const AccessDeniedFailure('x@y.com')),
        t.errors.accessDenied,
      );
    });

    test('maps the investment rule failures to t.investments entries', () {
      expect(
        localizedFailure(const TargetPercentOutOfRangeFailure()),
        t.investments.targetPercentOutOfRange,
      );
      expect(
        localizedFailure(const ParentAssetClassNotFoundFailure()),
        t.investments.parentClassNotFound,
      );
      expect(
        localizedFailure(const SubclassCannotBeParentFailure()),
        t.investments.subclassCannotBeParent,
      );
      expect(
        localizedFailure(const SelfParentAssetClassFailure()),
        t.investments.classCannotBeOwnParent,
      );
      expect(
        localizedFailure(const ClassOwnsSubclassesFailure()),
        t.investments.classOwnsSubclasses,
      );
      expect(
        localizedFailure(const AssetClassNotFoundFailure()),
        t.investments.assetClassNotFound,
      );
      expect(
        localizedFailure(const HoldingAccountNotInvestmentFailure()),
        t.investments.holdingAccountNotInvestment,
      );
      expect(
        localizedFailure(const HoldingRequiresSubclassFailure()),
        t.investments.holdingRequiresSubclass,
      );
    });

    test('maps access/master/budget failures to their feature entries', () {
      expect(
        localizedFailure(const InvalidEmailFormatFailure()),
        t.validators.emailInvalid,
      );
      expect(
        localizedFailure(const MasterEmailAlreadyAllowedFailure()),
        t.masterPanel.masterAlreadyAllowed,
      );
      expect(
        localizedFailure(const DuplicateBudgetCategoryFailure()),
        t.budgets.duplicateCategory,
      );
    });

    test('formats the carried amount on AllocationExceedsBalanceFailure', () {
      const failure = AllocationExceedsBalanceFailure(1234.5);
      expect(
        localizedFailure(failure),
        t.investments.allocationExceedsBalance(
          available: formatCurrency(1234.5),
        ),
      );
      // The raw double must never leak into UI copy unformatted.
      expect(localizedFailure(failure), isNot(contains('1234.5')));
    });

    test('picks root vs subclass copy on TargetSumExceededFailure', () {
      expect(
        localizedFailure(
          const TargetSumExceededFailure(availablePercent: 40, isRoot: true),
        ),
        t.investments.targetSumExceedsRoot(available: '40%'),
      );
      expect(
        localizedFailure(
          const TargetSumExceededFailure(availablePercent: 25, isRoot: false),
        ),
        t.investments.targetSumExceedsSub(available: '25%'),
      );
    });

    test('interpolates blocking counts on asset-class delete failures', () {
      expect(
        localizedFailure(const AssetClassHasSubclassesFailure(2)),
        t.investments.deleteBlockedBySubclasses(count: 2),
      );
      expect(
        localizedFailure(const AssetClassHasHoldingsFailure(3)),
        t.investments.deleteBlockedByHoldings(count: 3),
      );
    });

    test('resolves through the active locale, not a cached string', () {
      final english = localizedFailure(const ServerFailure());

      LocaleSettings.setLocaleSync(AppLocale.ptBr);
      addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

      final portuguese = localizedFailure(const ServerFailure());
      expect(portuguese, isNotEmpty);
      expect(portuguese, isNot(english));
    });
  });
}
