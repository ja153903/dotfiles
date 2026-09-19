#!/usr/bin/env bash
# Verifies the ported jimmy skills contain no untranslated Cursor constructs.
# Usage: audit-jimmy.sh [--with-rename]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WITH_RENAME=0
[[ "${1:-}" == "--with-rename" ]] && WITH_RENAME=1

fail=0

# Scans shipped content only. LICENSE-pstack carries upstream provenance by design.
# -I skips binary files. Every text file is scanned regardless of extension: an --include
# allowlist silently misses package.json, bun.lock, and the extensionless watch-pr script.
# The ported skills sit alongside pre-existing personal ones, so scanning $ROOT/skills
# wholesale would flag files this port never touched. .jimmy-manifest names the 45 that
# came from upstream; it is also what makes the skill-count structure check meaningful.
jimmy_dirs() {
  while read -r name; do
    [[ -n "$name" ]] && printf '%s\0' "$ROOT/skills/$name"
  done < "$ROOT/skills/.jimmy-manifest"
  printf '%s\0' "$ROOT/agents"
}
scan() {
  jimmy_dirs | xargs -0 grep -rIEn --exclude-dir=node_modules "$1" 2>/dev/null
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
check "no Cursor mentions"         '\bCursor\b'
check "no /add-plugin"             '/add-plugin'
check "no create-skill"            'create-skill'
check "no agent-transcripts"       'agent-transcripts'
check "no bare script paths"       '(`|^[[:space:]]*[$]?[[:space:]]*)(bun |node |sh |bash )?scripts/[a-z]'
check "no plugin-root variable"    'CLAUDE_PLUGIN_ROOT'

if [[ "$WITH_RENAME" == "1" ]]; then
  echo
  echo "== rename checks =="
  # \b is required: "upstack" is stacked-PR vocabulary, not the vendor name, and a
  # bare 'pstack' substring match demands breaking it. "poteto" needs no boundary.
  check "no pstack identifiers"    '\bpstack\b'
  check "no poteto identifiers"    'poteto'
fi

echo
echo "== structure checks =="
# The ported skills now live alongside personal ones, so a total skill count would conflate
# the two. Count what is unambiguously jimmy's: its playbooks, its role agents, and the
# principle skills the playbooks cross-reference by name.
listed=$(grep -c . "$ROOT/skills/.jimmy-manifest")
missing=0
while read -r name; do
  [[ -n "$name" && ! -f "$ROOT/skills/$name/SKILL.md" ]] && missing=$((missing + 1))
done < "$ROOT/skills/.jimmy-manifest"
plays=$(find "$ROOT/skills" -path '*/playbooks/*.md' 2>/dev/null | wc -l | tr -d ' ')
roles=$(find "$ROOT/agents" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
princ=$(find "$ROOT/skills" -maxdepth 1 -type d -name 'principle-*' 2>/dev/null | wc -l | tr -d ' ')
for pair in "45:$listed:manifest skills" "0:$missing:manifest skills missing SKILL.md" "23:$plays:playbooks" "9:$roles:agents" "21:$princ:principle skills"; do
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
