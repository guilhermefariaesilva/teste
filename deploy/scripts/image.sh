#!/bin/bash

# This file is a component of infra, do not run directly
if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  _ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}" )/../../" && pwd)"
fi
cd $_ROOT

set -e

echo "==> build image"
TARGET_IMAGE=gcr.io/$GCLOUD_PROJECT_ID/$DOCKER_IMAGE

echo "==> Push image '$TARGET_IMAGE'"

set -x
docker tag "$DOCKER_IMAGE:$DOCKER_TAG" "$TARGET_IMAGE:latest"
docker push "$TARGET_IMAGE:latest"
