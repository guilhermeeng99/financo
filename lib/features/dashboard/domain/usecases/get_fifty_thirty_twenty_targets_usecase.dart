import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

/// Resolves the user's active 50/30/20 split, falling back to
/// [FiftyThirtyTwentyTargets.classic] when no custom value is stored.
/// Single source of truth for "what targets should the dashboard use" —
/// callers never read the user entity directly for this.
class GetFiftyThirtyTwentyTargetsUseCase {
  const GetFiftyThirtyTwentyTargetsUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  Future<Either<Failure, FiftyThirtyTwentyTargets>> call(String userId) async {
    final result = await _profileRepository.getProfile(userId);
    return result.map(
      (user) =>
          user.fiftyThirtyTwentyTargets ?? FiftyThirtyTwentyTargets.classic,
    );
  }
}
