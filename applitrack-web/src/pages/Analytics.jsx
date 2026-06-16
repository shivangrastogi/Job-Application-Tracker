import { useData } from '../data/store.jsx';
import { STATUS_KEYS, PIPELINE_STAGES, statusColor, statusLabel, JobSource } from '../lib/enums';
import { resumeStats, coverLetterStats, sourceStats, resumeRecommendation, MIN_RESUME_SAMPLE } from '../lib/resumeAnalytics';

export default function Analytics() {
  const data = useData();
  const { applications: apps, documents } = data;
  const total = apps.length;
  const resumes = resumeStats(apps, documents || []);
  const coverLetters = coverLetterStats(apps);
  const channels = sourceStats(apps, JobSource);
  const recommendation = resumeRecommendation(resumes);
  const salary = salaryInsights(apps);
  const defaultId = data.defaultResumeId;
  const makeDefault = (id) => data.setDefaultResume(id);

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
        {recommendation && (
          <div className="reco">
            <span className="reco-ic">💡</span>
            <div className="reco-main">
              <b>{recommendation.best.name}</b> is landing interviews at {recommendation.best.interviewRate}%
              {recommendation.factor ? `, ${recommendation.factor} better than ` : ', vs '}
              <b>{recommendation.worst.name}</b> ({recommendation.worst.interviewRate}%). Lead with it.
            </div>
            {defaultId === recommendation.best.id
              ? <span className="badge" style={{ color: '#10B981', background: '#10B98122' }}>Default ✓</span>
              : <button className="btn btn-line btn-sm" onClick={() => makeDefault(recommendation.best.id)}>Set as default</button>}
          </div>
        )}
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

      {channels.length > 0 && (
        <section className="card">
          <h2 className="card-title">Channel performance</h2>
          <div className="resume-perf">
            <div className="rp-row rp-head">
              <span className="rp-name">Source</span>
              <span>Sent</span>
              <span>Response</span>
              <span>Interview</span>
              <span>Offer</span>
            </div>
            {channels.map((r) => (
              <div className={'rp-row' + (r.lowData ? ' rp-low' : '')} key={r.id}>
                <span className="rp-name">
                  {r.name}
                  {r.lowData && <span className="rp-tag" title={`Fewer than ${MIN_RESUME_SAMPLE} applications`}>low data</span>}
                </span>
                <b>{r.sent}</b>
                <RateCell value={r.responseRate} count={r.responded} />
                <RateCell value={r.interviewRate} count={r.interviewed} />
                <RateCell value={r.offerRate} count={r.offered} />
              </div>
            ))}
            <p className="muted small" style={{ marginTop: 10 }}>
              Where your applications convert best. Pair this with resume performance to see which resume works on each channel.
            </p>
          </div>
        </section>
      )}

      {salary && (
        <section className="card">
          <h2 className="card-title">Salary insights</h2>
          <div className="stat-grid">
            <KPI label="Median" value={fmtMoney(salary.median, salary.currency)} />
            <KPI label="Average" value={fmtMoney(salary.average, salary.currency)} />
            <KPI label="Lowest" value={fmtMoney(salary.lo, salary.currency)} />
            <KPI label="Highest" value={fmtMoney(salary.hi, salary.currency)} />
            {salary.offeredAvg != null && <KPI label="Avg of offers" value={fmtMoney(salary.offeredAvg, salary.currency)} />}
          </div>
          <p className="muted small">
            From {salary.count} application{salary.count === 1 ? '' : 's'} with salary data
            {salary.offeredCount ? ` · ${salary.offeredCount} offer${salary.offeredCount === 1 ? '' : 's'}` : ''}.
          </p>
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

function fmtMoney(v, cur) {
  const n = Math.round(v * 10) / 10;
  return cur === 'INR' ? `₹${n} LPA` : `${n} ${cur}`;
}

// Salary stats across applications that have any salary data. A job's value is
// the midpoint of its min/max (or whichever single bound is set).
function salaryInsights(apps) {
  const rows = apps.filter((a) => a.salaryMin != null || a.salaryMax != null);
  if (!rows.length) return null;
  const val = (a) => (a.salaryMin != null && a.salaryMax != null
    ? (a.salaryMin + a.salaryMax) / 2
    : (a.salaryMin ?? a.salaryMax));
  const vals = rows.map(val).sort((x, y) => x - y);
  const mid = Math.floor(vals.length / 2);
  const median = vals.length % 2 ? vals[mid] : (vals[mid - 1] + vals[mid]) / 2;
  const average = vals.reduce((s, v) => s + v, 0) / vals.length;
  const lo = Math.min(...rows.map((a) => a.salaryMin ?? a.salaryMax));
  const hi = Math.max(...rows.map((a) => a.salaryMax ?? a.salaryMin));
  const curCount = {};
  for (const a of rows) { const c = a.salaryCurrency || 'INR'; curCount[c] = (curCount[c] || 0) + 1; }
  const currency = Object.entries(curCount).sort((a, b) => b[1] - a[1])[0][0];
  const offers = rows.filter((a) => a.status === 'offerReceived' || a.status === 'accepted');
  const offeredAvg = offers.length ? offers.map(val).reduce((s, v) => s + v, 0) / offers.length : null;
  return { count: rows.length, currency, median, average, lo, hi, offeredAvg, offeredCount: offers.length };
}

function RateCell({ value, count }) {
  // Green-ish as the rate climbs, so strong resumes pop out of the table.
  const color = value >= 50 ? '#22C55E' : value >= 25 ? '#F59E0B' : '#9E9E9E';
  return <span title={`${count} application(s)`}><b style={{ color }}>{value}%</b></span>;
}
