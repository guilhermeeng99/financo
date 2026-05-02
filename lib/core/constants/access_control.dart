/// Master email — the single account that can manage the allowlist and
/// delete other users.
///
/// Hardcoded in three places that must stay in sync:
/// - this file (Flutter client)
/// - `firestore.rules` (`isMaster()` helper)
/// - `functions/src/config.ts` (`MASTER_EMAIL`)
///
/// A test (`test/core/constants/access_control_test.dart`) reads the rules
/// file and the functions config and asserts all three match.
const String kMasterEmail = 'guilhermeeng99@gmail.com';

/// Firestore collection holding the access allowlist. Doc id is the
/// lowercased email.
const String kAllowedEmailsCollection = 'allowed_emails';

/// Returns true when the given email is the master. Comparison is
/// case-insensitive; null/empty are non-master.
bool isMasterEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  return email.toLowerCase() == kMasterEmail;
}

/// Lowercases an email for safe comparison / Firestore doc id. Trims
/// whitespace; does NOT normalize Gmail dots/plus aliases.
String normalizeEmail(String email) => email.trim().toLowerCase();
