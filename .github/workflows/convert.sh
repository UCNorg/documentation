#!/usr/bin/env bash
# convert.sh -- convert files to Markdown using pandoc
# Usage: ./convert.sh [root-dir]
set -euo pipefail

ROOT="${1:-.}"
EXTS=("docx" "odt" "rst" "adoc" "asciidoc" "html" "htm" "txt")
OUT_FMT="gfm"

find "$ROOT" -type f \( $(printf -- '-iname "*.%s" -o ' "${EXTS[@]}" | sed 's/ -o $//') \) -print0 |
while IFS= read -r -d '' file; do
  case "${file,,}" in
    *.md) continue;;
  esac

  ext="${file##*.}"
  ext="${ext,,}"
  out="${file%.*}.md"
  outdir="$(dirname "$out")"

  mkdir -p "$outdir"

  case "$ext" in
    docx) infmt="docx";;
    odt) infmt="odt";;
    rst) infmt="rst";;
    adoc|asciidoc) infmt="asciidoc";;
    html|htm) infmt="html";;
    txt) infmt="plain";;
    *) infmt="auto";;
  esac

  media_dir="${outdir}/media/$(basename "${file%.*}")"
  mkdir -p "$media_dir"

  echo "Converting: $file -> $out (format: $infmt)"
  pandoc --from="$infmt" --to="$OUT_FMT" --standalone --wrap=preserve \
    --extract-media="$media_dir" -o "$out" "$file" || {
      echo "WARNING: pandoc failed for $file"
    }
done

echo "Done."
