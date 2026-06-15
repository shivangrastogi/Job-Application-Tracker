import { useState } from 'react';
import { useAuth } from './AuthContext.jsx';

export default function Login() {
  const { signInWithGoogle, signInEmail, signUpEmail } = useAuth();
  const [mode, setMode] = useState('signin');
  const [email, setEmail] = useState('');
  const [pw, setPw] = useState('');
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  const run = async (fn) => {
    setErr(''); setBusy(true);
    try { await fn(); }
    catch (e) { setErr(prettyError(e)); }
    finally { setBusy(false); }
  };

  return (
    <div className="auth-wrap">
      <div className="auth-grid" aria-hidden="true" />
      <div className="auth-card">
        <div className="auth-brand">
          <span className="brand-mark lg">
            <svg viewBox="0 0 24 24" width="26" height="26" fill="none"><path d="M4 13l5 5L20 6" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>
          </span>
          <span>AppliTrack</span>
        </div>
        <h1>{mode === 'signin' ? 'Welcome back.' : 'Create your account.'}</h1>
        <p className="auth-sub">Your job hunt, synced across every device.</p>

        <button className="btn btn-google" disabled={busy} onClick={() => run(signInWithGoogle)}>
          <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.4 29.3 35 24 35c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.5 5.1 29.5 3 24 3 12.4 3 3 12.4 3 24s9.4 21 21 21c10.5 0 20-7.6 20-21 0-1.2-.1-2.3-.4-3.5z"/><path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 16 19 13 24 13c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.5 7.1 29.5 5 24 5 16 5 9.1 9.5 6.3 14.7z"/><path fill="#4CAF50" d="M24 45c5.2 0 10-2 13.6-5.2l-6.3-5.3C29.2 36 26.7 37 24 37c-5.3 0-9.7-3.4-11.3-8.1l-6.6 5.1C9 40.5 15.9 45 24 45z"/><path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.1-4 5.5l6.3 5.3C41.4 36 44 30.7 44 24c0-1.2-.1-2.3-.4-3.5z"/></svg>
          Continue with Google
        </button>

        <div className="auth-or"><span>or</span></div>

        <form onSubmit={(e) => { e.preventDefault(); run(() => (mode === 'signin' ? signInEmail(email, pw) : signUpEmail(email, pw))); }}>
          <label className="field">
            <span>Email</span>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
          </label>
          <label className="field">
            <span>Password</span>
            <input type="password" value={pw} onChange={(e) => setPw(e.target.value)} required minLength={6} autoComplete={mode === 'signin' ? 'current-password' : 'new-password'} />
          </label>
          {err && <p className="auth-err">{err}</p>}
          <button className="btn btn-accent full" disabled={busy} type="submit">
            {busy ? 'Please wait…' : mode === 'signin' ? 'Sign in' : 'Create account'}
          </button>
        </form>

        <p className="auth-switch">
          {mode === 'signin' ? "No account yet?" : 'Already have an account?'}{' '}
          <button className="link" onClick={() => { setErr(''); setMode(mode === 'signin' ? 'signup' : 'signin'); }}>
            {mode === 'signin' ? 'Sign up' : 'Sign in'}
          </button>
        </p>
      </div>
    </div>
  );
}

function prettyError(e) {
  const c = e?.code || '';
  if (c.includes('invalid-credential') || c.includes('wrong-password') || c.includes('user-not-found'))
    return 'Wrong email or password.';
  if (c.includes('email-already-in-use')) return 'That email already has an account.';
  if (c.includes('weak-password')) return 'Password should be at least 6 characters.';
  if (c.includes('popup-closed')) return 'Sign-in was cancelled.';
  if (c.includes('unauthorized-domain')) return 'This domain isn’t authorized in Firebase Auth settings.';
  return e?.message || 'Something went wrong.';
}
