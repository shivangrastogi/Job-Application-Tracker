// Vercel Serverless Function — the production version of server/proxy.mjs.
// Deployed automatically with the app at /api/proxy (vercel.json rewrites
// /proxy → /api/proxy so the client code is identical in dev and prod).
//
// Career-page APIs don't send CORS headers, so the browser can't call them
// directly. This forwards the request server-side and adds permissive CORS.

const ALLOW_HOSTS = [
  'boards-api.greenhouse.io',
  'api.lever.co',
  'api.ashbyhq.com',
  'api.smartrecruiters.com',
  'apply.workable.com',
  'www.amazon.jobs',
  'recruitee.com',
  'myworkdayjobs.com',
];

function isAllowed(host) {
  return ALLOW_HOSTS.some((h) => host === h || host.endsWith('.' + h) || host.endsWith(h));
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const target = req.query.url;
  if (!target) return res.status(400).send('Missing url');

  let u;
  try { u = new URL(target); } catch { return res.status(400).send('Bad url'); }
  if (!isAllowed(u.host)) return res.status(403).send('Host not allowed');

  try {
    const upstream = await fetch(target, {
      method: req.method,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 AppliTrackWeb',
      },
      body: req.method === 'POST' ? JSON.stringify(req.body ?? {}) : undefined,
    });
    const text = await upstream.text();
    res.status(upstream.status);
    res.setHeader('Content-Type', upstream.headers.get('content-type') || 'application/json');
    return res.send(text);
  } catch (e) {
    return res.status(502).json({ error: String(e) });
  }
}
