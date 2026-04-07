#!/usr/bin/env bash
set -euo pipefail # exit on error (-e), unset vars are errors (-u), pipelines fail if any part fails (pipefail)

BASE_URL="${1:?Usage: $0 <base_url>}" # first arg is required; if missing, show usage and exit
ENDPOINTS_FILE="${2:-scripts/smoke-endpoints.txt}" # second arg optional: file with endpoints

SMOKE_TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-5}"  # curl timeout per try
SMOKE_RETRIES="${SMOKE_RETRIES:-30}" # how many tries per endpoint
SMOKE_SLEEP_SECONDS="${SMOKE_SLEEP_SECONDS:-2}" # wait between tries

mapfile -t endpoints < <(grep -vE '^\s*#|^\s*$' "$ENDPOINTS_FILE")
# mapfile        -> read lines from stdin into an array (one line per element)
# -t             -> strip trailing newline from each stored line
# endpoints      -> name of the array being populated

# <              -> redirect stdin for mapfile
# <( ... )       -> process substitution (run command and treat its output like a file)

# grep           -> filter lines from the input file
# -E             -> use extended regex (allows | for OR)
# -v             -> invert match (keep lines that do NOT match the pattern)

# '^\s*#|^\s*$'  -> regex for lines to exclude:
#   ^\s*#        -> lines starting with optional whitespace then '#'(comments)
#   |            -> OR
#   ^\s*$        -> blank or whitespace-only lines

# "$ENDPOINTS_FILE" -> the file being read

for ep in "${endpoints[@]}"; do # loop over each endpoint path from the file (eg. /health, /ready) | [@] expands to each array element as its own word.
  url="${BASE_URL%/}${ep}" # build full url: remove ONE trailing '/' from base_url, then append endpoint
  echo "checking $url"
  ok="false" # assume failure until there is a successful response on curl

  for ((i=1; i<=SMOKE_RETRIES; i++)); do # retry loop: keep trying the same url up to SMOKE_RETRIES times
    if curl -fsS --max-time "$SMOKE_TIMEOUT_SECONDS" "$url" >/dev/null; then  # curl: fail on http errors (-f), silent (no output spam) (-s) but show errors (-S), stop after timeout; ignore body (ignore response content)
      ok="true" # mark this endpoint as healthy
      break
    fi
    sleep "$SMOKE_SLEEP_SECONDS"
  done

  [[ "$ok" == "true" ]] || { echo "failed: $url" >&2; exit 1; } # if still not ok after given retries, print to stderr and fail the script
done

echo "Smoke tests passed"
