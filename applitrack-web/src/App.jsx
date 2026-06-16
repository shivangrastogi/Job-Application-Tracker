import { lazy, Suspense } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './auth/AuthContext.jsx';
import { DataProvider } from './data/store.jsx';
import { CryptoProvider, useCrypto } from './crypto/CryptoContext.jsx';
import Unlock from './crypto/Unlock.jsx';
import Shell from './components/Shell.jsx';
import Login from './auth/Login.jsx';

// Page routes are lazy-loaded so the initial bundle only ships the shell +
// whichever page you land on; the rest download on navigation.
const Dashboard = lazy(() => import('./pages/Dashboard.jsx'));
const Applications = lazy(() => import('./pages/Applications.jsx'));
const Companies = lazy(() => import('./pages/Companies.jsx'));
const CompanyJobs = lazy(() => import('./pages/CompanyJobs.jsx'));
const Catalog = lazy(() => import('./pages/Catalog.jsx'));
const Goals = lazy(() => import('./pages/Goals.jsx'));
const Referrals = lazy(() => import('./pages/Referrals.jsx'));
const Interviews = lazy(() => import('./pages/Interviews.jsx'));
const Resumes = lazy(() => import('./pages/Resumes.jsx'));
const Analytics = lazy(() => import('./pages/Analytics.jsx'));
const Profile = lazy(() => import('./pages/Profile.jsx'));

export default function App() {
  const { user, loading } = useAuth();

  if (loading) {
    return <div className="splash"><div className="spinner" /></div>;
  }

  if (!user) {
    return (
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  return (
    <CryptoProvider>
      <CryptoGate>
        <DataProvider>
          <Shell>
            <Suspense fallback={<div className="splash"><div className="spinner" /></div>}>
            <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/applications" element={<Applications />} />
          <Route path="/companies" element={<Companies />} />
          <Route path="/companies/catalog" element={<Catalog />} />
          <Route path="/companies/:id" element={<CompanyJobs />} />
          <Route path="/goals" element={<Goals />} />
          <Route path="/referrals" element={<Referrals />} />
          <Route path="/interviews" element={<Interviews />} />
          <Route path="/resumes" element={<Resumes />} />
          <Route path="/analytics" element={<Analytics />} />
          <Route path="/profile" element={<Profile />} />
              <Route path="/login" element={<Navigate to="/" replace />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
            </Suspense>
          </Shell>
        </DataProvider>
      </CryptoGate>
    </CryptoProvider>
  );
}

// Holds the app behind the unlock screen when this device is locked.
function CryptoGate({ children }) {
  const { status } = useCrypto();
  if (status === 'loading') return <div className="splash"><div className="spinner" /></div>;
  if (status === 'locked') return <Unlock />;
  return children;
}
