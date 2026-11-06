// Generates synthetic X fixture + expected JSON from one data list (independent of the extractor).
const fs = require('fs');
const NOW = Date.now();
const posts = [];
for (let i = 1; i <= 25; i++) {
  posts.push({
    id: String(1000 + i), handle: '@user' + i, author: 'User ' + i,
    text: 'Post number ' + i + ' about shipping.\nSecond line ' + i,
    ageMin: i * 7, replies: i, reposts: i * 2, likes: i * 1000, views: i * 5000,
    isReply: i === 3, isRepost: i === 4, isAd: i === 5,
  });
}
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
const art = (p) => `
<article data-testid="tweet" role="article">
  ${p.isRepost ? '<div data-testid="socialContext">Someone reposted</div>' : ''}
  <div data-testid="User-Name"><div><span>${p.author}</span></div><div><span>${p.handle}</span><span>·</span>
    <a href="/${p.handle.slice(1)}/status/${p.id}"><time datetime="${new Date(NOW - p.ageMin * 60000).toISOString()}">${p.ageMin}m</time></a></div></div>
  ${p.isReply ? '<div>Replying to <a>@x</a></div>' : ''}
  ${p.isAd ? '<div data-testid="placementTracking"><span>Ad</span></div>' : ''}
  <div data-testid="tweetText" lang="en"><span>${esc(p.text).replace(/\n/g, '<br>')}</span></div>
  <div role="group">
    <button data-testid="reply" aria-label="${p.replies} Replies. Reply"><span>${p.replies}</span></button>
    <button data-testid="retweet" aria-label="${p.reposts} reposts. Repost"></button>
    <button data-testid="like" aria-label="${p.likes} Likes. Like"></button>
    <a href="/${p.handle.slice(1)}/status/${p.id}/analytics" aria-label="${p.views} views. View post analytics"></a>
  </div>
</article>`;
// Each article is tall so scrolling is required; only 4 are in the DOM at a time (virtualization).
const html = `<!doctype html><meta charset=utf-8><body style="margin:0">
<div data-testid="primaryColumn"><div id="list" style="height:0"></div></div>
<style>article{height:420px;border-bottom:1px solid #ccc}</style>
<script>
const posts = ${JSON.stringify(posts)};
const NOW = ${NOW};
const tpl = ${JSON.stringify(posts.map(art))};
const list = document.getElementById('list');
const H = 420;
list.style.height = (posts.length * H) + 'px';
function render() {
  const first = Math.max(0, Math.floor(scrollY / H) - 1);
  const last = Math.min(posts.length - 1, first + 4);
  list.innerHTML = '';
  for (let i = first; i <= last; i++) {
    const d = document.createElement('div');
    d.style.cssText = 'position:absolute;left:0;right:0;top:' + (i * H) + 'px';
    d.innerHTML = tpl[i];
    list.appendChild(d);
  }
}
addEventListener('scroll', render); render();
</script>`;
fs.writeFileSync(__dirname + '/fixtures/x-feed.html', html);
const expected = posts.slice(0, 20).map((p) => ({
  id: p.id, handle: p.handle, author: p.author, likes: p.likes, views: p.views,
  replies: p.replies, reposts: p.reposts, isReply: p.isReply, isRepost: p.isRepost, isAd: p.isAd,
  text: p.text,
}));
fs.writeFileSync(__dirname + '/expected/x-feed.json', JSON.stringify(expected, null, 1));
console.log('wrote', posts.length, 'posts;', expected.length, 'expected');
