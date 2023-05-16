#!/bin/bash

set -e

mkdir ~/.k
git clone $GITOPS_REPOSITORY_URL ~/.k/default
git -C ~/.k/default config user.name "k-action"
git -C ~/.k/default config user.email "k-action@reclaim-the-stack.com"

if ! command -v kubectl; then
  wget -q -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
fi

mkdir -p $HOME/.kube
echo $KUBE_CONFIG | base64 -d > $HOME/.kube/config
KUBE_CONTEXT=${KUBE_CONTEXT:-$(kubectl config current-context)}

if ! command -v kubeseal; then
  wget -q -O - https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.5/kubeseal-0.20.5-linux-amd64.tar.gz | tar xvz -C /usr/local/bin/ kubeseal
  chmod +x /usr/local/bin/kubeseal
fi

if ! command -v kail; then
  wget -q -O - https://github.com/boz/kail/releases/download/v0.16.1/kail_v0.16.1_linux_amd64.tar.gz | tar xvz -C /usr/local/bin kail
  chmod +x /usr/local/bin/kail
fi

if ! command -v k; then
  wget -q -O /usr/local/bin/k https://raw.githubusercontent.com/reclaim-the-stack/k/master/k
  chmod +x /usr/local/bin/k
fi

if [ -z "$REGISTRY" ]; then
  # default to the first registry of the current docker context or fall back to docker.io
  REGISTRY=$(jq -r '.auths | keys[0]' ~/.docker/config.json || echo 'docker.io')
  REGISTRY=${REGISTRY:-docker.io}
fi

if [ -z $GITHUB_ORGANIZATION ]; then
  # default to the github organization of current git repository
  GITHUB_ORGANIZATION=$(git -C ~/.k/default config --get remote.origin.url | sed -n 's/.*github.com[:/]\(.*\)\/.*/\1/p')
fi

cat << EOF > ~/.k/config
context: default
contexts:
  default:
    repository: $GITOPS_REPOSITORY_URL
    registry: $REGISTRY
    registry_namespace: $REGISTRY_NAMESPACE
    github_organization: $GITHUB_ORGANIZATION
    kubectl_context: $KUBE_CONTEXT
EOF
