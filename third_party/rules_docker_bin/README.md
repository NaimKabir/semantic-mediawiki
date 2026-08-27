# Vendored rules_docker helper binaries

`rules_docker` (archived) downloads its `puller`/`loader` helper binaries from
`https://storage.googleapis.com/rules_docker/...`, a GCS bucket that no longer
exists (returns 403). These binaries are built from the `rules_docker` v0.19.0
sources (`container/go/cmd/puller`, `container/go/cmd/loader`) pinned against
`go-containerregistry v0.5.1`, and are wired up in the `WORKSPACE` via
`local_repository` overrides so `container_repositories()` skips its broken
`http_file` definitions.

The darwin binaries are universal (amd64 + arm64); the linux binaries cover
amd64, arm64, and s390x (every platform rules_docker declares a puller/loader
for, since Bazel's analysis phase resolves all of them).

To rebuild: copy the `container/` tree out of the `io_bazel_rules_docker`
external repo, `go mod init && go mod edit -require=github.com/google/go-containerregistry@v0.5.1 && go mod tidy`,
then `go build ./container/go/cmd/puller` / `.../loader` with the desired
`GOOS`/`GOARCH` and `CGO_ENABLED=0`.
