// The default resume is a per-device convenience (preselected on new
// applications). Mobile stores its own default in app settings; on web we keep
// it in localStorage so it doesn't need a synced settings collection.
const KEY = 'applitrack.defaultResumeId';

export function getDefaultResumeId() {
  try { return localStorage.getItem(KEY) || null; } catch { return null; }
}

export function setDefaultResumeId(id) {
  try {
    if (id) localStorage.setItem(KEY, id);
    else localStorage.removeItem(KEY);
  } catch { /* ignore storage failures */ }
}
