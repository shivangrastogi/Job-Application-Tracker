// Resume / cover-letter performance math, shared by the Analytics and Dashboard
// pages. Status sets are kept identical to the mobile app so the numbers match.

export const MIN_RESUME_SAMPLE = 5; // below this, a resume's rates are noise

const SENT = (a) => a.status !== 'wishlist'; // resume actually went out
const RESPONDED = new Set(['phoneScreen', 'technicalRound', 'onsiteInterview', 'offerReceived', 'accepted', 'rejected']);
const INTERVIEWED = new Set(['phoneScreen', 'technicalRound', 'onsiteInterview', 'offerReceived', 'accepted']);
const OFFERED = new Set(['offerReceived', 'accepted']);

function bucket() {
  return { sent: 0, responded: 0, interviewed: 0, offered: 0 };
}

function tally(b, status) {
  b.sent++;
  if (RESPONDED.has(status)) b.responded++;
  if (INTERVIEWED.has(status)) b.interviewed++;
  if (OFFERED.has(status)) b.offered++;
}

function withRates(extra, b) {
  return {
    ...extra, ...b,
    lowData: b.sent < MIN_RESUME_SAMPLE,
    responseRate: b.sent ? Math.round((b.responded / b.sent) * 100) : 0,
    interviewRate: b.sent ? Math.round((b.interviewed / b.sent) * 100) : 0,
    offerRate: b.sent ? Math.round((b.offered / b.sent) * 100) : 0,
  };
}

// Per-resume stats. Applications with no resume fall into a shared "No resume"
// bucket. Sorted: enough-data first, then by interview rate, then volume.
export function resumeStats(apps, documents) {
  const byId = {};
  for (const a of apps) {
    if (!SENT(a)) continue;
    const key = a.resumeVersionId || '__none__';
    tally((byId[key] ||= bucket()), a.status);
  }
  const nameOf = (id) => {
    if (id === '__none__') return 'No resume';
    const d = documents.find((x) => x.id === id);
    if (!d) return 'Deleted resume';
    return d.version ? `${d.name} · v${d.version}` : d.name;
  };
  return Object.entries(byId)
    .map(([id, b]) => withRates({ id, name: nameOf(id) }, b))
    .sort((a, b) =>
      (a.lowData - b.lowData) ||
      (b.interviewRate - a.interviewRate) ||
      (b.sent - a.sent));
}

// The strongest resume with a trustworthy sample, or null.
export function bestResume(stats) {
  const eligible = stats.filter((s) => !s.lowData && s.id !== '__none__' && s.interviewed > 0);
  if (eligible.length === 0) return null;
  return eligible.reduce((best, s) => (s.interviewRate > best.interviewRate ? s : best));
}

// With- vs without-cover-letter conversion, across sent applications.
export function coverLetterStats(apps) {
  const withCl = bucket();
  const without = bucket();
  for (const a of apps) {
    if (!SENT(a)) continue;
    tally(a.coverLetterUsed ? withCl : without, a.status);
  }
  return [
    withRates({ id: 'with', name: 'With cover letter' }, withCl),
    withRates({ id: 'without', name: 'Without cover letter' }, without),
  ].filter((r) => r.sent > 0);
}
