// usage: node compare.js <actual.json> <expected.json>; compares expected fields per item, in order.
const fs = require('fs');
const raw = fs.readFileSync(process.argv[2], 'utf8').trim();
let out = JSON.parse(raw); if (typeof out === 'string') out = JSON.parse(out);
if (out.result !== undefined) { out = out.result; if (typeof out === 'string') out = JSON.parse(out); }
const exp = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
let bad = 0;
const fail = (m) => { console.log('FAIL', m); bad++; };
if (out.errors && out.errors.length) fail('errors: ' + out.errors.join(','));
if (out.items.length !== exp.length) fail(`count ${out.items.length} != ${exp.length}`);
exp.forEach((e, i) => {
  const a = out.items[i] || {};
  for (const k of Object.keys(e)) if (JSON.stringify(a[k]) !== JSON.stringify(e[k])) fail(`item ${i} ${k}: got ${JSON.stringify(a[k])} want ${JSON.stringify(e[k])}`);
});
if (process.env.EXPECT_MISS && !(out.selectorMisses || []).length) fail('expected selectorMisses to be non-empty');
console.log(bad ? `${bad} failures` : `OK ${out.items.length} items in ${out.ms}ms, misses=${JSON.stringify(out.selectorMisses)}`);
process.exit(bad ? 1 : 0);
