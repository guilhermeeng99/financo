const TTL_MS = 5 * 60 * 1000;
const MAX_ENTRIES = 1000;

const seen = new Map<string, number>();

const evictStale = (now: number): void => {
  for (const [id, ts] of seen) {
    if (now - ts > TTL_MS) seen.delete(id);
  }
  while (seen.size > MAX_ENTRIES) {
    const oldest = seen.keys().next().value;
    if (oldest === undefined) break;
    seen.delete(oldest);
  }
};

export const isDuplicate = (id: string): boolean => {
  const now = Date.now();
  evictStale(now);
  if (seen.has(id)) return true;
  seen.set(id, now);
  return false;
};

export const _resetDedupeForTests = (): void => {
  seen.clear();
};
