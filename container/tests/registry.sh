#!/usr/bin/env bash
# Separate BuildKit and Docker daemons catch layer extraction failures even
# when the host already has the image cached. Requires privileged containers.
set -euo pipefail
cd "$(dirname "$0")/../.."
network="smw-test-$$-$RANDOM"
builder="$network"
registry=''
engine=''
cleanup() {
    docker buildx rm "$builder" >/dev/null 2>&1 || true
    if [ -n "$engine" ]; then docker rm -fv "$engine" >/dev/null; fi
    if [ -n "$registry" ]; then docker rm -fv "$registry" >/dev/null; fi
    docker network rm "$network" >/dev/null
}
docker network create "$network" >/dev/null
trap cleanup EXIT
registry=$(docker run -d --network "$network" --network-alias registry registry:2)
engine=$(docker run -d --privileged --network "$network" -p 127.0.0.1::2375 \
    -e DOCKER_TLS_CERTDIR= docker:29-dind --insecure-registry=registry:5000)
port=$(docker port "$engine" 2375/tcp | awk -F: '{print $NF}')
engine_host="tcp://127.0.0.1:$port"
for attempt in {1..60}; do
    if docker --host "$engine_host" info >/dev/null 2>&1; then break; fi
    if [ "$attempt" -eq 60 ]; then docker logs "$engine"; exit 1; fi
    sleep 1
done
docker buildx create --name "$builder" --driver docker-container --driver-opt "network=$network" >/dev/null
for target in release demo; do
    image="registry:5000/semantic-mediawiki:$target"
    docker buildx build --builder "$builder" --target "$target" \
        --output "type=image,push=true,registry.insecure=true" -t "$image" .
    docker --host "$engine_host" pull "$image"
    (unset DOCKER_CONTEXT; export DOCKER_HOST="$engine_host"; container/tests/smoke.sh "$image" "$target")
done
