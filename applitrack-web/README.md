# AppliTrack — Web App

The online version of the AppliTrack mobile app. Sign in and access **the same data** as the phone app (it uses the same Firebase project), with full feature parity: add/track jobs, pipeline & kanban, companies + live job sync, goals, referrals, interviews, and analytics.

## Stack
- **React 18 + Vite**
- **Firebase** Auth (Google + email/password) + **Cloud Firestore** — same project as mobile (`jarvis-calendar-469216`), data stored under `users/{uid}/...` so web ⇄ mobile sync is automatic and real-time.
- A tiny Node **proxy** (`server/proxy.mjs`) so career-page APIs (Greenhouse, Lever, Amazon, Workday…) work in the browser despite CORS.

## Run locally
```bash
npm install        # already done

# terminal 1 — the CORS proxy for live job sync
npm run proxy

# terminal 2 — the app
npm run dev        # http://localhost:5173
```
Job sync only needs the proxy; everything else works without it.

## Build for production
```bash
npm run build      # outputs to dist/
npm run preview    # preview the production build
```

## Before it works end-to-end (Firebase console)
The web app talks to your existing Firebase project. Two one-time settings:
1. **Authentication → Sign-in method:** enable **Google** and **Email/Password**.
2. **Authentication → Settings → Authorized domains:** add `localhost` (already allowed by default) and your production domain when you deploy.
3. **Firestore security rules** — make sure each user can only read/write their own data:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

## Deploying
- **App:** any static host (Vercel, Netlify, Firebase Hosting, Cloudflare Pages) — deploy `dist/`.
- **Proxy:** deploy `server/proxy.mjs` as a serverless/edge function reachable at the `/proxy` path (or set up a host rewrite to it). Locally, Vite proxies `/proxy` → `localhost:8787`.

## Features
| Page | What it does |
|------|--------------|
| Dashboard | Stats, pipeline, today's goals, response rate |
| Applications | List + Kanban, search, status filter, add/edit/delete |
| Companies | Grouped by category, add/paste-URL auto-detect, catalog of 40+ employers |
| Company jobs | Live openings via ATS APIs with filters; one-tap "Track" → application |
| Interviews | Schedule & list interviews tied to applications |
| Goals | Daily/weekly/monthly targets with live progress |
| Referrals | Groups/forms + request pipeline + Google-Form prefill + convert-to-application |
| Analytics | Funnel, response/offer rate, by-source, status breakdown |
| Profile | Account + data overview + sign out |

> Note: companies / goals / referrals are stored under `users/{uid}/...` on the web. The mobile app currently keeps those locally (Hive) and syncs applications/interviews/contacts/timeline; aligning mobile to sync those collections too is a small follow-up.
