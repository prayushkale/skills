#!/usr/bin/env bash
# Runs each extractor against its fixture in an isolated throwaway browser session. Exit 0 = all match.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; root="$here/.."
export FB_SESSION=fbtest FB_PROFILE="$(mktemp -d)"
fb="$root/scripts/fb"; rc=0
trap '"$fb" close >/dev/null 2>&1; rm -rf "$FB_PROFILE"' EXIT

run_case() { # name fixture extractor expected [prefix-js]
  local name=$1 fix=$2 ext=$3 exp=$4 pre=${5:-}
  "$fb" open about:blank >/dev/null 2>&1
  "$fb" --allow-file-access open "file://$here/fixtures/$fix" >/dev/null 2>&1 || { echo "FAIL $name: open"; rc=1; return; }
  { echo "window.__FB_N=20;window.__fbSeen=undefined;$pre"; cat "$root/scripts/$ext"; } | "$fb" eval --stdin > "$FB_PROFILE/$name.out" 2>"$FB_PROFILE/$name.err"
  echo -n "$name: "; node "$here/compare.js" "$FB_PROFILE/$name.out" "$here/expected/$exp" || rc=1
}
run_case x-feed x-feed.html x-feed.js x-feed.json
# fallback check: remove primary text selector, extractor must still work and report the miss
EXPECT_MISS=1 run_case x-feed-fallback x-feed.html x-feed.js x-feed.json \
  "document.querySelectorAll('[data-testid=tweetText]').forEach(e=>e.removeAttribute('data-testid'));new MutationObserver(()=>document.querySelectorAll('[data-testid=tweetText]').forEach(e=>e.removeAttribute('data-testid'))).observe(document.body,{childList:true,subtree:true});"
exit $rc
