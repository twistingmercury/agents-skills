# Image shape: gates, then cross-compile natively, then a scratch runtime stage.

# Pin the tooling image to version + digest so linter and scanner versions
# cannot drift. Get the digest with `docker buildx imagetools inspect <image>`.
# Running the build stage on the builder's own platform avoids emulation; Go
# cross-compiles for the target.
FROM --platform=${BUILDPLATFORM} ghcr.io/example-org/go-tooling:go1.27.1@sha256:<digest> AS build

ARG TARGETOS
ARG TARGETARCH

# No packages are installed here. If you add some, install them above these
# lines: BUILD_DATE changes every build and busts the cache of every RUN after it.
ARG BUILD_VER
ARG BUILD_COMMIT
ARG BUILD_DATE

ARG LD_FLAGS="-s -w \
    -X 'example.org/example-service/internal/version.version=${BUILD_VER}' \
    -X 'example.org/example-service/internal/version.commit=${BUILD_COMMIT}' \
    -X 'example.org/example-service/internal/version.date=${BUILD_DATE}'"

WORKDIR /workspace

COPY src/go.mod src/go.sum ./
RUN go mod verify

COPY src/ .

# Quality gates. Any failure stops the build before anything is compiled.
RUN golangci-lint run
RUN govulncheck ./...
RUN gosec ./...
RUN CGO_ENABLED=1 go test -race ./...

RUN CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
    go build -ldflags "${LD_FLAGS}" -o /out/example-service ./cmd/example-service

FROM scratch AS final

ARG BUILD_VER
ARG BUILD_COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="example-service" \
    org.opencontainers.image.source="https://github.com/example-org/example-service" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.version="${BUILD_VER}" \
    org.opencontainers.image.revision="${BUILD_COMMIT}" \
    org.opencontainers.image.created="${BUILD_DATE}"

# TLS needs the CA bundle; scratch has none of its own.
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /out/example-service /example-service
COPY LICENSE /licenses/LICENSE

# Settings are supplied at run time; no values are baked into the image.
ENV EXAMPLE_DATABASE_URL=""

# Numeric, because scratch has no /etc/passwd to resolve a name.
USER 65532:65532

EXPOSE 8080

# scratch has no curl or shell, so the binary checks itself.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/example-service", "--health"]

ENTRYPOINT ["/example-service"]
