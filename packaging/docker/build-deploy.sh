#!/bin/sh
set -e

OPT=""
UBUNTU_BASE=0
ENTERPRISE=0
REPO="grafana/grafana"

while [ "$1" != "" ]; do
  case "$1" in
    "--ubuntu")
      OPT="${OPT} --ubuntu"
      UBUNTU_BASE=1
      echo "Ubuntu base image enabled"
      shift
      ;;
    "--enterprise")
      ENTERPRISE=1
      REPO="grafana/grafana-enterprise"
      echo "Enterprise enabled"
      shift
      ;;
    * )
      # unknown param causes args to be passed through to $@
      break
      ;;
  esac
done

_grafana_version=$1
./build.sh ${OPT} "$_grafana_version" "$REPO"


echo NOT PUSHING ANYTHING, REMOVE THIS WHEN READY
exit
docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"

./push_to_docker_hub.sh ${OPT} "$_grafana_version"

if [ ${UBUNTU_BASE} = "0" ] && [ ${ENTERPRISE} = "0" ]; then
  if echo "$_grafana_version" | grep -q "^master-"; then
    ./deploy_to_k8s.sh "grafana/grafana-dev:$_grafana_version"
  fi
fi
