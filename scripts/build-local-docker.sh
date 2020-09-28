#!/usr/bin/env bash
set -e

_script_dir=$(dirname "$0")
_grafana_dir="$_script_dir/../."
_container="grafana-build"
_workdir="/usr/local/go/src/grafana/"

function log {
  echo "=======       $(date +%H:%M:%S): $1       ======="
}

function build {
  docker exec -ti -w "$_workdir" "$_container" /bin/bash -c "$1"
}


log "starting build container"
docker run --name "$_container" -d grafana/build-container:1.2.27 sleep inf

log "copying resources into container"
docker cp "$_grafana_dir" "$_container:$_workdir"

log "building backend"
build "go run build.go build"

log "downloading Frontend dependencies"
build "yarn install --pure-lockfile --no-progress"

log "building frontend"
build "yarn run build"

log "packaging Grafana"
build "go run build.go pkg-archive"

log "saving build"
docker cp "$_container:$_workdir/dist" "$_grafana_dir/dist-local-grafana"

exit

log "stopping build container"
docker kill "$_container"
docker rm "$_container"
log "build container stopped"

log "building docker image"
mv $_grafana_dir/dist-local-grafana/grafana*.tar.gz "$_grafana_dir/packaging/docker/grafana-latest.linux-x64.tar.gz"
docker build -f "$_grafana_dir/packaging/docker/ubuntu.Dockerfile" --tag grafana/grafana:dev "$_grafana_dir/packaging/docker/."

log "done"
