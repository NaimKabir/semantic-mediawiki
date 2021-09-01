# NOTE: This requires pinning .bazelversion to 3.5.0 because of: https://github.com/bazelbuild/rules_docker/issues/1716
# TODO: Unpin when that issue is closed.

workspace(
    name = "semantic-mediawiki",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Docker rules
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "95d39fd84ff4474babaf190450ee034d958202043e366b9fc38f438c9e6c3334",
    strip_prefix = "rules_docker-0.16.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.16.0/rules_docker-v0.16.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("@io_bazel_rules_docker//container:container.bzl", "container_pull")


# Pull MediaWiki base container

container_pull(
    name = "mediawiki",
    registry = "index.docker.io",
    repository = "library/mediawiki",
    digest = "sha256:944d0c01466de418d57e0a0182f1b30a22872050f7383f8ce541701828336110" # mediawiki:latest
)

