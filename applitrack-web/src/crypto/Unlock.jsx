import { useState } from 'react';
import { useCrypto } from './CryptoContext.jsx';
import { useAuth } from '../auth/AuthContext.jsx';

// Shown when the account has encryption enabled but this device is locked.
export default function Unlock() {
  const { unlock } = useCrypto();
  const { signOut } = useAuth();
  const [pw, setPw] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const submit = async (e) => {
    e.preventDefault();
    if (!pw) return;
    setBusy(true);
    setError('');
    try {
      await unlock(pw);
    } catch (err) {
      setError(err.message || 'Could not unlock.');
      setBusy(false);
    }
  };

  return (
    <div className="unlock">
      <form className="unlock-card" onSubmit={submit}>
        <div className="unlock-mark">🔒</div>
        <h1>Unlock your data</h1>
        <p className="muted">Your applications are end-to-end encrypted. Enter your passphrase to decrypt them on this device.</p>
        <input
          type="password"
          autoFocus
          placeholder="Encryption passphrase"
          value={pw}
          onChange={(e) => setPw(e.target.value)}
        />
        {error && <p className="unlock-error">{error}</p>}
        <button className="btn btn-accent" disabled={busy || !pw}>{busy ? 'Unlocking…' : 'Unlock'}</button>
        <button type="button" className="btn btn-ghost btn-sm" onClick={signOut}>Sign out</button>
        <p className="muted small">There is no recovery — if you've forgotten this passphrase, your encrypted data can't be read.</p>
      </form>
    </div>
  );
}
