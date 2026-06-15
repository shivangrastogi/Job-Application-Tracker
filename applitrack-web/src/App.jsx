import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './auth/AuthContext.jsx';
import { DataProvider } from './data/store.jsx';
import Shell from './components/Shell.jsx';
import Login from './auth/Login.jsx';
import Dashboard from './pages/Dashboard.jsx';
import Applications from './pages/Applications.jsx';
import Companies from './pages/Companies.jsx';
import CompanyJobs from './pages/CompanyJobs.jsx';
import Catalog from './pages/Catalog.jsx';
import Goals from './pages/Goals.jsx';
import Referrals from './pages/Referrals.jsx';
import Interviews from './pages/Interviews.jsx';
import Resumes from './pages/Resumes.jsx';
import Analytics from './pages/Analytics.jsx';
import Profile from './pages/Profile.jsx';

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
    <DataProvider>
      <Shell>
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
      </Shell>
    </DataProvider>
  );
}
