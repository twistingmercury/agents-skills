# Artifact shape: gates, then compile, then a scratch stage that holds only
# the files to export. There is no runtime image.

# Pin the tooling image to version + digest so linter and scanner versions
# cannot drift. Get the digest with `docker buildx imagetools inspect <image>`.
FROM ghcr.io/example-org/go-tooling:go1.27.1@sha256:<digest> AS build

# No packages are installed here. If you add some, install them above these
# lines: BUILD_DATE changes every build and busts the cache of every RUN after it.
ARG BUILD_VER
ARG BUILD_COMMIT
ARG BUILD_DATE

ARG LD_FLAGS="-s -w \
    -X 'example.org/example-tool/internal/version.version=${BUILD_VER}' \
    -X 'example.org/example-tool/internal/version.commit=${BUILD_COMMIT}' \
    -X 'example.org/example-tool/internal/version.date=${BUILD_DATE}'"

WORKDIR /workspace

# Dependencies first, so they stay cached while the source changes.
COPY src/go.mod src/go.sum ./
RUN go mod verify

COPY src/ .

# Quality gates. Any failure stops the build before anything is compiled.
RUN golangci-lint run
RUN govulncheck ./...
RUN gosec ./...
RUN CGO_ENABLED=1 go test -race ./...

# One binary per platform, laid out as <arch>/<os>/<name> in the export.
RUN set -eu; \
    for target in linux/amd64 linux/arm64 darwin/arm64; do \
        os="${target%/*}"; \
        arch="${target#*/}"; \
        CGO_ENABLED=0 GOOS="${os}" GOARCH="${arch}" \
            go build -ldflags "${LD_FLAGS}" -o "/out/${arch}/${os}/example-tool" ./cmd/example-tool; \
    done

# Exception to the build/final naming: nothing here runs. The stage exists so
# `docker build --output type=local` writes only these files to the host.
FROM scratch AS export

COPY --from=build /out/ /
