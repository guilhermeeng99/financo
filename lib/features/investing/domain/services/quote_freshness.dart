/// How long a cached quote is considered fresh enough to skip a network
/// refresh.
///
/// Both portfolio screens (dashboard + allocation) dedupe against the same
/// `quotes.fetchedAt` signal, so opening the second screen right after the
/// first refreshed does not re-hit the market APIs. Pull-to-refresh and the
/// manual refresh button bypass this window (force).
/// See `docs/specs/quotes.md`.
const Duration quoteFreshness = Duration(minutes: 15);
