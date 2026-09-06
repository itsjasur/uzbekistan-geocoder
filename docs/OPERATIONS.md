# Running the service

## Start

```bash
docker compose pull nominatim
docker compose build caddy
docker compose up -d
```

## Watch the first import

```bash
docker compose logs -f nominatim
```

Leave the container running while the import is making progress. Caddy returns
`502` until Gunicorn starts serving the API.

## Check readiness

```bash
docker compose ps nominatim
docker compose exec nominatim curl --fail http://localhost:8080/status
```

## Validate configuration

```bash
docker compose config --quiet
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Restart without reimporting

Once the import is complete, you can recreate the container without importing
again. Docker reuses the database volume:

```bash
docker compose up -d --no-deps --force-recreate nominatim
```

## Logs

```bash
docker compose logs --tail=100 nominatim
docker compose logs --tail=100 caddy
```

## Resource checks

```bash
docker stats
docker system df
```

`THREADS` controls import parallelism, not HTTP concurrency.
`GUNICORN_WORKERS` controls API worker processes. Increase either one only when
the server has enough free CPU and memory.

## Changing import style

The import style is chosen when the database is created. Changing
`IMPORT_STYLE` in `.env` does nothing to an existing database. Import into a new
volume, test it, and then switch production traffic.

Do not delete the active volume until the replacement works or you are prepared
to wait for another full import.

## Upgrades

Read the Nominatim and MediaGIS release notes before upgrading. A patch update
may only need a container recreation, but a major or database-format change can
require a migration or full import. I recommend preparing a new volume beside
the old one so rollback stays simple.
