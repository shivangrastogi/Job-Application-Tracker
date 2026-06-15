import { useData } from '../data/store.jsx';
import { STATUS_KEYS, PIPELINE_STAGES, statusColor, statusLabel, JobSource } from '../lib/enums';
import { resumeStats, coverLetterStats, MIN_RESUME_SAMPLE } from '../lib/resumeAnalytics';

export default function Analytics() {
  const { applications: apps, documents } = useData();
  const total = apps.length;
  const resumes = resumeStats(apps, documents || []);
  const coverLetters = coverLetterStats(apps);

  const countBy = (keyFn, keys) => {
    const m = Object.fromEntries(keys.map((k) => [k, 0]));
    for (const a of apps) { const k = keyFn(a); if (k in m) m[k]++; }
    return m;
  };

  const byStatus = countBy((a) => a.status, STATUS_KEYS);
  const bySource = countBy((a) => a.source, Object.keys(JobSource));
  const maxStage = Math.max(1, ...PIPELINE_STAGES.map((s) => byStatus[s]));

  const responded = apps.filter((a) => !['wishlist', 'applied'].includes(a.status)).length;
  const responseRate = total ? Math.round((responded / total) * 100) : 0;
  const interviewing = apps.filter((a) => ['phoneScreen', 'technicalRound', 'onsiteInterview'].includes(a.status)).length;
  const offers = apps.filter((a) => ['offerReceived', 'accepted'].includes(a.status)).length;
  const offerRate = total ? Math.round((offers / total) * 100) : 0;

  if (!total) return <div className="page"><div className="page-head"><h1>Analytics</h1></div><div className="empty"><p>Add applications to see your funnel and conversion stats.</p></div></div>;

  const sourceMax = Math.max(1, ...Object.values(bySource));

  return (
    <div className="page">
      <div className="page-head"><div><h1>Analytics</h1><p className="muted">How your hunt is converting.</p></div></div>

      <div className="stat-grid">
        <KPI label="Total applications" value={total} />
        <KPI label="Response rate" value={`${responseRate}%`} />
        <KPI label="Interviewing" value={interviewing} />
        <KPI label="Offer rate" value={`${offerRate}%`} />
      </div>

      <div className="cols-2">
        <section className="card">
          <h2 className="card-title">Funnel</h2>
          <div className="pipe">
            {PIPELINE_STAGES.map((s) => (
              <div className="pipe-row" key={s}>
                <span className="dot" style={{ background: statusColor(s) }} />
                <span className="pipe-name">{statusLabel(s)}</span>
                <span className="pipe-bar"><i style={{ width: `${(byStatus[s] / maxStage) * 100}%`, background: statusColor(s) }} /></span>
                <b>{byStatus[s]}</b>
              </div>
            ))}
          </div>
        </section>

        <section className="card">
          <h2 className="card-title">By source</h2>
          <div className="pipe">
            {Object.entries(bySource).filter(([, v]) => v > 0).map(([k, v]) => (
              <div className="pipe-row" key={k}>
                <span className="pipe-name wide">{JobSource[k]}</span>
                <span className="pipe-bar"><i style={{ width: `${(v / sourceMax) * 100}%` }} /></span>
                <b>{v}</b>
              </div>
            ))}
          </div>
        </section>
      </div>

      <section className="card">
        <h2 className="card-title">Resume performance</h2>
        {resumes.length === 0 ? (
          <p className="muted">Attach a resume to your applications (on the app form) to compare how each version converts.</p>
        ) : (
          <div className="resume-perf">
            <div className="rp-row rp-head">
              <span className="rp-name">Resume</span>
              <span>Sent</span>
              <span>Response</span>
              <span>Interview</span>
              <span>Offer</span>
            </div>
            {resumes.map((r) => (
              <div className={'rp-row' + (r.lowData ? ' rp-low' : '')} key={r.id}>
                <span className="rp-name">
                  {r.name}
                  {r.lowData && <span className="rp-tag" title={`Fewer than ${MIN_RESUME_SAMPLE} applications — not enough data to compare yet`}>low data</span>}
                </span>
                <b>{r.sent}</b>
                <RateCell value={r.responseRate} count={r.responded} />
                <RateCell value={r.interviewRate} count={r.interviewed} />
                <RateCell value={r.offerRate} count={r.offered} />
              </div>
            ))}
            <p className="muted small" style={{ marginTop: 10 }}>
              Rates are share of <b>sent</b> applications (excludes wishlist). Resumes under {MIN_RESUME_SAMPLE} applications are marked <b>low data</b> — give them more applications before trusting the numbers.
            </p>
          </div>
        )}
      </section>

      {coverLetters.length > 0 && (
        <section className="card">
          <h2 className="card-title">Cover letter impact</h2>
          <div className="resume-perf">
            <div className="rp-row rp-head">
              <span className="rp-name">Applications</span>
              <span>Sent</span>
              <span>Response</span>
              <span>Interview</span>
              <span>Offer</span>
            </div>
            {coverLetters.map((r) => (
              <div className="rp-row" key={r.id}>
                <span className="rp-name">{r.name}</span>
                <b>{r.sent}</b>
                <RateCell value={r.responseRate} count={r.responded} />
                <RateCell value={r.interviewRate} count={r.interviewed} />
                <RateCell value={r.offerRate} count={r.offered} />
              </div>
            ))}
            <p className="muted small" style={{ marginTop: 10 }}>
              Tick “Cover letter sent” on applications to see whether it lifts your interview rate.
            </p>
          </div>
        </section>
      )}

      <section className="card">
        <h2 className="card-title">Status breakdown</h2>
        <div className="status-breakdown">
          {STATUS_KEYS.filter((s) => byStatus[s] > 0).map((s) => (
            <div className="sb" key={s}>
              <span className="sb-num" style={{ color: statusColor(s) }}>{byStatus[s]}</span>
              <span className="muted small">{statusLabel(s)}</span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}

function KPI({ label, value }) {
  return <div className="stat"><b>{value}</b><small>{label}</small></div>;
}

function RateCell({ value, count }) {
  // Green-ish as the rate climbs, so strong resumes pop out of the table.
  const color = value >= 50 ? '#22C55E' : value >= 25 ? '#F59E0B' : '#9E9E9E';
  return <span title={`${count} application(s)`}><b style={{ color }}>{value}%</b></span>;
}
