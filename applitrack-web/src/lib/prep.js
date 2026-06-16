// A simple per-application interview-prep checklist. State is kept in
// localStorage (per device) keyed by application id — it's a personal working
// aid, so it doesn't need to sync or touch the application schema.
export const PREP_ITEMS = [
  'Research the company & product',
  'Re-read the job description',
  'Prepare 3 STAR stories',
  'Prepare questions to ask them',
  'Review your resume bullets',
  'Test your setup (camera/mic/link)',
];

const KEY = (id) => `applitrack.prep.${id}`;

export function getPrep(id) {
  try { return JSON.parse(localStorage.getItem(KEY(id)) || '[]'); } catch { return []; }
}

export function setPrep(id, items) {
  try { localStorage.setItem(KEY(id), JSON.stringify(items)); } catch { /* ignore */ }
}
