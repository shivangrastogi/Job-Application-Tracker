import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider } from 'firebase/auth';
import { initializeFirestore } from 'firebase/firestore';

// Same Firebase project as the AppliTrack mobile app, so web ⇄ mobile data
// syncs automatically. (Firebase web config is safe to ship in the client;
// access is controlled by Firestore security rules + Auth.)
const firebaseConfig = {
  apiKey: 'AIzaSyDmecM0vnZi6GaYYMlhlNwP7P41boqjKCI',
  authDomain: 'jarvis-calendar-469216.firebaseapp.com',
  projectId: 'jarvis-calendar-469216',
  storageBucket: 'jarvis-calendar-469216.firebasestorage.app',
  messagingSenderId: '453229654159',
  appId: '1:453229654159:web:5c947c8e5de67506b440fa',
  measurementId: 'G-0T7S1ST3S8',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
// Auto-detect long-polling so Firestore still works when its streaming
// WebChannel/QUIC connection is blocked by a proxy, VPN, ad-blocker, or strict
// network — the cause of "WebChannelConnection RPC 'Listen' stream transport
// errored" / ERR_QUIC_PROTOCOL_ERROR, where data silently never reaches the server.
export const db = initializeFirestore(app, {
  experimentalAutoDetectLongPolling: true,
});
export const googleProvider = new GoogleAuthProvider();
