# AppliTrack — Marketing Website

A standalone, production-ready landing page for the AppliTrack job-application tracker.
Pure static site — **no build step, no dependencies**. Just open or host it.

## Files
| File | Purpose |
|------|---------|
| `index.html` | Page structure & copy (semantic, accessible) |
| `styles.css` | All styling — design tokens, layout, animations, responsive |
| `script.js`  | Scroll reveals, animated pipeline, mobile menu, current year |

## View locally
Double-click `index.html`, or serve it (recommended, so fonts/relative paths behave like production):

```bash
# from the website/ folder
python -m http.server 8000
# then open http://localhost:8000
```

## Deploy
Drop the `website/` folder onto any static host — GitHub Pages, Netlify, Vercel, Cloudflare Pages, S3, etc. No configuration required.

## Design
- **Aesthetic:** editorial "career command center" — warm ink background with a fine grid + grain texture.
- **Type:** Fraunces (display) · Hanken Grotesk (body) · JetBrains Mono (data labels), via Google Fonts.
- **Color:** deep ink with a single acid-lime accent and amber "offer" highlights, echoing the app's pipeline.
- **Motion:** one orchestrated hero load with staggered reveals, an IntersectionObserver-driven pipeline funnel that grows on scroll, and a paused-on-hover company marquee.
- **Responsive:** 3-col → 2-col → 1-col, with a hamburger menu under 980px.
- **Accessibility:** honours `prefers-reduced-motion`, keyboard-focusable nav, semantic landmarks, ARIA labels.

## Customising
- Colors & fonts: edit the `:root` CSS variables at the top of `styles.css`.
- Copy & sections: all in `index.html`.
- The Android download buttons (`#download`) currently link to placeholders — point them at your Play Store / APK URL when ready.
