import { useEffect, useMemo, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useData } from '../data/store.jsx';
import { fetchJobs } from '../lib/jobBoard';
import { isFetchable, CareerWorkType } from '../lib/enums';
import { fmtDate } from '../lib/format';

export default function CompanyJobs() {
  const { id } = useParams();
  const data = useData();
  const nav = useNavigate();
  const company = data.companies.find((c) => c.id === id);

  const [jobs, setJobs] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [loc, setLoc] = useState('');
  const [dept, setDept] = useState('');
  const [wt, setWt] = useState('');
  const [added, setAdded] = useState({});

  const load = async () => {
    if (!company || !isFetchable(company.provider)) return;
    setLoading(true); setError('');
    try {
      const res = await fetchJobs(company);
      res.sort((a, b) => (b.postedAt || '').localeCompare(a.postedAt || ''));
      setJobs(res);
      data.recordFetch(company, res.length);
    } catch (e) { setError(e.message || 'Could not load jobs.'); setJobs([]); }
    finally { setLoading(false); }
  };

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [id]);

  const facet = (sel) => [...new Set((jobs || []).map(sel).filter(Boolean))].sort();
  const locations = useMemo(() => facet((j) => j.location), [jobs]);
  const depts = useMemo(() => facet((j) => j.department), [jobs]);
  const workTypes = useMemo(() => [...new Set((jobs || []).map((j) => j.workType).filter((w) => w && w !== 'unknown'))], [jobs]);

  const filtered = (jobs || []).filter((j) =>
    (!search || j.title.toLowerCase().includes(search.toLowerCase())) &&
    (!loc || j.location === loc) && (!dept || j.department === dept) && (!wt || j.workType === wt));

  if (!company) return <div className="page"><div className="empty"><p>Company not found.</p></div></div>;

  const openUrl = (u) => u && window.open(u, '_blank', 'noopener');
  const track = async (job) => {
    await data.addApplication({
      company: job.companyName, role: job.title, jobUrl: job.url, location: job.location,
      workType: job.workType === 'remote' ? 'remote' : job.workType === 'hybrid' ? 'hybrid' : 'onsite',
      source: 'company', sourceName: job.companyName,
    });
    setAdded((a) => ({ ...a, [job.id]: true }));
  };

  return (
    <div className="page">
      <div className="page-head">
        <div>
          <button className="link" onClick={() => nav('/companies')}>‹ Companies</button>
          <h1>{company.name}</h1>
        </div>
        <div className="head-actions">
          {company.careerUrl && <button className="btn btn-line btn-sm" onClick={() => openUrl(company.careerUrl)}>Careers page ↗</button>}
          {isFetchable(company.provider) && <button className="btn btn-line btn-sm" onClick={load} disabled={loading}>Refresh</button>}
        </div>
      </div>

      {!isFetchable(company.provider) ? (
        <div className="empty">
          <p>This company isn't on a supported job board, so listings can't be pulled automatically.</p>
          {company.careerUrl && <button className="btn btn-accent" onClick={() => openUrl(company.careerUrl)}>Open careers page ↗</button>}
        </div>
      ) : loading ? (
        <div className="empty"><div className="spinner" /></div>
      ) : error ? (
        <div className="empty"><p>{error}</p>
          <div className="head-actions"><button className="btn btn-accent" onClick={load}>Retry</button>
            {company.careerUrl && <button className="btn btn-line" onClick={() => openUrl(company.careerUrl)}>Open careers page</button>}</div>
          <p className="hint" style={{ marginTop: 12 }}>Tip: make sure the proxy is running (<code>npm run proxy</code>).</p>
        </div>
      ) : (
        <>
          <div className="filters">
            <input className="search" placeholder="Search roles" value={search} onChange={(e) => setSearch(e.target.value)} />
            {depts.length > 0 && <select value={dept} onChange={(e) => setDept(e.target.value)}><option value="">All departments</option>{depts.map((d) => <option key={d} value={d}>{d}</option>)}</select>}
            {locations.length > 0 && <select value={loc} onChange={(e) => setLoc(e.target.value)}><option value="">All locations</option>{locations.map((l) => <option key={l} value={l}>{l}</option>)}</select>}
            {workTypes.length > 0 && <select value={wt} onChange={(e) => setWt(e.target.value)}><option value="">Any work type</option>{workTypes.map((w) => <option key={w} value={w}>{CareerWorkType[w]}</option>)}</select>}
          </div>
          <p className="muted small" style={{ margin: '4px 2px 12px' }}>{filtered.length} result{filtered.length === 1 ? '' : 's'}</p>

          <div className="list">
            {filtered.map((j) => (
              <div className="job-card" key={j.id}>
                <div className="job-main">
                  <b>{j.title}</b>
                  <div className="job-meta">
                    {j.location && <span>📍 {j.location}</span>}
                    {j.department && <span>🗂 {j.department}</span>}
                    {j.workType !== 'unknown' && <span>💻 {CareerWorkType[j.workType]}</span>}
                    {j.postedAt && <span>🕒 {fmtDate(j.postedAt)}</span>}
                  </div>
                </div>
                <div className="job-actions">
                  {j.url && <button className="btn btn-line btn-sm" onClick={() => openUrl(j.url)}>View</button>}
                  <button className="btn btn-accent btn-sm" disabled={added[j.id]} onClick={() => track(j)}>{added[j.id] ? 'Tracked ✓' : 'Track'}</button>
                </div>
              </div>
            ))}
            {filtered.length === 0 && <div className="empty"><p>No jobs match your filters.</p></div>}
          </div>
        </>
      )}
    </div>
  );
}
