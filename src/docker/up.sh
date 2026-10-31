#!/usr/bin/env bash
# Bring every Compose stack up with secrets injected from Infisical.
#
# Plain `docker compose up -d` starts containers with empty secrets because the
# values live in Infisical, not in the stack .env files. Running it under
# `infisical run` fills the ${VARS} the compose files reference.
#
# Do not run this under sudo: sudo resets the environment and drops every
# injected variable. The docker group membership is enough.
#
# Usage:
#   ./up.sh                        # start everything
#   ./up.sh --force-recreate       # recreate after a secret or config change
#   ./up.sh down                   # stop everything
set -uo pipefail

cd "$(dirname "$0")"

DOMAIN="${INFISICAL_DOMAIN:-https://secrets.zinkzone.tech}"
ENVIRONMENT="${INFISICAL_ENVIRONMENT:-prod}"

COMMAND=(up -d)
case "${1:-}" in
  up|down|stop|restart|pull)
    COMMAND=("$1")
    shift
    ;;
esac

failed=()

for dir in */; do
  [ -f "${dir}compose.yaml" ] || continue
  name="${dir%/}"

  if (cd "$dir" && infisical run --domain="$DOMAIN" --env="$ENVIRONMENT" -- \
      docker compose "${COMMAND[@]}" "$@"); then
    echo "ok: $name"
  else
    echo "FAILED: $name"
    failed+=("$name")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  echo
  echo "Stacks that failed: ${failed[*]}"
  exit 1
fi
