// Pings every company in the catalog against its real source (ATS API, Amazon
// JSON, Workday CXS, or career page) and reports which links are live, which
// are bot-blocked, and which are actually broken.
//
//   npm run check:links
//
// Exits non-zero if any ATS/API endpoint (the ones that power live job sync) is
// broken — career-page bot-blocks (403/400) are reported but don't fail the run.
import { CATALOG } from '../src/lib/catalog.js';

const UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36';
const TIMEOUT = 20000;

async function req(url, { method = 'GET', headers = {}, body } = {}) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), TIMEOUT);
  try {
    const res = await fetch(url, { method, body, redirect: 'follow', signal: ctrl.signal, headers: { 'User-Agent': UA, ...headers } });
    const text = await res.text().catch(() => '');
    return { status: res.status, text };
  } catch (e) {
    return { status: 0, text: '', error: e.message };
  } finally {
    clearTimeout(timer);
  }
}

// Where to actually check each provider (mirrors src/lib/jobBoard.js).
function plan(c) {
  switch (c.provider) {
    case 'greenhouse': return { kind: 'api', url: `https://boards-api.greenhouse.io/v1/boards/${c.slug}/jobs` };
    case 'lever': return { kind: 'api', url: `https://api.lever.co/v0/postings/${c.slug}?mode=json` };
    case 'ashby': return { kind: 'api', url: `https://api.ashbyhq.com/posting-api/job-board/${c.slug}` };
    case 'smartrecruiters': return { kind: 'api', url: `https://api.smartrecruiters.com/v1/companies/${c.slug}/postings?limit=1` };
    case 'workable': return { kind: 'api', url: `https://apply.workable.com/api/v1/widget/accounts/${c.slug}?details=true` };
    case 'recruitee': return { kind: 'api', url: `https://${c.slug}.recruitee.com/api/offers/` };
    case 'amazon': {
      const cfg = c.config || {};
      const p = new URLSearchParams({ loc_query: cfg.loc_query || '', country: cfg.country || '', category: cfg.category || '', result_limit: '1' });
      return { kind: 'api', url: `https://www.amazon.jobs/en/search.json?${p}` };
    }
    case 'workday': {
      const cfg = c.config || {};
      return {
        kind: 'api',
        url: `https://${cfg.tenant}.${cfg.dc}.myworkdayjobs.com/wday/cxs/${cfg.tenant}/${cfg.site}/jobs`,
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ limit: 1, offset: 0, searchText: cfg.query || '' }),
      };
    }
    case 'custom': return { kind: 'page', url: c.careerUrl };
    default: return null;
  }
}

// Pull a rough job count out of whatever JSON shape came back.
function jobCount(text) {
  try {
    const d = JSON.parse(text);
    if (Array.isArray(d)) return d.length;                       // lever
    if (typeof d.total === 'number') return d.total;             // workday
    if (typeof d.hits === 'number') return d.hits;               // amazon
    if (d.meta && typeof d.meta.total === 'number') return d.meta.total; // greenhouse
    if (Array.isArray(d.jobs)) return d.jobs.length;             // ashby/greenhouse
    if (Array.isArray(d.offers)) return d.offers.length;         // recruitee
    if (typeof d.totalFound === 'number') return d.totalFound;   // smartrecruiters
  } catch { /* not json */ }
  return null;
}

const results = { ok: [], blocked: [], broken: [] };

for (const c of CATALOG) {
  const p = plan(c);
  if (!p) { results.broken.push([c.name, 'no check plan']); continue; }
  const r = await req(p.url, p);
  if (p.kind === 'api') {
    if (r.status === 200) {
      const n = jobCount(r.text);
      results.ok.push([c.name, `${c.provider} · ${n ?? '?'} jobs`]);
    } else {
      results.broken.push([c.name, `${c.provider} HTTP ${r.status}${r.error ? ` (${r.error})` : ''}`]);
    }
  } else { // career page
    if (r.status === 200) results.ok.push([c.name, `page 200`]);
    else if ([400, 401, 403, 405, 429].includes(r.status)) results.blocked.push([c.name, `page HTTP ${r.status} — likely bot protection`]);
    else results.broken.push([c.name, `page HTTP ${r.status}${r.error ? ` (${r.error})` : ''}`]);
  }
  process.stdout.write('.');
}

console.log('\n');
const line = (label, rows) => {
  console.log(`${label} (${rows.length})`);
  for (const [name, detail] of rows) console.log(`   ${name.padEnd(26)} ${detail}`);
  console.log('');
};
line('✓ LIVE', results.ok);
if (results.blocked.length) line('⚠ BOT-BLOCKED (verify in a browser)', results.blocked);
if (results.broken.length) line('✗ BROKEN', results.broken);

console.log(`Summary: ${results.ok.length} live, ${results.blocked.length} bot-blocked, ${results.broken.length} broken.`);
process.exit(results.broken.length > 0 ? 1 : 0);
