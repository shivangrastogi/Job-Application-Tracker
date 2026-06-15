// AppliTrack landing — interactions
(() => {
  'use strict';

  // ---- current year ----
  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  // ---- mobile menu ----
  const toggle = document.getElementById('navToggle');
  const menu = document.getElementById('mobileMenu');
  if (toggle && menu) {
    const setOpen = (open) => {
      menu.hidden = !open;
      toggle.classList.toggle('open', open);
      toggle.setAttribute('aria-expanded', String(open));
    };
    toggle.addEventListener('click', () => setOpen(menu.hidden));
    menu.querySelectorAll('a').forEach((a) =>
      a.addEventListener('click', () => setOpen(false))
    );
  }

  // ---- scroll reveals ----
  const reveals = document.querySelectorAll('.reveal');
  const pipe = document.getElementById('pipeViz');

  if (!('IntersectionObserver' in window)) {
    reveals.forEach((el) => el.classList.add('in'));
    if (pipe) pipe.classList.add('in');
    return;
  }

  const io = new IntersectionObserver(
    (entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('in');
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.16, rootMargin: '0px 0px -8% 0px' }
  );

  reveals.forEach((el) => io.observe(el));

  // ---- pipeline funnel grow-in ----
  if (pipe) {
    const pipeIO = new IntersectionObserver(
      (entries, obs) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('in');
            obs.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.3 }
    );
    pipeIO.observe(pipe);
  }
})();
