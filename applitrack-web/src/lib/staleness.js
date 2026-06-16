import { isActiveStatus } from './enums';

// An active application with no update in this many days is "stale" — worth a
// follow-up nudge. Wishlist items aren't applied yet, so they don't count.
export const STALE_DAYS = 14;

export function daysSince(iso) {
  if (!iso) return 0;
  return Math.floor((Date.now() - new Date(iso).getTime()) / 86400000);
}

export function isStale(a) {
  return a.status !== 'wishlist'
    && isActiveStatus(a.status)
    && daysSince(a.updatedAt) >= STALE_DAYS;
}
