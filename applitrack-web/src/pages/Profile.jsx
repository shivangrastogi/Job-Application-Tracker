import { useAuth } from '../auth/AuthContext.jsx';
import { useData } from '../data/store.jsx';

export default function Profile() {
  const { user, signOut } = useAuth();
  const { applications, companies, goals, referrals, interviews } = useData();

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
