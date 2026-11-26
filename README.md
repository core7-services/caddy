# Caddy for Core7

An Alpine-based Caddy image with [caddy-l4](https://github.com/mholt/caddy-l4) for TCP routing and the [Cloudflare DNS module](https://github.com/caddy-dns/cloudflare) for ACME DNS-01. The [Dockerfile](Dockerfile) pins Caddy and both modules.

## Image

Pull requests to `main` build the Linux AMD64 image, check that both modules are registered, and validate the example. Pushes to `main` run the same checks and publish `ghcr.io/core7-services/caddy:latest` and `ghcr.io/core7-services/caddy:sha-<commit>`. Use the commit tag or image digest to pin a deployment.

Build locally with `docker build -t core7-caddy .`.

## Configuration

The [example Caddyfile](examples/Caddyfile) shows two paths on the same `443/tcp` listener. Caddy sends one SNI to a TLS backend that accepts PROXY protocol v2 and terminates HTTPS for the site itself. For HTTP/3, publish `443/udp` alongside `443/tcp`. Set `CLOUDFLARE_API_TOKEN` in the container for DNS-01.

Caddy reads the Caddyfile on startup and adapts it to its native JSON configuration. Keep the Caddyfile and any `import` fragments in a mounted directory such as `/etc/caddy`. After updating the files, validate and reload them from inside the container. These commands assume the Compose service is named `caddy`.

```sh
docker compose exec -T caddy caddy validate --config /etc/caddy/Caddyfile
docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile
```

`caddy reload` applies the configuration through the Admin API without restarting the process. If loading fails, Caddy keeps serving the previous configuration. The default container startup reads the Caddyfile once. `caddy run --watch` is a local development option. See the [Caddy CLI reference](https://caddyserver.com/docs/command-line#caddy-reload).

The Admin API listens on `localhost:2019` by default. A controller can send a complete JSON configuration to `POST /load` or use `text/caddyfile` to send a Caddyfile. Keep the API local and reach it over SSH when managing a remote host, or use Caddy's experimental remote admin endpoint with mutual TLS. An API update changes the active configuration. For persistence after restart, keep the mounted files in sync or use `caddy run --resume` and persist Caddy's config directory. See the [Admin API reference](https://caddyserver.com/docs/api#post-load) and [remote admin implementation](https://github.com/caddyserver/caddy/blob/v2.11.9/admin.go).
