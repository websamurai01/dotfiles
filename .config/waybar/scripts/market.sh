#!/usr/bin/env bash
# Market tickers for Waybar: bitcoin, S&P 500 and the crypto Fear and Greed index.
# Each mode prints one Waybar JSON line:
#   {"text": "₿ 96123 (+1.21%)", "class": "up", "tooltip": "..."}
# The class "up" or "down" comes from the change since 00:00 UTC. style.css sets the color.
# When a request fails, the last good line is printed again. The bar does not flicker.
#
# usage: market.sh btc|spx|fng|--check

set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-market"
mkdir -p "$CACHE_DIR"
UA="Mozilla/5.0 (waybar)"

# Print "<signed percent> <class>".
delta() {
  awk -v b="$1" -v c="$2" 'BEGIN {
    if (b <= 0) { print "+0.00 flat"; exit }
    p = (c - b) / b * 100
    cls = (p > 0) ? "up" : (p < 0 ? "down" : "flat")
    printf "%+.2f %s\n", p, cls
  }'
}

# Print "<signed points> <class>". The Fear and Greed index has no percent change.
diff() {
  awk -v b="$1" -v c="$2" 'BEGIN {
    d = c - b
    cls = (d > 0) ? "up" : (d < 0 ? "down" : "flat")
    printf "%+.0f %s\n", d, cls
  }'
}

# Print one JSON line and keep it as the last good output.
emit() {  # emit <module> <text> <class> <tooltip>
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$2" "$3" "$4" | tee "$CACHE_DIR/$1.json"
}

# Print the last good line when the request fails. Else print a placeholder.
fallback() {  # fallback <module> <placeholder>
  if [ -s "$CACHE_DIR/$1.json" ]; then
    cat "$CACHE_DIR/$1.json"
  else
    printf '{"text":"%s","class":"flat","tooltip":"no data"}\n' "$2"
  fi
}

btc() {
  local resp price base pct cls text

  # Kraken gives the last price and the 00:00 UTC price in one answer. It needs no API key.
  resp=$(curl -s --max-time 4 -A "$UA" 'https://api.kraken.com/0/public/Ticker?pair=XBTUSD') || return 1
  read -r price base < <(printf '%s' "$resp" | jq -r '.result | to_entries[0].value | "\(.c[0]) \(.o)"')
  [ -n "$price" ] && [ "$price" != "null" ] || return 1

  printf -v price '%.0f' "$price"
  if [ -n "$base" ]; then
    read -r pct cls < <(delta "$base" "$price")
    text="₿ $price ($pct%)"
  else
    text="₿ $price"
    cls="flat"
  fi
  emit btc "$text" "$cls" "Bitcoin since 00:00 UTC"
}

spx() {
  local resp base price pct cls text

  resp=$(curl -s --max-time 5 -A "$UA" \
    'https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC?interval=1d&range=5d') || return 1

  # The index does not trade at 00:00 UTC, so the base is the close before the last one.
  read -r base price < <(printf '%s' "$resp" | jq -r '
    .chart.result[0].indicators.quote[0].close
    | map(select(. != null)) | "\(.[-2]) \(.[-1])"')
  [ -n "$price" ] && [ "$price" != "null" ] || return 1

  printf -v price '%.0f' "$price"
  if [ -n "$base" ] && [ "$base" != "null" ]; then
    read -r pct cls < <(delta "$base" "$price")
    text="S&P $price ($pct%)"
  else
    text="S&P $price"
    cls="flat"
  fi
  emit spx "$text" "$cls" "S&P 500 since the last close"
}

fng() {
  local resp today prev label d cls

  resp=$(curl -s --max-time 5 -A "$UA" 'https://api.alternative.me/fng/?limit=2') || return 1
  read -r today prev label < <(printf '%s' "$resp" | jq -r '
    .data | "\(.[0].value) \(.[1].value // .[0].value) \(.[0].value_classification)"')
  [ -n "${today:-}" ] || return 1

  read -r d cls < <(diff "$prev" "$today")
  emit fng "F&G $today ($d)" "$cls" "$label"
}

# Small self-check of the number logic. No network.
check() {
  local bad=0 got
  expect() { [ "$2" = "$3" ] || { echo "$1: want '$3', got '$2'"; bad=1; }; }
  expect "delta up"    "$(delta 100 101)" "+1.00 up"
  expect "delta down"  "$(delta 100 99)"  "-1.00 down"
  expect "delta flat"  "$(delta 100 100)" "+0.00 flat"
  expect "delta zero"  "$(delta 0 5)"     "+0.00 flat"
  expect "diff up"     "$(diff 10 12)"    "+2 up"
  expect "diff down"   "$(diff 12 11)"    "-1 down"
  [ "$bad" = 0 ] && echo ok || exit 1
}

case "${1:-}" in
  btc) btc || fallback btc "₿ …" ;;
  spx) spx || fallback spx "S&P …" ;;
  fng) fng || fallback fng "F&G …" ;;
  --check) check ;;
  *) echo "usage: $0 btc|spx|fng|--check" >&2; exit 2 ;;
esac
