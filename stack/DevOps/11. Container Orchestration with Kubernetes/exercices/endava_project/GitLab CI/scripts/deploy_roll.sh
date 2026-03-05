#!/usr/bin/env bash
set -euo pipefail

# configuration

# yaml defaults
NAMESPACE="${NAMESPACE:-petclinic}"
DEPLOYMENT="${DEPLOYMENT:-petclinic}"
CONTAINER="${CONTAINER:-petclinic}"

# NEW_IMAGE = the full container image name (registry + image + version tag) to deploy, e.g. registry.gitlab.com/mygroup/app:v1.2.3
NEW_IMAGE="${NEW_IMAGE:?Set NEW_IMAGE (e.g. gitlab-registry...:smoke1)}"

# base url used by smoke tests (eg localhost via port-forward or an ingress URL)
BASE_URL="${BASE_URL:-http://localhost:8080}"

# local file used to store the previous known-good image, so rollback is possible
STATE_FILE="${STATE_FILE:-.prev_image}"

# capture the currently configured image (for rollback)
# reads the current image from the deployment's Pod template
# filters containers by name to select the correct container in multi-container Pods
prev="$(kubectl -n "$NAMESPACE" get deploy "$DEPLOYMENT" \
  -o jsonpath="{.spec.template.spec.containers[?(@.name=='$CONTAINER')].image}")" # select the one whose .name matches $CONTAINER

# if no image was found, fail early; proceeding would make rollback unsafe
[[ -n "${prev:-}" ]] || { # -n true if non-zero string
  echo "Could not read current image. Check DEPLOYMENT/CONTAINER." >&2
  exit 2
}

# persist the previous image locally so it can be reused later for rollback
echo "$prev" > "$STATE_FILE" # redirect value in file
echo "Saved previous image: $prev"

# deploy the new image and wait for rollout completion
# updates only the chosen container inside the Deployment
kubectl -n "$NAMESPACE" set image deploy/"$DEPLOYMENT" "$CONTAINER=$NEW_IMAGE"

# blocks until the rollout is complete or until the timeout is reached
kubectl -n "$NAMESPACE" rollout status deploy/"$DEPLOYMENT" --timeout=10m

# smoke tests (basic health checks)
# runs a separate smoke test script against BASE_URL.
# returns 0 if healthy
if ./scripts/smoke_test.sh "$BASE_URL"; then
  echo "Deploy done!"
  exit 0
fi

# rollback if smoke tests failed
# revert to the previous image stored in STATE_FILE
echo "Smoke failed. Rolling back to: $(cat "$STATE_FILE")"

# restore the previous image on the Deployment
kubectl -n "$NAMESPACE" set image deploy/"$DEPLOYMENT" "$CONTAINER=$(cat "$STATE_FILE")"

# wait for the rollback rollout to complete
kubectl -n "$NAMESPACE" rollout status deploy/"$DEPLOYMENT" --timeout=10m

# after rollback, re-run smoke tests to confirm the system is healthy again
echo "Re-testing after rollback"
./scripts/smoke_test.sh "$BASE_URL"

# if re-test passes, rollback is confirmed successful, but the overall job is still a failure
# (exit 1) to signal that the new image was not acceptable
echo "Rollback restored working version (but deploy considered failed)"
exit 1