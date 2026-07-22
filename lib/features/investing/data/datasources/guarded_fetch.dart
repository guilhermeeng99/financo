import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';

/// Runs a remote [fetch] (which returns its own `Either`), translating the
/// transport/parse exceptions every quote/FX/index adapter shares into a
/// [ServerFailure]. Centralizes the try/catch so adapters keep only their
/// request and mapping.
///
/// Catches every `Object` (not just `Exception`): a malformed payload typically
/// throws a cast `Error`, and adapters rely on that surfacing as a failure the
/// repository can degrade from — never crashing the refresh.
Future<Either<Failure, T>> guardedFetch<T>(
  Future<Either<Failure, T>> Function() fetch,
) async {
  try {
    return await fetch();
  } on Object {
    return const Left(ServerFailure('Market data request failed.'));
  }
}
