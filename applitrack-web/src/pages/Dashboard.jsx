import { Link } from 'react-router-dom';
import { useData } from '../data/store.jsx';
import { isActiveStatus, statusColor, statusLabel, PIPELINE_STAGES, GoalMetric, GoalPeriod } from '../lib/enums';
import { goalProgress } from '../lib/goals';
import { resumeStats, bestResume } from '../lib/resumeAnalytics';
import { isStale, daysSince, STALE_DAYS } from '../lib/staleness';

export default function Dashboard() {
  const { applications: apps, interviews, goals, documents } = useData();
  const topResume = bestResume(resumeStats(apps, documents || []));
  const staleApps = apps.filter(isStale).sort((a, b) => daysSince(b.updatedAt) - daysSince(a.updatedAt));

  const total = apps.length;
  const active = apps.filter((a) => isActiveStatus(a.status)).length;
  const offers = apps.filter((a) => a.status === 'offerReceived' || a.status === 'accepted').length;

  const weekAhead = Date.now() + 7 * 86400000;
  const ivThisWeek = interviews.filter((i) => {
    const t = i.scheduledAt ? new Date(i.scheduledAt).getTime() : 0;
    return t >= Date.now() && t <= weekAhead;
  }).length;

  const counts = {};
  for (const s of PIPELINE_STAGES) counts[s] = apps.filter((a) => a.status === s).length;
  const maxCount = Math.max(1, ...Object.values(counts));

  const activeGoals = goals.filter((g) => g.active).map((g) => ({ g, p: goalProgress(g, apps, interviews) }));
  const responded = apps.filter((a) => !['wishlist', 'applied'].includes(a.status)).length;
  const responseRate = total ? Math.round((responded / total) * 100) : 0;

  return (
    <div className="page">
      <div className="page-head">
        <div>
          <h1>Dashboard</h1>
          <p className="muted">Your hunt at a glance.</p>
        </div>
        <Link to="/applications" className="btn btn-accent">+ Add job</Link>
      </div>

      <div className="stat-grid">
        <Stat label="Total" value={total} color="#c8f751" icon="▦" />
        <Stat label="Active" value={active} color="#5b9dff" icon="◷" />
        <Stat label="Interviews / week" value={ivThisWeek} color="#a78bfa" icon="◆" />
        <Stat label="Offers" value={offers} color="#22c55e" icon="★" />
      </div>

      {staleApps.length > 0 && (
        <section className="card nudge">
          <div className="card-title-row">
            <h2 className="card-title">⏰ Needs follow-up</h2>
            <Link to="/applications" className="link">View all</Link>
          </div>
          <p className="muted" style={{ marginTop: -4 }}>
            {staleApps.length} active application{staleApps.length === 1 ? '' : 's'} with no movement in {STALE_DAYS}+ days.
          </p>
          <div className="nudge-list">
            {staleApps.slice(0, 4).map((a) => (
              <Link to="/applications" className="nudge-row" key={a.id}>
                <span className="nudge-main"><b>{a.role || a.company}</b><span className="muted">{a.company}</span></span>
                <span className="nudge-age">{daysSince(a.updatedAt)}d</span>
              </Link>
            ))}
          </div>
        </section>
      )}

      {topResume && (
        <Link to="/analytics" className="card top-resume">
          <div className="tr-icon">★</div>
          <div className="tr-main">
            <small className="muted">Top resume · {topResume.sent} sent</small>
            <b>{topResume.name}</b>
          </div>
          <div className="tr-rate">
            <b>{topResume.interviewRate}%</b>
            <small className="muted">interview rate</small>
          </div>
        </Link>
      )}

      <div className="cols-2">
        <section className="card">
          <h2 className="card-title">Your pipeline</h2>
          <div className="pipe">
            {PIPELINE_STAGES.map((s) => (
              <div className="pipe-row" key={s}>
                <span className="dot" style={{ background: statusColor(s) }} />
                <span className="pipe-name">{statusLabel(s)}</span>
                <span className="pipe-bar"><i style={{ width: `${(counts[s] / maxCount) * 100}%`, background: statusColor(s) }} /></span>
                <b>{counts[s]}</b>
              </div>
            ))}
          </div>
          <div className="resp">
            <div className="resp-head"><span>Response rate</span><b>{responseRate}%</b></div>
            <div className="bar"><i style={{ width: `${responseRate}%` }} /></div>
          </div>
        </section>

        <section className="card">
          <div className="card-title-row">
            <h2 className="card-title">Today's goals</h2>
            <Link to="/goals" className="link">Manage</Link>
          </div>
          {activeGoals.length === 0 ? (
            <div className="empty-sm">
              <p>No goals yet.</p>
              <Link to="/goals" className="btn btn-line btn-sm">Set a goal</Link>
            </div>
          ) : activeGoals.slice(0, 4).map(({ g, p }) => (
            <div className="goal-mini" key={g.id}>
              <div className="goal-mini-head">
                <span>{g.target} {GoalMetric[g.metric]?.short} {GoalPeriod[g.period]?.unit}</span>
                <b style={{ color: p.achieved ? '#22c55e' : 'var(--lime)' }}>{p.current}/{g.target}</b>
              </div>
              <div className="bar"><i style={{ width: `${p.fraction * 100}%`, background: p.achieved ? '#22c55e' : undefined }} /></div>
            </div>
          ))}
        </section>
      </div>

      <div className="quick-row">
        <Link to="/companies" className="quick"><b>Companies</b><span>Browse & sync MNC openings</span></Link>
        <Link to="/referrals" className="quick"><b>Referrals</b><span>Track forms & groups</span></Link>
        <Link to="/analytics" className="quick"><b>Analytics</b><span>Funnel & conversion</span></Link>
      </div>
    </div>
  );
}

function Stat({ label, value, color, icon }) {
  return (
    <div className="stat">
      <span className="stat-ic" style={{ background: color + '22', color }}>{icon}</span>
      <b>{value}</b>
      <small>{label}</small>
    </div>
  );
}
