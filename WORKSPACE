workspace(
    name = "semantic-mediawiki",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Docker rules
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "1f4e59843b61981a96835dc4ac377ad4da9f8c334ebe5e0bb3f58f80c09735f4",
    strip_prefix = "rules_docker-0.19.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.19.0/rules_docker-v0.19.0.tar.gz"],
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

