import { NavLink, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { useAuth } from '../auth/AuthContext.jsx';

const NAV = [
  { to: '/', label: 'Dashboard', end: true, icon: 'M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z' },
  { to: '/applications', label: 'Applications', icon: 'M4 6h16M4 12h16M4 18h10' },
  { to: '/companies', label: 'Companies', icon: 'M3 21h18M5 21V7l8-4v18M19 21V11l-6-3' },
  { to: '/interviews', label: 'Interviews', icon: 'M7 4v3m10-3v3M4 9h16M5 5h14a1 1 0 011 1v13a1 1 0 01-1 1H5a1 1 0 01-1-1V6a1 1 0 011-1z' },
  { to: '/referrals', label: 'Referrals', icon: 'M16 11a4 4 0 10-8 0m-2 9a6 6 0 0112 0M12 7v0' },
  { to: '/resumes', label: 'Resumes', icon: 'M7 3h7l5 5v13a1 1 0 01-1 1H7a1 1 0 01-1-1V4a1 1 0 011-1zm6 0v6h6M9 13h6M9 17h6' },
  { to: '/goals', label: 'Goals', icon: 'M5 21V5a2 2 0 012-2h7l-1 4h5l-1 5H7' },
  { to: '/analytics', label: 'Analytics', icon: 'M4 20V10m6 10V4m6 16v-7' },
];

export default function Shell({ children }) {
  const { user, signOut } = useAuth();
  const [open, setOpen] = useState(false);
  const navigate = useNavigate();

  // Keyboard shortcuts: "/" focuses search; "g" then a key jumps to a page.
  useEffect(() => {
    let gPending = false;
    let timer;
    const GO = { d: '/', a: '/applications', c: '/companies', i: '/interviews', r: '/resumes', g: '/goals', n: '/analytics', f: '/referrals', p: '/profile' };
    const onKey = (e) => {
      const tag = (e.target.tagName || '').toLowerCase();
      if (tag === 'input' || tag === 'textarea' || tag === 'select' || e.target.isContentEditable) return;
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (e.key === '/') { e.preventDefault(); document.querySelector('.search')?.focus(); return; }
      if (e.key === 'g') { gPending = true; clearTimeout(timer); timer = setTimeout(() => { gPending = false; }, 1200); return; }
      if (gPending) {
        gPending = false;
        const to = GO[e.key];
        if (to) { e.preventDefault(); navigate(to); }
      }
    };
    window.addEventListener('keydown', onKey);
    return () => { window.removeEventListener('keydown', onKey); clearTimeout(timer); };
  }, [navigate]);

  return (
    <div className="layout">
      <aside className={'sidebar' + (open ? ' open' : '')}>
        <div className="side-brand">
          <span className="brand-mark">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none"><path d="M4 13l5 5L20 6" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>
          </span>
          AppliTrack
        </div>
        <nav className="side-nav" onClick={() => setOpen(false)}>
          {NAV.map((n) => (
            <NavLink key={n.to} to={n.to} end={n.end}
              className={({ isActive }) => 'side-link' + (isActive ? ' active' : '')}>
              <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d={n.icon} /></svg>
              <span>{n.label}</span>
            </NavLink>
          ))}
        </nav>
        <div className="side-foot">
          <NavLink to="/profile" className="side-user">
            <span className="avatar">{(user?.displayName || user?.email || '?')[0].toUpperCase()}</span>
            <span className="side-user-meta">
              <b>{user?.displayName || 'Account'}</b>
              <small>{user?.email}</small>
            </span>
          </NavLink>
          <button className="btn btn-ghost btn-sm" onClick={signOut}>Sign out</button>
        </div>
      </aside>

      <div className="main-area">
        <header className="topbar">
          <button className="hamburger" onClick={() => setOpen((o) => !o)} aria-label="Menu">
            <span /><span /><span />
          </button>
          <span className="topbar-brand">AppliTrack</span>
        </header>
        <main className="content">{children}</main>
      </div>

      {open && <div className="scrim" onClick={() => setOpen(false)} />}
    </div>
  );
}
