import { createContext, useContext, useEffect, useState } from 'react';
import {
  collection, doc, onSnapshot, setDoc, deleteDoc,
} from 'firebase/firestore';
import { db } from '../firebase';
import { useAuth } from '../auth/AuthContext';
import { uid, nowIso } from '../lib/format';

const DataCtx = createContext(null);
export const useData = () => useContext(DataCtx);

// Collections that live under users/{uid}/...  (mirrors the mobile app).
const COLLECTIONS = [
  'applications', 'interviews', 'contacts', 'timeline',
  'companies', 'goals', 'referral_sources', 'referrals',
];

export function DataProvider({ children }) {
  const { user } = useAuth();
  const [data, setData] = useState(() =>
    Object.fromEntries(COLLECTIONS.map((c) => [c, []])));
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!user) {
      setData(Object.fromEntries(COLLECTIONS.map((c) => [c, []])));
      setReady(false);
      return;
    }
    const unsubs = COLLECTIONS.map((name) =>
      onSnapshot(collection(db, 'users', user.uid, name), (snap) => {
        const rows = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        setData((prev) => ({ ...prev, [name]: rows }));
        setReady(true);
      }, () => setReady(true))
    );
    return () => unsubs.forEach((u) => u());
  }, [user]);

  // ---- low-level write helpers ----
  const ref = (name, id) => doc(db, 'users', user.uid, name, id);
  const put = (name, obj) => setDoc(ref(name, obj.id), obj);
  const remove = (name, id) => deleteDoc(ref(name, id));

  // ---- timeline ----
  const addTimeline = (applicationId, type, description, extra = {}) =>
    put('timeline', {
      id: uid(), applicationId, type, description,
      timestamp: nowIso(), ...extra,
    });

  // ---- applications ----
  const api = {
    ready,
    ...data,

    addApplication: async (d) => {
      const id = uid();
      const now = nowIso();
      const app = {
        id, company: d.company, role: d.role,
        status: d.status || 'wishlist',
        appliedDate: d.appliedDate || null,
        jobUrl: d.jobUrl || null, location: d.location || null,
        workType: d.workType || 'onsite',
        salaryMin: d.salaryMin ?? null, salaryMax: d.salaryMax ?? null,
        salaryCurrency: d.salaryCurrency || 'INR',
        source: d.source || 'other', sourceName: d.sourceName || null,
        priority: d.priority ?? 3, tags: d.tags || [],
        notes: d.notes || null, resumeVersionId: null, coverLetterUsed: false,
        createdAt: now, updatedAt: now,
      };
      await put('applications', app);
      await addTimeline(id, 'statusChange', `Application created as ${app.status}`, { newStatus: app.status });
      return app;
    },
    updateApplication: async (prev, patch) => {
      const next = { ...prev, ...patch, updatedAt: nowIso() };
      await put('applications', next);
      if (patch.status && patch.status !== prev.status) {
        await addTimeline(prev.id, 'statusChange',
          `Status changed from ${prev.status} to ${patch.status}`,
          { previousStatus: prev.status, newStatus: patch.status });
      }
      return next;
    },
    deleteApplication: (id) => remove('applications', id),

    // ---- interviews ----
    addInterview: (d) => put('interviews', {
      id: uid(), applicationId: d.applicationId, type: d.type || 'phone',
      scheduledAt: d.scheduledAt, durationMinutes: d.durationMinutes ?? 60,
      platform: d.platform || null, interviewerName: d.interviewerName || null,
      notes: d.notes || null, feedback: null, outcome: 'pending',
      createdAt: nowIso(),
    }),
    deleteInterview: (id) => remove('interviews', id),

    // ---- companies ----
    addCompany: (d) => put('companies', {
      id: uid(), name: d.name, provider: d.provider || 'custom',
      slug: d.slug || null, careerUrl: d.careerUrl || null, logoUrl: null,
      location: d.location || null, category: d.category || 'other',
      tags: d.tags || [], notes: null, config: d.config || {},
      lastFetchedAt: null, lastJobCount: 0,
      createdAt: nowIso(), updatedAt: nowIso(),
    }),
    updateCompany: (prev, patch) =>
      put('companies', { ...prev, ...patch, updatedAt: nowIso() }),
    deleteCompany: (id) => remove('companies', id),
    recordFetch: (prev, count) =>
      put('companies', { ...prev, lastFetchedAt: nowIso(), lastJobCount: count, updatedAt: nowIso() }),

    // ---- goals ----
    addGoal: (d) => put('goals', {
      id: uid(), metric: d.metric, period: d.period, target: d.target,
      active: true, createdAt: nowIso(),
    }),
    updateGoal: (g) => put('goals', g),
    deleteGoal: (id) => remove('goals', id),

    // ---- referral sources ----
    addSource: (d) => put('referral_sources', {
      id: uid(), name: d.name, type: d.type || 'group', url: d.url || null,
      formTemplate: d.formTemplate || null, notes: d.notes || null, createdAt: nowIso(),
    }),
    updateSource: (s) => put('referral_sources', s),
    deleteSource: (id) => remove('referral_sources', id),

    // ---- referrals ----
    addReferral: (d) => put('referrals', {
      id: uid(), sourceId: d.sourceId || null, company: d.company,
      role: d.role || null, jobUrl: d.jobUrl || null, referrerName: d.referrerName || null,
      status: d.status || 'requested', requestedDate: d.requestedDate || nowIso(),
      notes: d.notes || null, linkedApplicationId: null,
      createdAt: nowIso(), updatedAt: nowIso(),
    }),
    updateReferral: (prev, patch) =>
      put('referrals', { ...prev, ...patch, updatedAt: nowIso() }),
    deleteReferral: (id) => remove('referrals', id),
  };

  return <DataCtx.Provider value={api}>{children}</DataCtx.Provider>;
}
