import { useState } from 'react';
import { useAuth } from '../auth/AuthContext.jsx';
import { useData } from '../data/store.jsx';
import { useCrypto } from '../crypto/CryptoContext.jsx';
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

      <EncryptionSection />

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

function EncryptionSection() {
  const { status, busy, setup, lock, disable } = useCrypto();
  const [open, setOpen] = useState(false);
  const [pw, setPw] = useState('');
  const [pw2, setPw2] = useState('');
  const [backedUp, setBackedUp] = useState(false);
  const [progress, setProgress] = useState('');
  const [error, setError] = useState('');

  const canEnable = pw.length >= 8 && pw === pw2 && backedUp && !busy;

  const enable = async () => {
    setError('');
    try {
      await setup(pw, (name) => setProgress(`Encrypting ${name}…`));
      setOpen(false); setPw(''); setPw2(''); setBackedUp(false); setProgress('');
    } catch (e) {
      setError(e.message || 'Encryption failed.');
    }
  };

  const turnOff = async () => {
    if (!confirm('Turn off encryption and store your data as plaintext again?')) return;
    setError('');
    try { await disable(); } catch (e) { setError(e.message || 'Could not disable.'); }
  };

  return (
    <section className="card">
      <h2 className="card-title">🔒 Encryption</h2>

      {status === 'unlocked' && (
        <>
          <p className="muted">End-to-end encryption is <b style={{ color: '#22c55e' }}>ON</b>. Your data is encrypted on this device with your passphrase — the server only stores ciphertext.</p>
          <div className="head-actions" style={{ marginTop: 14 }}>
            <button className="btn btn-line btn-sm" onClick={lock}>Lock this device</button>
            <button className="btn btn-danger btn-sm" disabled={busy} onClick={turnOff}>Turn off encryption</button>
          </div>
          {error && <p className="unlock-error">{error}</p>}
        </>
      )}

      {status === 'disabled' && !open && (
        <>
          <p className="muted">Encrypt all your applications, resumes and notes with a passphrase only you know. The server (and anyone with database access) will only ever see ciphertext.</p>
          <button className="btn btn-accent" style={{ marginTop: 14 }} onClick={() => setOpen(true)}>Enable end-to-end encryption</button>
        </>
      )}

      {status === 'disabled' && open && (
        <div className="enc-setup">
          <p className="enc-warn">⚠ There is <b>no recovery</b>. If you forget this passphrase, your data is permanently unreadable. It must also be entered on each device. <b>Don't enable this until the mobile app is updated too.</b></p>
          <label className="field full"><span>Passphrase (min 8 chars)</span><input type="password" value={pw} onChange={(e) => setPw(e.target.value)} /></label>
          <label className="field full"><span>Confirm passphrase</span><input type="password" value={pw2} onChange={(e) => setPw2(e.target.value)} /></label>
          {pw && pw2 && pw !== pw2 && <p className="unlock-error">Passphrases don't match.</p>}
          <label className="field field-check"><input type="checkbox" checked={backedUp} onChange={(e) => setBackedUp(e.target.checked)} /><span>I've exported a CSV backup (above) and saved my passphrase somewhere safe.</span></label>
          {progress && <p className="muted small">{progress}</p>}
          {error && <p className="unlock-error">{error}</p>}
          <div className="head-actions">
            <button className="btn btn-line btn-sm" disabled={busy} onClick={() => setOpen(false)}>Cancel</button>
            <button className="btn btn-accent" disabled={!canEnable} onClick={enable}>{busy ? 'Encrypting…' : 'Encrypt my data'}</button>
          </div>
        </div>
      )}
    </section>
  );
}
