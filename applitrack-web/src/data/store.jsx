import { createContext, useContext, useEffect, useState } from 'react';
import {
  collection, doc, onSnapshot, setDoc, deleteDoc,
} from 'firebase/firestore';
import { db } from '../firebase';
import { useAuth } from '../auth/AuthContext';
import { useCrypto } from '../crypto/CryptoContext.jsx';
import { COLLECTIONS } from './collections';
import { uid, nowIso } from '../lib/format';

const DataCtx = createContext(null);
export const useData = () => useContext(DataCtx);

export function DataProvider({ children }) {
  const { user } = useAuth();
  const crypto = useCrypto();
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
      onSnapshot(collection(db, 'users', user.uid, name), async (snap) => {
        // Decrypt each doc (pass-through for legacy plaintext). decDoc binds to
        // the live key, so this works as soon as the device is unlocked.
        const rows = await Promise.all(
          snap.docs.map((d) => crypto.decDoc({ id: d.id, ...d.data() }).catch(() => null)),
        );
        setData((prev) => ({ ...prev, [name]: rows.filter(Boolean) }));
        setReady(true);
      }, () => setReady(true))
    );
    return () => unsubs.forEach((u) => u());
    // Re-subscribe when encryption flips on (after migration) so rows refresh decrypted.
  }, [user, crypto.decDoc, crypto.enabled]);

  // ---- low-level write helpers ----
  // Surface write/delete failures instead of swallowing them. Firestore uses
  // "latency compensation": a rejected write still shows locally for the
  // session, then vanishes on refresh — so a silent failure looks like data
  // "disappearing". A permission error here ("Missing or insufficient
  // permissions") means your security rules don't cover this collection.
  const ref = (name, id) => doc(db, 'users', user.uid, name, id);
  const put = async (name, obj) =>
    setDoc(ref(name, obj.id), await crypto.encDoc(obj)).catch((e) => {
      console.error(`[AppliTrack] failed to save to "${name}":`, e);
      alert(`Couldn't save to the cloud ("${name}"):\n${e.message}`);
      throw e;
    });
  const remove = (name, id) =>
    deleteDoc(ref(name, id)).catch((e) => {
      console.error(`[AppliTrack] failed to delete from "${name}":`, e);
      alert(`Couldn't delete from the cloud ("${name}"):\n${e.message}`);
      throw e;
    });

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
        notes: d.notes || null,
        resumeVersionId: d.resumeVersionId || null,
        coverLetterUsed: d.coverLetterUsed ?? false,
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

    // ---- documents (resumes / cover letters) — same shape as mobile AppDocument ----
    addDocument: (d) => put('documents', {
      id: uid(), name: d.name, type: d.type || 'resume',
      version: d.version || null, content: d.content || null,
      filePath: d.filePath || null, tags: d.tags || [],
      createdAt: nowIso(), updatedAt: nowIso(),
    }),
    updateDocument: (prev, patch) =>
      put('documents', { ...prev, ...patch, updatedAt: nowIso() }),
    deleteDocument: (id) => remove('documents', id),

    // ---- preferences (synced cross-device, e.g. the default resume) ----
    defaultResumeId: (data.preferences.find((p) => p.id === 'default') || {}).resumeId || null,
    setDefaultResume: (id) =>
      id ? put('preferences', { id: 'default', resumeId: id }) : remove('preferences', 'default'),
  };

  return <DataCtx.Provider value={api}>{children}</DataCtx.Provider>;
}
