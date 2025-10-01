#!/usr/bin/env sh
set -eu

inPath="${1:-assets/simple-icons/data/simple-icons.json}"
outPath="${2:-assets/simple-icons/data/simple-icons-fmt.json}"

if [ ! -f "$inPath" ]; then
  echo "Input file not found: $inPath, maybe update git submodules?" >&2
  exit 1
fi

echo "Processing $inPath to $outPath..."

jq '
  map(select(.title != null) |
    { ( .title
        | ascii_downcase
        | gsub("^[[:space:]]+|[[:space:]]+$"; "")
      ): .hex
    }
  ) | add // {}
' "$inPath" > "$outPath"

echo "Wrote $outPath"

rm -f "$inPath"
echo "Removed $inPath"

rm -f simple-icons.d.ts
echo "Removed simple-icons.d.ts"
