#!/usr/bin/env bash
# Renders diagram sources under content/ to light and dark SVG files.
#
#   scripts/render-diagrams.sh [--force] [source ...]
#
# Sources are *.mmd (Mermaid) and *.vl.json (Vega-Lite) inside page bundles.
# Each writes rendered/<name>.light.svg and rendered/<name>.dark.svg beside it.
# A source is skipped when it, its theme config and package-lock.json are unchanged.
# Set DIAGRAMS_PUPPETEER_CONFIG to use a custom Puppeteer config; CI uses diagrams/puppeteer-ci.json.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

force=0
if [ "${1:-}" = "--force" ]; then force=1; shift; fi

bin=node_modules/.bin
cache=.cache/diagrams
mkdir -p "$cache/tmp"

if [ ! -x "$bin/mmdc" ]; then
  echo "Dependencies missing: run 'npm ci' first." >&2
  exit 1
fi

pup=()
puppeteer_cfg=${DIAGRAMS_PUPPETEER_CONFIG:-}
if [ -z "$puppeteer_cfg" ] && [ -n "${CI:-}" ]; then puppeteer_cfg=diagrams/puppeteer-ci.json; fi
if [ -n "$puppeteer_cfg" ]; then pup=(-p "$puppeteer_cfg"); fi

sources=()
if [ "$#" -gt 0 ]; then
  for f in "$@"; do sources+=("${f#"$root"/}"); done
else
  while IFS= read -r f; do sources+=("$f"); done < <(find content -type f \( -name '*.mmd' -o -name '*.vl.json' \) | sort)
fi

rendered=0
skipped=0
failed=0

render_one() {
  local src=$1 kind base configs out key sum variant tmp
  case "$src" in
    *.mmd) kind=mermaid; base=$(basename "$src" .mmd); configs="diagrams/mermaid-light.json diagrams/mermaid-dark.json" ;;
    *.vl.json) kind=vega; base=$(basename "$src" .vl.json); configs="diagrams/vega-light.json diagrams/vega-dark.json" ;;
    *) echo "skipped $src: not a diagram source" >&2; return 0 ;;
  esac
  if [ ! -f "$src" ]; then echo "missing $src" >&2; return 1; fi

  out=$(dirname "$src")/rendered
  key=$(printf '%s' "$src" | shasum -a 256 | cut -c1-16)
  # shellcheck disable=SC2086
  sum=$(cat "$src" $configs package-lock.json scripts/diagrams.mjs | shasum -a 256 | cut -c1-64)

  if [ "$force" -eq 0 ] && [ -f "$cache/$key" ] && [ "$(cat "$cache/$key")" = "$sum" ] \
    && [ -f "$out/$base.light.svg" ] && [ -f "$out/$base.dark.svg" ]; then
    skipped=$((skipped + 1))
    return 0
  fi

  mkdir -p "$out"
  for variant in light dark; do
    tmp="$cache/tmp/$key.$variant.svg"
    rm -f "$tmp"
    if [ "$kind" = mermaid ]; then
      "$bin/mmdc" -q -i "$src" -o "$tmp" -c "diagrams/mermaid-$variant.json" -b transparent ${pup[@]+"${pup[@]}"} || return 1
    else
      node scripts/diagrams.mjs vega "$src" "diagrams/vega-$variant.json" "$tmp" || return 1
    fi
    node scripts/diagrams.mjs fit "$tmp" || return 1
    mv "$tmp" "$out/$base.$variant.svg"
  done

  printf '%s' "$sum" > "$cache/$key"
  rendered=$((rendered + 1))
  echo "rendered $src"
}

if [ "${#sources[@]}" -gt 0 ]; then
  for src in "${sources[@]}"; do
    render_one "$src" || { echo "FAILED $src" >&2; failed=$((failed + 1)); }
  done
fi

echo "diagrams: $rendered rendered, $skipped up to date, $failed failed"
[ "$failed" -eq 0 ]
