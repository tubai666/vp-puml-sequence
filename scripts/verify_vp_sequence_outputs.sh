#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  printf 'Usage: %s PROJECT_VPP PNG_DIR SVG_DIR EXPECTED_COUNT [KEY_TEXT ...]\n' "$0" >&2
  exit 2
fi

PROJECT_VPP=$1
PNG_DIR=$2
SVG_DIR=$3
EXPECTED_COUNT=$4
shift 4

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -f "$PROJECT_VPP" ]] || fail "Project not found: $PROJECT_VPP"
[[ -d "$PNG_DIR" ]] || fail "PNG directory not found: $PNG_DIR"
[[ -d "$SVG_DIR" ]] || fail "SVG directory not found: $SVG_DIR"

diagram_count=$(sqlite3 "$PROJECT_VPP" "select count(*) from DIAGRAM where DIAGRAM_TYPE='InteractionDiagram';")
[[ "$diagram_count" == "$EXPECTED_COUNT" ]] || fail "Expected $EXPECTED_COUNT InteractionDiagram rows, got $diagram_count"

png_count=$(find "$PNG_DIR" -type f -name '*.png' | wc -l | tr -d ' ')
svg_count=$(find "$SVG_DIR" -type f -name '*.svg' | wc -l | tr -d ' ')
[[ "$png_count" == "$EXPECTED_COUNT" ]] || fail "Expected $EXPECTED_COUNT PNG files, got $png_count"
[[ "$svg_count" == "$EXPECTED_COUNT" ]] || fail "Expected $EXPECTED_COUNT SVG files, got $svg_count"

nested_hits=$(perl -0ne '$c += () = /\b1\.1/g; END { print $c + 0 }' "$SVG_DIR"/*.svg)
[[ "$nested_hits" == "0" ]] || fail "Found $nested_hits nested numbering hits like 1.1 in SVG exports"

for key_text in "$@"; do
  escaped_key_text=${key_text//\'/\'\'}
  hits=$(sqlite3 "$PROJECT_VPP" "select count(*) from MODEL_ELEMENT where DEFINITION like '%$escaped_key_text%';")
  [[ "$hits" != "0" ]] || fail "Key text not found in VPP model: $key_text"
done

if ps -axo command | grep -E 'com\.vp\.cmd\.Plugin|ExportDiagramImage|Visual Paradigm\.app/Contents/Resources/jre' | grep -v grep >/dev/null; then
  fail "VP command-line process still running"
fi

printf 'OK: %s InteractionDiagram, %s PNG, %s SVG, no nested numbering hits\n' "$diagram_count" "$png_count" "$svg_count"
