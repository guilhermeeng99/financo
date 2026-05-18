import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

/// Persists a new 50/30/20 split on the user document. Read-modify-write
/// against `ProfileRepository` so we don't overwrite unrelated fields
/// (name, photoUrl, etc.).
///
/// Returns `Left(ValidationFailure)` when the submitted targets do not
/// satisfy [FiftyThirtyTwentyTargets.isValid] (sum != 1.0 within
/// tolerance, or any component negative). The caller's UI should
/// disable submit until validation passes — this is a defensive net.
class UpdateFiftyThirtyTwentyTargetsUseCase {
  const UpdateFiftyThirtyTwentyTargetsUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  Future<Either<Failure, FiftyThirtyTwentyTargets>> call({
    required String userId,
    required FiftyThirtyTwentyTargets targets,
  }) async {
    if (!targets.isValid) {
      return const Left(
        ValidationFailure(
          'Os percentuais precisam somar 100% e ser não-negativos.',
        ),
      );
    }
    final profileResult = await _profileRepository.getProfile(userId);
    return profileResult.fold(
      Left.new,
      (user) async {
        final updated = user.copyWith(fiftyThirtyTwentyTargets: targets);
        final result = await _profileRepository.updateProfile(updated);
        return result.map((u) => targets);
      },
    );
  }
}
