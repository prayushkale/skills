// LinkedIn feed extractor (2026 componentized layout; class names are obfuscated, so anchor on ARIA labels).
// Posts = div[role=listitem] containing button[aria-label^="Hide post by"]. Other listitems (share box, "New posts") are skipped.
// Run via agent-browser:   (echo 'window.__FB_N=20;'; cat linkedin-feed.js) | fb eval --stdin
// Run via Claude in Chrome javascript_tool:   window.__fbSeen=undefined; JSON.stringify(await (<this file>))
// Permalinks are not in this DOM, so `key` identifies a post; comment on it in place with linkedin-comment.js.
(async () => {
  const N = window.__FB_N || 20;
  const TIMEOUT_MS = window.__FB_TIMEOUT || 15000;
  const MAX_TEXT = 600;
  const seen = (window.__fbSeen = window.__fbSeen || new Set());
  const misses = new Set();
  const errors = [];
  const items = [];

  const num = (s) => {
    const m = String(s || '').replace(/,/g, '').match(/([\d.]+)\s*([KM])?/i);
    return m ? Math.round(parseFloat(m[1]) * ({ K: 1e3, M: 1e6 }[(m[2] || '').toUpperCase()] || 1)) : 0;
  };
  if (/\/(login|uas\/login|checkpoint|authwall)/.test(location.pathname) || document.querySelector('form.login__form, input#session_key')) {
    return JSON.stringify({ items: [], errors: ['loginRequired'], selectorMisses: [], url: location.href });
  }

  const isUuid = (k) => /^[0-9a-f]{8}-[0-9a-f]{4}-/.test(k);
  const parse = (el) => {
    const hide = el.querySelector('button[aria-label^="Hide post by"]');
    if (!hide) return null; // not a post
    const key = [...el.querySelectorAll('[componentkey]')]
      .map((x) => x.getAttribute('componentkey'))
      .find((k) => k && !isUuid(k) && k.length >= 20 && !/replaceable|Ref$|^draft/i.test(k));
    if (!key) { misses.add('key:all-missed'); return null; }
    if (seen.has(key)) return null;
    const ps = [...el.querySelectorAll('p')].filter((p) => !p.closest('button')).map((p) => p.innerText.replace(/\s+/g, ' ').trim()).filter(Boolean);
    if (!ps.length) { misses.add('p:all-missed'); return null; }
    const body = ps.reduce((a, b) => (b.length > a.length ? b : a), '');
    const bodyFull = [...el.querySelectorAll('p')].find((p) => p.innerText.replace(/\s+/g, ' ').trim() === body);
    const age = ps.find((t) => /^\d+\s?(s|m|h|d|w|mo|yr)$/.test(t)) || '';
    if (!age) misses.add('age:missed');
    const author = hide.getAttribute('aria-label').replace(/^Hide post by\s*/i, '').trim() || ps[0] || '';
    const inner = el.innerText;
    const cm = inner.match(/([\d,.]+[KM]?)\s+comments?\b/i);
    const rm = inner.match(/(?:^|\n)\s*([\d,.]+[KM]?)\s*(?:\n|$)/);
    return {
      key,
      url: null,
      author,
      headline: ps[2] && ps[2] !== age ? ps[2].slice(0, 120) : '',
      text: (bodyFull ? bodyFull.innerText : body).replace(/\n{3,}/g, '\n\n').replace(/…\s*more$/i, '').trim().slice(0, MAX_TEXT),
      ageLabel: age,
      reactions: rm ? num(rm[1]) : 0,
      comments: cm ? num(cm[1]) : 0,
      isPromoted: /(^|\n)\s*Promoted\s*(\n|$)/.test(inner),
    };
  };

  const collect = () => {
    const els = document.querySelectorAll('div[role="listitem"]');
    if (!els.length) misses.add('container:all-missed');
    for (const el of els) {
      if (items.length >= N) break;
      try { const it = parse(el); if (it) { seen.add(it.key); items.push(it); } }
      catch (e) { errors.push(String(e).slice(0, 120)); }
    }
  };

  const t0 = Date.now();
  let stalls = 0;
  collect();
  while (items.length < N && Date.now() - t0 < TIMEOUT_MS && stalls < 6) {
    const before = items.length;
    // The feed may scroll inside its own container, so scroll the last post into view instead of the window.
    const list = document.querySelectorAll('div[role="listitem"]');
    const countBefore = list.length;
    if (list.length) list[list.length - 1].scrollIntoView({ block: 'end' });
    window.scrollBy(0, Math.round(window.innerHeight * 0.5));
    // wait for more posts to render (poll, max 2.5 s), not for any DOM mutation
    for (let w = 0; w < 25 && document.querySelectorAll('div[role="listitem"]').length <= countBefore; w++) {
      await new Promise((r) => setTimeout(r, 100));
    }
    await new Promise((r) => setTimeout(r, 150));
    collect();
    stalls = items.length === before ? stalls + 1 : 0;
  }
  return JSON.stringify({ items, errors, selectorMisses: [...misses], ms: Date.now() - t0, url: location.href });
})()
