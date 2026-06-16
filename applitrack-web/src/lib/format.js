export const uid = () =>
  (crypto.randomUUID ? crypto.randomUUID() : 'id-' + Date.now() + '-' + Math.random().toString(16).slice(2));

export const nowIso = () => new Date().toISOString();

export function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  if (isNaN(d)) return '';
  return d.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
}

export function relDate(iso) {
  if (!iso) return '';
  const d = new Date(iso);
  const diff = Math.floor((Date.now() - d) / 86400000);
  if (diff <= 0) return 'Today';
  if (diff === 1) return 'Yesterday';
  if (diff < 30) return `${diff}d ago`;
  return fmtDate(iso);
}

export function startOfPeriod(period) {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (period === 'daily') return today;
  if (period === 'weekly') {
    const dow = (today.getDay() + 6) % 7; // Monday = 0
    return new Date(today.getTime() - dow * 86400000);
  }
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

export function initials(name) {
  if (!name) return '?';
  return name.trim()[0].toUpperCase();
}

// Hostname of a job URL (without www.) — used as a friendly fallback title for
// link-only applications that don't have a company/role filled in yet.
export function jobHost(url) {
  if (!url) return '';
  try {
    const u = new URL(url.startsWith('http') ? url : `https://${url}`);
    return u.hostname.replace(/^www\./, '');
  } catch {
    return '';
  }
}

// Best label we can show for an application, even if details aren't filled yet.
export function appTitle(a) {
  return a.role || a.company || jobHost(a.jobUrl) || 'Untitled job';
}

// Canonical form of a URL for duplicate comparison: lowercased host+path+query,
// no hash, no trailing slash. Keeps the query (some boards put the job id there).
export function normalizeUrl(url) {
  if (!url) return '';
  try {
    const u = new URL(url.startsWith('http') ? url : `https://${url}`);
    return `${u.host}${u.pathname}${u.search}`.toLowerCase().replace(/\/+$/, '');
  } catch {
    return url.trim().toLowerCase().replace(/\/+$/, '');
  }
}

// Loose check that a string is a usable web link (parses to a host with a dot).
export function looksLikeUrl(s) {
  if (!s || !s.trim()) return false;
  try {
    const u = new URL(s.startsWith('http') ? s : `https://${s}`);
    return !!u.hostname && u.hostname.includes('.');
  } catch {
    return false;
  }
}

// Title-case a slug: "acme-corp" / "acme_corp" → "Acme Corp".
function titleize(s) {
  return (s || '')
    .replace(/[-_]+/g, ' ')
    .split(' ')
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join(' ')
    .trim();
}

// Guess the employer from a job link so link-first capture still gets a company.
// ATS hosts put the company in the slug; generic career sites in the domain;
// job boards (LinkedIn/Naukri/…) keep it in the path, so we can't guess → ''.
export function guessCompanyFromUrl(url) {
  if (!url) return '';
  let u;
  try { u = new URL(url.startsWith('http') ? url : `https://${url}`); } catch { return ''; }
  const host = u.hostname.replace(/^www\./, '');
  const parts = u.pathname.split('/').filter(Boolean);

  // ATS providers where the slug is the company
  if (host.endsWith('greenhouse.io') && parts[0]) return titleize(parts[0]);
  if (host.endsWith('lever.co') && parts[0]) return titleize(parts[0]);
  if (host.endsWith('ashbyhq.com') && parts[0]) return titleize(parts[0]);
  if (host === 'apply.workable.com' && parts[0]) return titleize(parts[0]);
  if (host.endsWith('.workable.com')) return titleize(host.split('.')[0]);
  if (host.endsWith('.recruitee.com')) return titleize(host.split('.')[0]);
  if (host.includes('smartrecruiters.com') && parts[0]) return titleize(parts[0]);
  if (host.includes('myworkdayjobs.com')) return titleize(host.split('.')[0]);

  // Job boards: company lives in the path, not the host → can't guess
  const boards = ['linkedin.com', 'naukri.com', 'indeed.com', 'glassdoor.com', 'wellfound.com',
    'instahyre.com', 'monster.com', 'ziprecruiter.com', 'dice.com', 'simplyhired.com',
    'foundit.in', 'shine.com', 'timesjobs.com', 'angel.co'];
  if (boards.some((b) => host === b || host.endsWith(`.${b}`))) return '';

  // Otherwise treat as a company career site: use the second-level domain.
  const segs = host.split('.');
  const second = segs.length >= 2 ? segs[segs.length - 2] : segs[0];
  const ignore = new Set(['careers', 'jobs', 'job', 'apply', 'work', 'hire', 'boards', 'recruiting', 'talent', 'www', 'co']);
  if (ignore.has(second)) return '';
  return titleize(second);
}
