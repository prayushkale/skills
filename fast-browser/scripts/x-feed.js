// X feed extractor. Run: (echo 'window.__FB_N=20;'; cat x-feed.js) | fb eval --stdin
// Scrolls inside the page, collects up to N new posts (X virtualizes the DOM, so collect while scrolling),
// and returns one JSON object. No screenshots, one tool call.
(async () => {
  const N = window.__FB_N || 20;
  const TIMEOUT_MS = window.__FB_TIMEOUT || 15000;
  const MAX_TEXT = 600;
  const seen = (window.__fbSeen = window.__fbSeen || new Set());
  const misses = new Set();
  const errors = [];
  const items = [];

  const first = (root, name, sels) => {
    for (let i = 0; i < sels.length; i++) {
      const el = root.querySelector(sels[i]);
      if (el) { if (i > 0) misses.add(name + ':primary-missed'); return el; }
    }
    misses.add(name + ':all-missed');
    return null;
  };
  const num = (s) => {
    if (!s) return 0;
    const m = String(s).replace(/,/g, '').match(/([\d.]+)\s*([KMB])?/i);
    if (!m) return 0;
    const mult = { K: 1e3, M: 1e6, B: 1e9 }[(m[2] || '').toUpperCase()] || 1;
    return Math.round(parseFloat(m[1]) * mult);
  };
  const metric = (art, testid) => {
    const el = art.querySelector('[data-testid="' + testid + '"]');
    if (!el) return 0;
    const label = el.getAttribute('aria-label') || el.textContent || '';
    return num(label);
  };

  const loginWall = () =>
    /\/i\/flow\/login|\/login/.test(location.pathname) ||
    !!document.querySelector('[data-testid="loginButton"], [data-testid="signupButton"]') &&
      !document.querySelector('[data-testid="primaryColumn"] article');

  if (loginWall()) {
    return JSON.stringify({ items: [], errors: ['loginRequired'], selectorMisses: [], url: location.href });
  }

  const parse = (art) => {
    const link = first(art, 'permalink', ['a[href*="/status/"] time', 'time'])?.closest('a');
    const href = link ? link.getAttribute('href') : null;
    const idm = href && href.match(/\/status\/(\d+)/);
    if (!idm) return null;
    const id = idm[1];
    if (seen.has(id)) return null;
    const time = link.querySelector('time');
    const ageMin = time ? Math.max(0, Math.round((Date.now() - new Date(time.getAttribute('datetime')).getTime()) / 60000)) : null;
    const nameEl = first(art, 'author', ['[data-testid="User-Name"]', 'div[dir="ltr"] > span']);
    const nameText = nameEl ? nameEl.innerText.split('\n') : [];
    const hm = nameEl && nameEl.innerText.match(/@\w{1,15}/);
    const handle = hm ? hm[0] : '';
    const author = (nameText[0] || '').trim();
    const textEl = first(art, 'text', ['[data-testid="tweetText"]', 'div[lang]']);
    const text = textEl ? textEl.innerText.replace(/\s+\n/g, '\n').trim().slice(0, MAX_TEXT) : '';
    const social = art.querySelector('[data-testid="socialContext"]');
    const views = (() => {
      const a = art.querySelector('a[href$="/analytics"]');
      return a ? num(a.getAttribute('aria-label') || a.textContent) : 0;
    })();
    const inner = art.innerText;
    return {
      id,
      url: 'https://x.com' + href.split('?')[0],
      author,
      handle,
      text,
      ageMin,
      replies: metric(art, 'reply'),
      reposts: metric(art, 'retweet'),
      likes: metric(art, 'like'),
      views,
      isReply: /^Replying to/m.test(inner),
      isRepost: !!(social && /reposted/i.test(social.innerText)),
      isAd: !!art.querySelector('[data-testid="placementTracking"]') || /\nAd\n/.test('\n' + inner + '\n'),
    };
  };

  const collect = () => {
    const arts = document.querySelectorAll('article[data-testid="tweet"], article[role="article"]');
    if (!arts.length) misses.add('article:all-missed');
    for (const art of arts) {
      if (items.length >= N) break;
      try {
        const it = parse(art);
        if (it) { seen.add(it.id); items.push(it); }
      } catch (e) { errors.push(String(e).slice(0, 120)); }
    }
  };

  const t0 = Date.now();
  let stalls = 0;
  collect();
  while (items.length < N && Date.now() - t0 < TIMEOUT_MS && stalls < 6) {
    const before = items.length;
    window.scrollBy(0, Math.round(window.innerHeight * 0.9));
    // wait for new nodes (or 600 ms max) instead of a fixed sleep
    await new Promise((res) => {
      const mo = new MutationObserver(() => { mo.disconnect(); res(); });
      mo.observe(document.body, { childList: true, subtree: true });
      setTimeout(() => { mo.disconnect(); res(); }, 600);
    });
    await new Promise((r) => setTimeout(r, 120)); // let layout settle
    collect();
    stalls = items.length === before ? stalls + 1 : 0;
  }

  return JSON.stringify({
    items,
    errors,
    selectorMisses: [...misses],
    ms: Date.now() - t0,
    url: location.href,
  });
})()
