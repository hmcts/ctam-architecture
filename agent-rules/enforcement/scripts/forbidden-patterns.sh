#!/usr/bin/env bash
# Scans what Checkstyle and ArchUnit cannot see — YAML, SQL, Helm values, build files, and the
# text of log statements. Copy to scripts/forbidden-patterns.sh; wired into `check` by
# gradle/ctam-quality.gradle.
#
# Every pattern maps to a numbered rule. This is a coarse text scan by design: it is the last
# line of defence, not the first. A hit is a rule breach; fix the code, never the pattern (R9).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

violations=0

# scan <rule-id> <description> <extended-regex> <path...>
scan() {
  local rule="$1" desc="$2" pattern="$3"
  shift 3
  local hits
  hits=$(grep -rnIE --exclude-dir=build --exclude-dir=.git --exclude-dir=node_modules \
           --exclude-dir=generated "$pattern" "$@" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    printf '\n\033[31m%s violation — %s\033[0m\n' "$rule" "$desc"
    printf '%s\n' "$hits"
    violations=$((violations + 1))
  fi
}

SRC=(src)
[ -d helm ] && SRC+=(helm)
[ -d terraform ] && SRC+=(terraform)

# ---- S1/S2: sensitive values in log statements -----------------------------------------
scan "S1" "personal data or credentials in a log statement" \
  'log(ger)?\.(trace|debug|info|warn|error)\(.*(payrollNumber|personnelNumber|firstName|lastName|surname|dateOfBirth|nationalInsurance|sortCode|accountNumber|iban|bankAccount|Authorization|bearer|jwt|token|password|secret)' \
  "${SRC[@]}"

scan "S2" "concatenation in a log statement (use placeholders; whole objects leak fields)" \
  'log(ger)?\.(trace|debug|info|warn|error)\(\s*"[^"]*"\s*\+' \
  "${SRC[@]}"

# ---- S6/S7: secrets in configuration ---------------------------------------------------
CONFIG_PATHS=(src/main/resources)
[ -d helm ] && CONFIG_PATHS+=(helm)
scan "S6" "literal secret in configuration (use Azure Key Vault)" \
  '^[[:space:]]*(password|client-secret|clientSecret|api-key|apiKey|secret|connection-string)[[:space:]]*:[[:space:]]*[^$#[:space:]].*' \
  "${CONFIG_PATHS[@]}"

# ---- P1: Flyway is prohibited; Liquibase is the CTAM standard ---------------------------
scan "P1" "Flyway reference (CTAM standardises on Liquibase)" \
  '(flyway|Flyway)' \
  "${SRC[@]}" build.gradle

# ---- P6: no in-memory database substitutes ---------------------------------------------
scan "P6" "in-memory database substitute (integration tests use Testcontainers PostgreSQL)" \
  '(com\.h2database|org\.hsqldb|jdbc:h2:|jdbc:hsqldb:|apache\.derby)' \
  "${SRC[@]}" build.gradle

# ---- P7: the changelog is the only thing that changes the schema -----------------------
scan "P7" "ddl-auto value that mutates the schema" \
  'ddl-auto[[:space:]]*:[[:space:]]*(create|create-drop|update)' \
  src

# ---- S12: mock auth must never be reachable from production ----------------------------
scan "S12" "mock-auth reference outside a dev/test profile" \
  '(mock-auth|mock_oauth_clients|mock_user_roster)' \
  src/main/resources/application.yml src/main/resources/application-production.yml \
  src/main/resources/application-staging.yml

# ---- S14: no unpinned or pre-release dependencies --------------------------------------
scan "S14" "SNAPSHOT, release-candidate or milestone dependency version" \
  '(SNAPSHOT|-RC[0-9]|-M[0-9]|\+["'"'"']?$)' \
  build.gradle

# ---- S8: TLS verification is never disabled --------------------------------------------
scan "S8" "TLS verification disabled" \
  '(trustAll|TrustAllCerts|insecureSkipVerify|verify[[:space:]]*=[[:space:]]*false|sslVerify[[:space:]]*:[[:space:]]*false)' \
  "${SRC[@]}"

if [ "$violations" -gt 0 ]; then
  printf '\n\033[31m%d forbidden-pattern rule(s) violated.\033[0m\n' "$violations"
  printf 'These are absolute rules. Fix the code — do not edit this script (R9).\n'
  exit 1
fi

printf 'forbidden-patterns: clean\n'
