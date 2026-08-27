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
    # Make container_run_and_commit work with Docker's containerd image store,
    # where loaded images are not addressable by their config digest.
    patches = ["//third_party:rules_docker_containerd_store.patch"],
    patch_args = ["-p1"],
)

# rules_docker is archived and the GCS bucket it downloads its prebuilt
# puller/loader helper binaries from (storage.googleapis.com/rules_docker)
# is gone (403). Declaring these repositories before container_repositories()
# makes it skip its own (broken) http_file definitions, using our vendored
# binaries instead. See third_party/rules_docker_bin/README.md.
local_repository(
    name = "go_puller_darwin",
    path = "third_party/rules_docker_bin/go_puller_darwin",
)

local_repository(
    name = "go_puller_linux_amd64",
    path = "third_party/rules_docker_bin/go_puller_linux_amd64",
)

local_repository(
    name = "go_puller_linux_arm64",
    path = "third_party/rules_docker_bin/go_puller_linux_arm64",
)

local_repository(
    name = "go_puller_linux_s390x",
    path = "third_party/rules_docker_bin/go_puller_linux_s390x",
)

local_repository(
    name = "loader_darwin",
    path = "third_party/rules_docker_bin/loader_darwin",
)

local_repository(
    name = "loader_linux_amd64",
    path = "third_party/rules_docker_bin/loader_linux_amd64",
)

local_repository(
    name = "loader_linux_arm64",
    path = "third_party/rules_docker_bin/loader_linux_arm64",
)

local_repository(
    name = "loader_linux_s390x",
    path = "third_party/rules_docker_bin/loader_linux_s390x",
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("@io_bazel_rules_docker//container:container.bzl", "container_pull")


# Pull MediaWiki base container.
# NOTE: This must be pinned to a particular release to satisfy Semantic MediaWiki compatibility, see:
# https://www.semantic-mediawiki.org/wiki/Help:Compatibility

container_pull(
    name = "mediawiki-linux-amd64",
    registry = "index.docker.io",
    repository = "library/mediawiki",
    digest = "sha256:c4f5d7dcccfbf22204f05fadb8e08515dccd8bd97ed854d77e64f25e5cc21d6e" # mediawiki:1.46.0, linux/amd64
)

