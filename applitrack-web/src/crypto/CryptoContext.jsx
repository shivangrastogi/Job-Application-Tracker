import { createContext, useContext, useEffect, useRef, useState, useCallback } from 'react';
import { doc, getDoc, setDoc, deleteDoc, collection, getDocs, writeBatch } from 'firebase/firestore';
import { db } from '../firebase';
import { useAuth } from '../auth/AuthContext.jsx';
import { COLLECTIONS } from '../data/collections';
import {
  deriveKey, exportKeyRaw, importKeyRaw, randomBytes, toB64, fromB64,
  makeVerifier, checkVerifier, encryptDoc, decryptDoc, PBKDF2_ITERATIONS, CRYPTO_VERSION,
} from '../lib/crypto';

const CryptoCtx = createContext(null);
export const useCrypto = () => useContext(CryptoCtx);

const metaDoc = (uid) => doc(db, 'users', uid, 'meta', 'crypto');
// Device-local cache of the derived key so the passphrase is entered once per
// device (the key never leaves the device and never reaches the server).
const cacheKey = (uid) => `applitrack.enckey.${uid}`;

export function CryptoProvider({ children }) {
  const { user } = useAuth();
  const [status, setStatus] = useState('loading'); // loading | disabled | locked | unlocked
  const [busy, setBusy] = useState(false);
  const keyRef = useRef(null);
  const metaRef = useRef(null); // { salt, verifier, iterations }

  useEffect(() => {
    let cancelled = false;
    keyRef.current = null;
    metaRef.current = null;
    if (!user) { setStatus('loading'); return undefined; }
    (async () => {
      setStatus('loading');
      let snap;
      try { snap = await getDoc(metaDoc(user.uid)); } catch { if (!cancelled) setStatus('disabled'); return; }
      if (cancelled) return;
      if (!snap.exists()) { setStatus('disabled'); return; }
      const meta = snap.data();
      metaRef.current = meta;
      try {
        const cached = localStorage.getItem(cacheKey(user.uid));
        if (cached) {
          const k = await importKeyRaw(cached);
          if (await checkVerifier(k, meta.verifier)) { keyRef.current = k; if (!cancelled) setStatus('unlocked'); return; }
        }
      } catch { /* fall through to locked */ }
      if (!cancelled) setStatus('locked');
    })();
    return () => { cancelled = true; };
  }, [user]);

  const enabled = status === 'unlocked';

  // Bound to the live key ref so an in-flight snapshot subscription still
  // decrypts correctly the moment the key becomes available.
  const decDoc = useCallback((d) => (keyRef.current ? decryptDoc(keyRef.current, d) : Promise.resolve(d)), []);
  const encDoc = useCallback((obj) => (enabled && keyRef.current ? encryptDoc(keyRef.current, obj) : Promise.resolve(obj)), [enabled]);

  const unlock = useCallback(async (passphrase) => {
    const meta = metaRef.current;
    if (!meta) throw new Error('Encryption is not set up.');
    const key = await deriveKey(passphrase, fromB64(meta.salt), meta.iterations || PBKDF2_ITERATIONS);
    if (!(await checkVerifier(key, meta.verifier))) throw new Error('Wrong passphrase.');
    keyRef.current = key;
    try { localStorage.setItem(cacheKey(user.uid), await exportKeyRaw(key)); } catch { /* ignore */ }
    setStatus('unlocked');
  }, [user]);

  const lock = useCallback(() => {
    keyRef.current = null;
    try { localStorage.removeItem(cacheKey(user.uid)); } catch { /* ignore */ }
    setStatus('locked');
  }, [user]);

  // Set a passphrase + encrypt all existing data (one-time migration).
  const setup = useCallback(async (passphrase, onProgress) => {
    setBusy(true);
    try {
      const salt = randomBytes(16);
      const key = await deriveKey(passphrase, salt);
      const verifier = await makeVerifier(key);
      for (const name of COLLECTIONS) {
        const snap = await getDocs(collection(db, 'users', user.uid, name));
        const docs = snap.docs.filter((d) => !d.data()._enc);
        for (let i = 0; i < docs.length; i += 400) {
          const batch = writeBatch(db);
          for (const d of docs.slice(i, i + 400)) {
            const enc = await encryptDoc(key, { id: d.id, ...d.data() });
            batch.set(doc(db, 'users', user.uid, name, d.id), enc);
          }
          await batch.commit();
        }
        onProgress?.(name);
      }
      const meta = { salt: toB64(salt), verifier, iterations: PBKDF2_ITERATIONS, v: CRYPTO_VERSION, createdAt: new Date().toISOString() };
      await setDoc(metaDoc(user.uid), meta); // written last → marks encryption "on"
      metaRef.current = meta;
      keyRef.current = key;
      try { localStorage.setItem(cacheKey(user.uid), await exportKeyRaw(key)); } catch { /* ignore */ }
      setStatus('unlocked');
    } finally { setBusy(false); }
  }, [user]);

  // Turn encryption off again: decrypt everything back to plaintext.
  const disable = useCallback(async () => {
    if (!keyRef.current) throw new Error('Unlock first.');
    setBusy(true);
    try {
      const key = keyRef.current;
      for (const name of COLLECTIONS) {
        const snap = await getDocs(collection(db, 'users', user.uid, name));
        const docs = snap.docs.filter((d) => d.data()._enc);
        for (let i = 0; i < docs.length; i += 400) {
          const batch = writeBatch(db);
          for (const d of docs.slice(i, i + 400)) {
            const plain = await decryptDoc(key, { id: d.id, ...d.data() });
            const { id, ...rest } = plain;
            batch.set(doc(db, 'users', user.uid, name, id), rest);
          }
          await batch.commit();
        }
      }
      await deleteDoc(metaDoc(user.uid));
      keyRef.current = null;
      metaRef.current = null;
      try { localStorage.removeItem(cacheKey(user.uid)); } catch { /* ignore */ }
      setStatus('disabled');
    } finally { setBusy(false); }
  }, [user]);

  const value = { status, enabled, busy, encDoc, decDoc, setup, unlock, lock, disable };
  return <CryptoCtx.Provider value={value}>{children}</CryptoCtx.Provider>;
}
