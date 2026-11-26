ARG CADDY_VERSION=2.11.9

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder
ARG CADDY_VERSION

RUN xcaddy build "v${CADDY_VERSION}" \
    --output /usr/bin/caddy \
    --with github.com/mholt/caddy-l4@v0.1.3 \
    --with github.com/caddy-dns/cloudflare@v0.2.4

FROM caddy:${CADDY_VERSION}-alpine

LABEL org.opencontainers.image.source="https://github.com/core7-services/caddy"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
