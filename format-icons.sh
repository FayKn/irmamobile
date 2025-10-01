#!/usr/bin/env sh
set -eu

inPath="${1:-assets/simple-icons/data/simple-icons.json}"
outPath="${2:-assets/simple-icons/data/simple-icons-fmt.json}"

if [ ! -f "$inPath" ]; then
  printf '%s\n' "Input file not found: $inPath" >&2

  printf 'Updating git submodules...\n'
  command git submodule update || {
    printf '%s\n' "Failed to update git submodules" >&2
    exit 1
  }

  if [ ! -f "$inPath" ]; then
    printf '%s\n' "Input file still not found: $inPath" >&2 'Did you already run this script?'
    exit 1
  fi
fi

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' "jq is required but not found" >&2
  exit 1
fi

printf 'Processing %s to %s\n' "$inPath" "$outPath"
jq '
  map(select(.title != null) |
    { ( .title
        | ascii_downcase
        | gsub("^[[:space:]]+|[[:space:]]+$"; "")
      ): .hex
    }
  ) | add // {}
' "$inPath" > "$outPath"

printf 'Wrote %s\n' "$outPath"

rm -f "$inPath"
printf 'Removed %s\n' "$inPath"

rm -f simple-icons.d.ts
printf 'Removed %s\n' "simple-icons.d.ts"
