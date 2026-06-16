// End-to-end encryption primitives (AES-GCM + PBKDF2-SHA256).
//
// FORMAT (must stay identical on web + mobile so both can decrypt each other):
//   key   = PBKDF2-HMAC-SHA256(passphrase, salt, 210000 iterations) -> 256-bit
//   salt  = 16 random bytes (stored, non-secret)
//   cipher= AES-256-GCM, 12-byte random IV per value
//   blob  = base64( iv(12) || ciphertext+tag )
//   doc   = { id, _enc: <blob of JSON.stringify(everything-except-id)>, _v: 1 }
// The passphrase and derived key never leave the device / never touch the server.
export const PBKDF2_ITERATIONS = 210000;
export const CRYPTO_VERSION = 1;
const VERIFIER_TEXT = 'applitrack-encryption-ok';

const te = new TextEncoder();
const td = new TextDecoder();

export function toB64(bytes) {
  let s = '';
  const arr = new Uint8Array(bytes);
  for (let i = 0; i < arr.length; i += 1) s += String.fromCharCode(arr[i]);
  return btoa(s);
}
export function fromB64(str) {
  return Uint8Array.from(atob(str), (c) => c.charCodeAt(0));
}
export function randomBytes(n) {
  return crypto.getRandomValues(new Uint8Array(n));
}

export async function deriveKey(passphrase, salt, iterations = PBKDF2_ITERATIONS) {
  const base = await crypto.subtle.importKey('raw', te.encode(passphrase), 'PBKDF2', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt, iterations, hash: 'SHA-256' },
    base,
    { name: 'AES-GCM', length: 256 },
    true, // extractable so the key can be cached per-device
    ['encrypt', 'decrypt'],
  );
}

export async function exportKeyRaw(key) {
  return toB64(await crypto.subtle.exportKey('raw', key));
}
export async function importKeyRaw(b64) {
  return crypto.subtle.importKey('raw', fromB64(b64), { name: 'AES-GCM' }, true, ['encrypt', 'decrypt']);
}

export async function encryptString(key, plaintext) {
  const iv = randomBytes(12);
  const ct = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, te.encode(plaintext));
  const out = new Uint8Array(iv.length + ct.byteLength);
  out.set(iv, 0);
  out.set(new Uint8Array(ct), iv.length);
  return toB64(out);
}
export async function decryptString(key, blob) {
  const data = fromB64(blob);
  const iv = data.slice(0, 12);
  const ct = data.slice(12);
  const pt = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, ct);
  return td.decode(pt);
}

// A doc -> encrypted doc ({ id stays plaintext as the Firestore key }).
export async function encryptDoc(key, obj) {
  const { id, ...rest } = obj;
  return { id, _enc: await encryptString(key, JSON.stringify(rest)), _v: CRYPTO_VERSION };
}
// An encrypted (or legacy-plaintext) doc -> plaintext object.
export async function decryptDoc(key, doc) {
  if (!doc || !doc._enc) return doc; // legacy plaintext or meta — pass through
  const rest = JSON.parse(await decryptString(key, doc._enc));
  return { id: doc.id, ...rest };
}

export async function makeVerifier(key) {
  return encryptString(key, VERIFIER_TEXT);
}
export async function checkVerifier(key, verifier) {
  try {
    return (await decryptString(key, verifier)) === VERIFIER_TEXT;
  } catch {
    return false;
  }
}
