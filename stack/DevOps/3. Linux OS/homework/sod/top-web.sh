#!/usr/bin/env bash
# HTTP output TOP via ncat

set -euo pipefail

command -v ncat >/dev/null || { echo "no ncat"; exit 1; }

## defaulted port at launch
#
DEF_PORT=8080


## is free?
#
check_port() { ! ss -ltn | awk '{print $4}' | grep -q ":$1$"; }

## port chooser
## if not available, seek another
#
if check_port "$DEF_PORT"; then PORT="$DEF_PORT"; else
  while :; do
    PORT=$((RANDOM % 1990 + 8000))
    check_port "$PORT" && break
  done
fi

echo "TOP on http://localhost:$PORT/ (auto-refresh 10s)"

## http handler
#
HANDLER='
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nCache-Control: no-store\r\n\r\n"
  echo "<!doctype html><meta http-equiv=refresh content=10><title>top</title><pre>"
  top -b -n1 | sed -n "1,50p"
  echo "</pre>"
'

## server initialiser
#
exec ncat -k -l "$PORT" -c "bash -lc '$HANDLER'"

