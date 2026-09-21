# Semantic MediaWiki Docker Images

[![deploy](https://github.com/NaimKabir/semantic-mediawiki/actions/workflows/deploy.yaml/badge.svg)](https://github.com/NaimKabir/semantic-mediawiki/actions/workflows/deploy.yaml)

Docker images with MediaWiki and Semantic MediaWiki (SMW) pre-installed. The current build targets **SMW 7.3.0**, **MediaWiki 1.43.9 LTS**, and **PHP 8.3**, for Linux AMD64 and ARM64.

Images are published to [Docker Hub](https://hub.docker.com/r/naimkabir/semantic-mediawiki). Report problems in [GitHub issues](https://github.com/NaimKabir/semantic-mediawiki/issues).

## Run a wiki

After the release workflow publishes this version:

```sh
docker pull naimkabir/semantic-mediawiki:7.3.0
docker run --name smw -d -p 8080:80 naimkabir/semantic-mediawiki:7.3.0
```

1. Open `http://localhost:8080` and complete the MediaWiki installer, or supply your existing `LocalSettings.php`. Use persistent storage for your database and uploads; the release image does not contain a configured wiki or database.
2. Add this line to `LocalSettings.php` (SMW 7 enables semantics when the extension loads):

   ```php
   wfLoadExtension('SemanticMediaWiki');
   ```

3. Copy the configuration into the container and update the schema:

   ```sh
   docker cp LocalSettings.php smw:/var/www/html/LocalSettings.php
   docker exec smw php maintenance/run.php update --quick
   ```

4. Check `Special:Version` and `Special:SemanticMediaWiki`.

For upgrades, back up your database, configuration, and uploads, and follow the [SMW release notes](https://github.com/SemanticMediaWiki/SemanticMediaWiki/blob/7.3.0/docs/releasenotes/RELEASE-NOTES-7.3.0.md) and [MediaWiki upgrade instructions](https://www.mediawiki.org/wiki/Manual:Upgrading). Wikis using URL, Annotation URI, or Email properties should run `php maintenance/run.php SemanticMediaWiki:rebuildData` after upgrading to SMW 7.3.0.

## Try the demo

```sh
docker run --name smw-demo -d -p 127.0.0.1:8080:80 naimkabir/semantic-mediawiki:7.3.0-demo
```

Open `http://localhost:8080`. Login: **Admin / smw-demo-password**. This disposable SQLite demo has a public password and a fixed localhost URL; use it only for local evaluation. Its database is inside the container and is lost when the container is removed.

## Build and test locally

Docker with BuildKit/buildx is required. The registry regression test also needs permission to run privileged Docker-in-Docker containers. No Bazel or Python packages are needed.

```sh
docker build --target release -t smw:local .
container/tests/smoke.sh smw:local

# Optional preconfigured demo:
docker build --target demo -t smw:demo .
container/tests/smoke.sh smw:demo demo

# Full packaging regression test (starts a temporary local registry):
container/tests/registry.sh
```

The smoke test installs a temporary SQLite wiki, loads SMW, updates the database, saves a semantic annotation, runs jobs, and queries it through the HTTP API. It removes its test container when finished. The registry test builds and pushes both targets with an isolated BuildKit builder, pulls them into a fresh Docker-in-Docker daemon, and runs the smoke test against each pulled image. The separate image stores ensure cached layers cannot hide extraction failures; all temporary containers, volumes, and networks are removed afterward. CI runs this on native AMD64 and ARM64 runners.

## Update and publish

Edit the version arguments in `Dockerfile`. Pin base images to their multi-platform index digests, and choose a MediaWiki version supported by the [SMW compatibility matrix](https://github.com/SemanticMediaWiki/SemanticMediaWiki/blob/7.3.0/docs/COMPATIBILITY.md). Run the registry test and update these instructions.

The build also updates Guzzle to 7.15.2, matching the patched pin on MediaWiki’s `REL1_43` maintenance branch, and fails if `composer audit --no-dev` reports vulnerable production dependencies. Revisit that override when updating MediaWiki.

Branch pushes and pull requests run the tests, including on subsequent commits. Pushes to `main` (or a manual deployment workflow run) test first, then publish the version tag and `latest`, plus the versioned demo tag and `demo`. The workflow uses the existing `DOCKER_HUB_USERNAME` and `DOCKER_HUB_ACCESS_TOKEN` secrets. The SMW tag comes directly from `Dockerfile`.

### Why the build changed

The old `rules_docker` path depended on unavailable helpers and could publish gzip-compressed layers labeled as uncompressed OCI tar layers. Docker rejected the published `7.2.1` image with `archive/tar: invalid tar header`; the old `latest` tag still contained SMW 4.0.0. Native BuildKit now builds and publishes images without converting `docker save` archives through the archived Bazel rules. The registry round-trip test guards against that packaging regression.
