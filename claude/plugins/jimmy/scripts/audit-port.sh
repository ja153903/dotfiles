#!/usr/bin/env bash
# Verifies the jimmy plugin contains no untranslated Cursor constructs.
# Usage: audit-port.sh [--with-rename]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_RENAME=0
[[ "${1:-}" == "--with-rename" ]] && WITH_RENAME=1

fail=0

# Scans shipped content only. LICENSE and README carry upstream provenance by design.
# -I skips binary files (the guide's .jpg images). Every text file is scanned regardless
# of extension: an --include allowlist silently misses package.json, bun.lock,
# configuration.example.yaml, and the extensionless watch-pr script.
scan() {
  grep -rIEn "$1" \
    "$ROOT/skills" "$ROOT/agents" "$ROOT/automations" "$ROOT/docs" \
    2>/dev/null
}

check() {
  local label="$1" pattern="$2" hits
  hits="$(scan "$pattern")"
  if [[ -n "$hits" ]]; then
    printf 'FAIL  %s\n' "$label"
    sed 's/^/      /' <<<"$hits"
    printf '\n'
    fail=1
  else
    printf 'ok    %s\n' "$label"
  fi
}

echo "== translation checks =="
check "no Cursor Task tool"        '`Task` call|Task tool|`Task`s|three `Task`'
check "no generalPurpose"          'generalPurpose'
check "no AskQuestion"             '(^|[^r])\bAskQuestion\b'
check "no environment: cloud/local" 'environment: "(cloud|local)"'
check "no cloud_base_branch"       'cloud_base_branch'
check "no Cursor readonly param"   '`readonly`: |readonly: `(true|false)`'
check "no inherit-parent alias"    'inherit-parent'
check "no .cursor paths"           '\.cursor/'
check "no pstack-models.mdc"       'pstack-models\.mdc'
check "no Cursor model slugs"      'grok-[0-9]|gpt-[0-9]+\.[0-9]+-sol|claude-fable-5-1-thinking|claude-opus-5-thinking'
check "no Bugbot"                  '[Bb]ugbot'
check "no /add-plugin"             '/add-plugin'

if [[ "$WITH_RENAME" == "1" ]]; then
  echo
  echo "== rename checks =="
  check "no pstack identifiers"    'pstack'
  check "no poteto identifiers"    'poteto'
fi

echo
echo "== structure checks =="
skills=$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
plays=$(find "$ROOT/skills" -path '*/playbooks/*.md' 2>/dev/null | wc -l | tr -d ' ')
for pair in "45:$skills:skill directories" "23:$plays:playbooks"; do
  want="${pair%%:*}"; rest="${pair#*:}"; got="${rest%%:*}"; what="${rest#*:}"
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %s (%s)\n' "$what" "$got"
  else
    printf 'FAIL  %s: expected %s, found %s\n' "$what" "$want" "$got"
    fail=1
  fi
done

echo
[[ "$fail" == "0" ]] && echo "AUDIT PASS" || echo "AUDIT FAIL"
exit "$fail"
