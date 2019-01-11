#!/bin/bash

# This file is a component of infra, do not run directly
if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  _ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}" )/../../" && pwd)"
fi

command_exists() {
  type "$1" &>/dev/null
}

install_gcloud() {
	export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
	echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	apt-get update -y && apt-get install google-cloud-sdk -y
}

install_helm() {
	HELM_VERSION="v2.12.1"

	wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm
	chmod +x /usr/local/bin/helm
}

cd $_ROOT

set -e

# echo "==> Install dependencies"

# apk add --no-cache \
# 	--repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
# 	openssh coreutils ncurses docker bash ca-certificates git

echo "==> Install gcloud sdk"

if ! command_exists gcloud; then
	install_gcloud
fi

echo "==> Authenticate with Google Service Account"

tmp_gcloud_service_key_json=/tmp/gcloud-service-key.json

if [[ -n "$GCLOUD_SERVICE_KEY" ]]; then
	echo $GCLOUD_SERVICE_KEY | base64 --decode > "$tmp_gcloud_service_key_json"
elif [[ -n "$GOOGLE_JSON_FILE" ]]; then
	echo $GOOGLE_JSON_FILE > "$tmp_gcloud_service_key_json"
else
	echo "Required 'GCLOUD_SERVICE_KEY' or 'GOOGLE_JSON_FILE' env"
	exit 1
fi

gcloud auth activate-service-account --key-file "$tmp_gcloud_service_key_json"

gcloud config set project ${GCLOUD_PROJECT_ID}
gcloud config set compute/zone ${GCLOUD_COMPUTE_ZONE}

echo "==> Install kubectl"
gcloud --quiet components install kubectl
gcloud container clusters get-credentials ${GCLOUD_CLUSTER_NAME}

echo "==> Install Helm"

if ! command_exists helm; then
	install_helm
fi
