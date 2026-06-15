// Live job fetching from public ATS APIs, routed through the /proxy server to
// bypass browser CORS. Mirrors lib/services/job_board_service.dart.

const PROXY = (url) => `/proxy?url=${encodeURIComponent(url)}`;

async function getJson(url) {
  const res = await fetch(PROXY(url), { headers: { Accept: 'application/json' } });
  if (res.status === 404) throw new Error('Company not found — check the slug.');
  if (!res.ok) throw new Error(`Job board returned error ${res.status}.`);
  return res.json();
}
async function postJson(url, body) {
  const res = await fetch(PROXY(url), {
    method: 'POST',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`Job board returned error ${res.status}.`);
  return res.json();
}

function workType(text) {
  if (!text) return 'unknown';
  const t = text.toLowerCase();
  if (t.includes('remote')) return 'remote';
  if (t.includes('hybrid')) return 'hybrid';
  if (t.includes('on-site') || t.includes('onsite') || t.includes('office')) return 'onsite';
  return 'unknown';
}
const J = (o) => ({ workType: 'unknown', location: null, department: null, employmentType: null, url: null, postedAt: null, ...o });

export async function fetchJobs(company) {
  const c = company;
  switch (c.provider) {
    case 'greenhouse': return greenhouse(c);
    case 'lever': return lever(c);
    case 'ashby': return ashby(c);
    case 'smartrecruiters': return smartrecruiters(c);
    case 'workable': return workable(c);
    case 'recruitee': return recruitee(c);
    case 'amazon': return amazon(c);
    case 'workday': return workday(c);
    default: throw new Error(`${c.name} uses a custom page — open it in the browser.`);
  }
}

async function greenhouse(c) {
  const d = await getJson(`https://boards-api.greenhouse.io/v1/boards/${c.slug}/jobs?content=true`);
  return (d.jobs || []).map((m) => J({
    id: 'gh_' + m.id, companyId: c.id, companyName: c.name, title: m.title?.trim() || 'Untitled',
    location: m.location?.name || null, department: m.departments?.[0]?.name || null,
    workType: workType(m.location?.name), url: m.absolute_url, postedAt: m.updated_at,
  }));
}
async function lever(c) {
  const d = await getJson(`https://api.lever.co/v0/postings/${c.slug}?mode=json`);
  return (d || []).map((m) => J({
    id: 'lv_' + m.id, companyId: c.id, companyName: c.name, title: m.text?.trim() || 'Untitled',
    location: m.categories?.location || null, department: m.categories?.team || m.categories?.department || null,
    employmentType: m.categories?.commitment || null, workType: workType(m.workplaceType || m.categories?.location),
    url: m.hostedUrl, postedAt: m.createdAt ? new Date(m.createdAt).toISOString() : null,
  }));
}
async function ashby(c) {
  const d = await getJson(`https://api.ashbyhq.com/posting-api/job-board/${c.slug}`);
  return (d.jobs || []).map((m) => J({
    id: 'as_' + m.id, companyId: c.id, companyName: c.name, title: m.title?.trim() || 'Untitled',
    location: m.location || null, department: m.department || m.team || null,
    employmentType: m.employmentType || null, workType: m.isRemote ? 'remote' : workType(m.location),
    url: m.jobUrl || m.applyUrl, postedAt: m.publishedAt || m.publishedDate || null,
  }));
}
async function smartrecruiters(c) {
  const d = await getJson(`https://api.smartrecruiters.com/v1/companies/${c.slug}/postings?limit=100`);
  return (d.content || []).map((m) => {
    const loc = [m.location?.city, m.location?.country].filter(Boolean).join(', ');
    return J({
      id: 'sr_' + m.id, companyId: c.id, companyName: c.name, title: m.name?.trim() || 'Untitled',
      location: loc || null, department: m.department?.label || null,
      employmentType: m.typeOfEmployment?.label || null, workType: m.location?.remote ? 'remote' : workType(loc),
      url: `https://jobs.smartrecruiters.com/${c.slug}/${m.id}`, postedAt: m.releasedDate,
    });
  });
}
async function workable(c) {
  const d = await getJson(`https://apply.workable.com/api/v1/widget/accounts/${c.slug}?details=true`);
  return (d.jobs || []).map((m) => {
    const loc = [m.city, m.country].filter(Boolean).join(', ');
    const remote = m.telecommuting === true || m.remote === true;
    return J({
      id: 'wk_' + (m.shortcode || m.id), companyId: c.id, companyName: c.name, title: m.title?.trim() || 'Untitled',
      location: loc || null, department: m.department || null, employmentType: m.employment_type || null,
      workType: remote ? 'remote' : workType(loc), url: m.url || m.application_url, postedAt: m.published_on || m.created_at,
    });
  });
}
async function recruitee(c) {
  const d = await getJson(`https://${c.slug}.recruitee.com/api/offers/`);
  return (d.offers || []).map((m) => J({
    id: 'rc_' + m.id, companyId: c.id, companyName: c.name, title: m.title?.trim() || 'Untitled',
    location: m.location || m.city || null, department: m.department || null,
    workType: m.remote ? 'remote' : workType(m.location), url: m.careers_url || m.careers_apply_url, postedAt: m.published_at,
  }));
}
async function amazon(c) {
  const cfg = c.config || {};
  const params = new URLSearchParams();
  params.set('loc_query', cfg.loc_query || 'India');
  params.set('country', cfg.country || 'IND');
  params.set('result_limit', '100');
  params.set('sort', 'recent');
  if (cfg.query) params.set('base_query', cfg.query);
  let url = `https://www.amazon.jobs/en/search.json?${params.toString()}`;
  if (cfg.category) url += `&category[]=${encodeURIComponent(cfg.category)}`;
  const d = await getJson(url);
  return (d.jobs || []).map((m) => J({
    id: 'az_' + (m.id_icims || m.id), companyId: c.id, companyName: c.name, title: m.title?.trim() || 'Untitled',
    location: m.normalized_location || [m.city, m.state].filter(Boolean).join(', '),
    department: m.job_category || m.business_category || null, employmentType: m.job_schedule_type || null,
    workType: workType(m.normalized_location), url: m.job_path ? `https://www.amazon.jobs${m.job_path}` : null,
    postedAt: m.updated_time || null,
  }));
}
async function workday(c) {
  const cfg = c.config || {};
  if (!cfg.tenant || !cfg.dc || !cfg.site) throw new Error('Workday needs tenant, dc and site.');
  const base = `https://${cfg.tenant}.${cfg.dc}.myworkdayjobs.com`;
  const apiUrl = `${base}/wday/cxs/${cfg.tenant}/${cfg.site}/jobs`;
  const out = [];
  for (let offset = 0; offset < 100; offset += 20) {
    const d = await postJson(apiUrl, { appliedFacets: {}, limit: 20, offset, searchText: cfg.query || '' });
    const posts = d.jobPostings || [];
    if (!posts.length) break;
    for (const m of posts) {
      out.push(J({
        id: 'wd_' + (m.bulletFields?.[0] || m.externalPath), companyId: c.id, companyName: c.name,
        title: m.title?.trim() || 'Untitled', location: m.locationsText || null,
        workType: workType(m.locationsText), url: m.externalPath ? base + m.externalPath : null, postedAt: null,
      }));
    }
    if (posts.length < 20) break;
  }
  return out;
}

// ── paste-a-URL auto-detect (mirrors detectFromUrl) ──
export function detectFromUrl(raw) {
  const s = (raw || '').trim();
  if (!s) return null;
  let u;
  try { u = new URL(s.startsWith('http') ? s : 'https://' + s); } catch { return null; }
  const host = u.hostname.toLowerCase();
  const segs = u.pathname.split('/').filter(Boolean);

  if (host.includes('greenhouse.io') && segs[0]) return { provider: 'greenhouse', slug: segs[0] };
  if (host.includes('lever.co') && segs[0]) return { provider: 'lever', slug: segs[0] };
  if (host.includes('ashbyhq.com') && segs[0]) return { provider: 'ashby', slug: segs[0] };
  if (host.includes('smartrecruiters.com') && segs[0]) return { provider: 'smartrecruiters', slug: segs[0] };
  if (host.endsWith('workable.com')) {
    const sub = host.split('.')[0];
    if (sub !== 'apply' && sub !== 'www') return { provider: 'workable', slug: sub };
    if (segs[0]) return { provider: 'workable', slug: segs[0] };
  }
  if (host.endsWith('recruitee.com')) return { provider: 'recruitee', slug: host.split('.')[0] };
  if (host.includes('amazon.jobs')) {
    const q = u.searchParams;
    return { provider: 'amazon', config: {
      loc_query: q.get('loc_query') || 'India', country: q.get('country') || 'IND',
      ...(q.get('base_query') ? { query: q.get('base_query') } : {}),
    }};
  }
  if (host.includes('myworkdayjobs.com')) {
    const parts = host.split('.');
    if (parts.length >= 2) {
      let site = null;
      for (const seg of segs) {
        if (seg.length === 5 && seg.includes('-')) continue;
        if (['job', 'jobs'].includes(seg.toLowerCase())) continue;
        site = seg; break;
      }
      if (site) return { provider: 'workday', config: { tenant: parts[0], dc: parts[1], site } };
    }
  }
  return null;
}
