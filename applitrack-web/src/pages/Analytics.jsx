import { useData } from '../data/store.jsx';
import { STATUS_KEYS, PIPELINE_STAGES, statusColor, statusLabel, JobSource } from '../lib/enums';

export default function Analytics() {
  const { applications: apps } = useData();
  const total = apps.length;

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
