// Minimal CORS proxy for job-board APIs.
//
// Career-page APIs (Greenhouse, Lever, Amazon, Workday, …) don't send CORS
// headers, so the browser can't call them directly. This forwards the request
// server-side and adds permissive CORS. Run with `npm run proxy`.
//
// Usage from the client:  /proxy?url=<encoded target url>   (GET or POST)
// In production deploy this as a serverless function at the same /proxy path.

import http from 'node:http';

const PORT = process.env.PROXY_PORT || 8787;
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

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const u = new URL(req.url, `http://localhost:${PORT}`);
  if (u.pathname !== '/proxy') {
    res.writeHead(404);
    res.end('Not found');
    return;
  }

  const target = u.searchParams.get('url');
  if (!target) {
    res.writeHead(400);
    res.end('Missing url');
    return;
  }

  let targetUrl;
  try {
    targetUrl = new URL(target);
  } catch {
    res.writeHead(400);
    res.end('Bad url');
    return;
  }
  if (!isAllowed(targetUrl.host)) {
    res.writeHead(403);
    res.end('Host not allowed');
    return;
  }

  // Collect body for POST (Workday)
  const chunks = [];
  for await (const c of req) chunks.push(c);
  const body = chunks.length ? Buffer.concat(chunks) : undefined;

  try {
    const upstream = await fetch(target, {
      method: req.method,
      headers: {
        Accept: 'application/json',
        'Content-Type': req.headers['content-type'] || 'application/json',
        'User-Agent': 'Mozilla/5.0 AppliTrackWeb',
      },
      body: req.method === 'POST' ? body : undefined,
    });
    const text = await upstream.text();
    res.writeHead(upstream.status, {
      'Content-Type': upstream.headers.get('content-type') || 'application/json',
    });
    res.end(text);
  } catch (e) {
    res.writeHead(502);
    res.end(JSON.stringify({ error: String(e) }));
  }
});

server.listen(PORT, () => {
  console.log(`Job-board proxy running on http://localhost:${PORT}/proxy`);
});
