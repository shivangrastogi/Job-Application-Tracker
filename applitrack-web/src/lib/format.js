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
