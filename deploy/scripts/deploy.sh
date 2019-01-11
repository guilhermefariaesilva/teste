#!/bin/bash

# This file is a component of infra, do not run directly
if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  _ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}" )/../../" && pwd)"
fi
cd $_ROOT

set -e

echo "==> build image"
TARGET_IMAGE=gcr.io/$GCLOUD_PROJECT_ID/$DOCKER_IMAGE

_helm_cmd="helm upgrade -i infra-app --namespace default ./deploy"

set -x

# show release informations
# $_helm_cmd --dry-run --debug
# upgrade release
$_helm_cmd --debug
