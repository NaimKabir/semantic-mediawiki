#!/usr/bin/env bash
# Exercise the actual release image, including semantic persistence and HTTP.
set -euo pipefail
image=${1:?Usage: smoke.sh IMAGE [demo]}
mode=${2:-release}
root=$(cd "$(dirname "$0")/../.." && pwd)
container=$(docker run -d "$image")
cleanup() {
    status=$?
    if [ "$status" -ne 0 ]; then docker logs "$container"; fi
    docker rm -f "$container" >/dev/null
}
trap cleanup EXIT
if [ "$mode" = release ]; then
    docker exec "$container" test ! -f LocalSettings.php
    docker cp "$root/container/init-demo.sh" "$container:/tmp/init-demo.sh"
    docker exec "$container" sh /tmp/init-demo.sh
fi
docker exec "$container" composer check-platform-reqs --no-dev
docker exec "$container" php -r '
$e=json_decode(file_get_contents("extensions/SemanticMediaWiki/extension.json"),true);
if ($e["version"] !== getenv("SMW_VERSION") || !extension_loaded("mbstring")) { exit(1); }
echo "SMW ", $e["version"], " on PHP ", PHP_VERSION, "\n";
'
printf '[[Has test value::Registry round trip works]]\n' | \
    docker exec -i "$container" php maintenance/run.php edit --user Admin 'SMW smoke test'
docker exec "$container" php maintenance/run.php runJobs --maxjobs 100
docker cp "$root/container/tests/verify-api.php" "$container:/tmp/verify-api.php"
docker exec "$container" php /tmp/verify-api.php
