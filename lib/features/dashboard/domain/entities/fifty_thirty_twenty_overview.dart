import 'package:equatable/equatable.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';

/// Per-bucket compliance flag used by the dashboard card to colour each
/// row's icon and headline.
///
/// - `onTrack` — within target band.
/// - `over`    — needs/wants exceeded their target.
/// - `under`   — savings fell short of its target.
enum BucketStatus { onTrack, over, under }

/// Headline state for the whole card. See `docs/specs/fifty_thirty_twenty.md`
/// §1 for the aggregation rules.
enum FiftyThirtyTwentyStatus {
  /// No income recorded in the period — percentages can't be drawn.
  noData,

  /// Unclassified spend dominates classified — trust the user to
  /// classify before drawing conclusions.
  unclassifiedDominant,

  /// All three buckets within target.
  onTrack,

  /// At least one bucket off-target (but the data is trustworthy).
  needsAttention,
}

/// Presentation entity surfaced on `DashboardSummary.fiftyThirtyTwenty`.
/// Built by `compute50_30_20Overview` from the same data the dashboard
/// already fetches (income, expense, transfer transactions + categories
/// + accounts). The card reads this directly — no further joins.
class FiftyThirtyTwentyOverview extends Equatable {
  const FiftyThirtyTwentyOverview({
    required this.income,
    required this.needsSpent,
    required this.wantsSpent,
    required this.savingsAmount,
    required this.unclassifiedSpent,
    required this.unclassifiedCount,
    required this.hasInvestmentAccount,
    this.targets = FiftyThirtyTwentyTargets.classic,
  });

  /// Empty state singleton — used as the default when the dashboard has
  /// no period transactions or as a safe fallback before compose runs.
  static const empty = FiftyThirtyTwentyOverview(
    income: 0,
    needsSpent: 0,
    wantsSpent: 0,
    savingsAmount: 0,
    unclassifiedSpent: 0,
    unclassifiedCount: 0,
    hasInvestmentAccount: false,
  );

  /// Sum of income-type, non-transfer transactions in the period. This is
  /// the "100%" against which every percentage below is computed.
  final double income;

  /// Sum of expense transactions whose category resolves to `bucket == needs`.
  final double needsSpent;

  /// Sum of expense transactions whose category resolves to `bucket == wants`.
  final double wantsSpent;

  /// Net contribution to investment accounts in the period — i.e.
  /// `Σ(checking → investment)` minus `Σ(investment → checking)`, clamped
  /// at 0. See `docs/specs/fifty_thirty_twenty.md` §2 rule 4.
  final double savingsAmount;

  /// Sum of expense transactions whose resolved root category lacks a
  /// `bucket` (legacy, never classified, or orphan). Surfaced as the
  /// "unclassified" portion of the period spend.
  final double unclassifiedSpent;

  /// Backlog of **root expense categories** still missing a bucket. Not
  /// tied to whether they spent in the period — the goal is to tell the
  /// user how much classification work is left, not "how many of this
  /// month's categories are unclassified". Subcategories don't count
  /// (they inherit per rule 20). Orphan transactions also don't bump
  /// this number because there's no category for the user to classify.
  final int unclassifiedCount;

  /// Whether the user has at least one investment account. Drives which
  /// of the two "under-target" tips renders for savings.
  final bool hasInvestmentAccount;

  /// Active target split. Defaults to [FiftyThirtyTwentyTargets.classic]
  /// so legacy call-sites and the [empty] singleton continue to compile;
  /// production callers always pass the user's saved value.
  final FiftyThirtyTwentyTargets targets;

  // ── Computed: targets ─────────────────────────────────────────────

  double get needsTarget => income * targets.needs;
  double get wantsTarget => income * targets.wants;
  double get savingsTarget => income * targets.savings;

  // ── Computed: actual percentages (uncapped, 0 when no income) ──────

  double get needsPercent => income == 0 ? 0 : needsSpent / income;
  double get wantsPercent => income == 0 ? 0 : wantsSpent / income;
  double get savingsPercent => income == 0 ? 0 : savingsAmount / income;
  double get unclassifiedPercent =>
      income == 0 ? 0 : unclassifiedSpent / income;

  bool get hasData => income > 0;
  bool get hasUnclassified => unclassifiedCount > 0;

  // ── Computed: per-bucket status ────────────────────────────────────

  /// Headline state used by the card's top line. Aggregates per-bucket
  /// flags into a single user-facing message.
  FiftyThirtyTwentyStatus get status {
    if (!hasData) return FiftyThirtyTwentyStatus.noData;
    if (unclassifiedSpent > needsSpent + wantsSpent) {
      return FiftyThirtyTwentyStatus.unclassifiedDominant;
    }
    final allOnTrack = needsStatus == BucketStatus.onTrack &&
        wantsStatus == BucketStatus.onTrack &&
        savingsStatus == BucketStatus.onTrack;
    return allOnTrack
        ? FiftyThirtyTwentyStatus.onTrack
        : FiftyThirtyTwentyStatus.needsAttention;
  }

  BucketStatus get needsStatus =>
      needsPercent <= targets.needs ? BucketStatus.onTrack : BucketStatus.over;

  BucketStatus get wantsStatus =>
      wantsPercent <= targets.wants ? BucketStatus.onTrack : BucketStatus.over;

  BucketStatus get savingsStatus => savingsPercent >= targets.savings
      ? BucketStatus.onTrack
      : BucketStatus.under;

  // ── Computed: gap amounts ──────────────────────────────────────────

  /// How much over the needs target the user spent (>= 0).
  double get needsOverflow {
    final over = needsSpent - needsTarget;
    return over < 0 ? 0 : over;
  }

  /// How much over the wants target the user spent (>= 0).
  double get wantsOverflow {
    final over = wantsSpent - wantsTarget;
    return over < 0 ? 0 : over;
  }

  /// How much more needs to be invested to reach the savings target (>= 0).
  double get savingsShortfall {
    final short = savingsTarget - savingsAmount;
    return short < 0 ? 0 : short;
  }

  @override
  List<Object?> get props => [
    income,
    needsSpent,
    wantsSpent,
    savingsAmount,
    unclassifiedSpent,
    unclassifiedCount,
    hasInvestmentAccount,
    targets,
  ];
}
