import { useAuth } from '../auth/AuthContext.jsx';
import { useData } from '../data/store.jsx';
import { applicationsToCsv, downloadCsv } from '../lib/exportCsv';

export default function Profile() {
  const { user, signOut } = useAuth();
  const { applications, companies, goals, referrals, interviews, documents } = useData();

  const exportCsv = () => {
    const csv = applicationsToCsv(applications, documents || []);
    const date = new Date().toISOString().slice(0, 10);
    downloadCsv(`applitrack-applications-${date}.csv`, csv);
  };

  return (
    <div className="page">
      <div className="page-head"><div><h1>Profile</h1><p className="muted">Your account & data</p></div></div>

      <section className="card">
        <div className="profile-head">
          <span className="avatar lg">{(user?.displayName || user?.email || '?')[0].toUpperCase()}</span>
          <div>
            <b>{user?.displayName || 'AppliTrack user'}</b>
            <span className="muted">{user?.email}</span>
          </div>
        </div>
        <div className="stat-grid" style={{ marginTop: 20 }}>
          <Mini n={applications.length} label="Applications" />
          <Mini n={companies.length} label="Companies" />
          <Mini n={interviews.length} label="Interviews" />
          <Mini n={referrals.length} label="Referrals" />
          <Mini n={goals.length} label="Goals" />
        </div>
      </section>

      <section className="card">
        <h2 className="card-title">Export</h2>
        <p className="muted">Download all your applications as a CSV (opens in Excel / Google Sheets), including which resume and whether a cover letter was used.</p>
        <button className="btn btn-line" style={{ marginTop: 14 }} disabled={!applications.length} onClick={exportCsv}>
          Export applications ({applications.length}) → CSV
        </button>
      </section>

      <section className="card">
        <h2 className="card-title">Sync</h2>
        <p className="muted">Your data lives in your AppliTrack cloud account and syncs automatically with the mobile app signed in to the same account.</p>
        <button className="btn btn-line" style={{ marginTop: 14 }} onClick={signOut}>Sign out</button>
      </section>
    </div>
  );
}

function Mini({ n, label }) {
  return <div className="stat"><b>{n}</b><small>{label}</small></div>;
}
