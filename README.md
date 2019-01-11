# Infra-app

An app to apply SRE tests.

## Basic instructions

To run in development, just run:

```sh
docker-compose up
```

```sh
docker-compose build
docker-compose run web ruby -Itest "test/*"
```

## Deployment from local machine

### Starting helm in the server

```sh
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

### Starting helm in the client

```sh
helm init --client-only
```

### Run deploy

NOTE: Get `./credentials/gcloud_service_account.json` from project admin

```sh
docker-compose build web

export GCLOUD_PROJECT_ID=magnetis-gullit-test
export GCLOUD_COMPUTE_ZONE=us-central1-a
export GCLOUD_CLUSTER_NAME=standard-cluster-1
export DOCKER_IMAGE=infra-app_web
export DOCKER_TAG=latest
export GCLOUD_SERVICE_KEY=$(cat ./credentials/gcloud_service_account.json | base64)

./deploy/scripts/deploy.setup.sh
./deploy/scripts/image.sh
./deploy/scripts/deploy.sh
```

NOTE: When the first deploy fail, you will need to remove the release before starting again: `helm delete --purge infra-app`
