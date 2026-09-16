# syntax=docker/dockerfile:1
ARG MEDIAWIKI_IMAGE=mediawiki:1.43.9@sha256:be0ca7ec9565f1e06e3abadf96a3b71bb8402026868342445637f68e55246676
ARG COMPOSER_IMAGE=composer:2.10.3@sha256:aaeab4b6b031e0a88efb907f0f26b563532a644fc2f4ea0d000ecf8658f7a2b8
FROM ${COMPOSER_IMAGE} AS composer
FROM ${MEDIAWIKI_IMAGE} AS smw
ARG SMW_VERSION=7.3.0
# Match the patched Guzzle pin in MediaWiki REL1_43 (remove once bundled).
ARG GUZZLE_VERSION=7.15.2
ENV SMW_VERSION=${SMW_VERSION}
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*
# Keep MediaWiki's dependency constraints and merge SMW through its supported
# composer.local.json mechanism. Explicitly allow the extension installer.
RUN printf '{"require":{"mediawiki/semantic-media-wiki":"%s"}}\n' "$SMW_VERSION" > composer.local.json \
    && COMPOSER_ALLOW_SUPERUSER=1 composer config allow-plugins.composer/installers true \
    && COMPOSER_ALLOW_SUPERUSER=1 composer require --no-update "guzzlehttp/guzzle:${GUZZLE_VERSION}" \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader \
    && composer check-platform-reqs --no-dev \
    && composer audit --no-dev \
    && composer clear-cache \
    && php -r '$e=json_decode(file_get_contents("extensions/SemanticMediaWiki/extension.json"),true); if ($e["version"] !== getenv("SMW_VERSION")) { exit(1); }'

FROM smw AS demo
COPY container/init-demo.sh /usr/local/bin/init-smw-demo
RUN init-smw-demo

# An unqualified docker build produces the unconfigured production image.
FROM smw AS release
