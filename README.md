# Uzbekistan Geocoder

This is the Docker setup I use to run a public geocoder for Uzbekistan. It uses
[Nominatim](https://nominatim.org/) with OpenStreetMap data from Geofabrik and
puts Caddy in front of it for HTTPS, CORS, and rate limiting.

It supports both forward geocoding (a place name to coordinates) and reverse
geocoding (coordinates to an address). The database stays updated from the
Uzbekistan OSM replication feed.

This repo is configuration around Nominatim, not a fork of Nominatim itself.

## What is included

- Forward and reverse geocoding
- Uzbekistan data from Geofabrik
- Continuous OpenStreetMap updates
- The `address` import style, which skips unrelated POIs
- Automatic HTTPS with Caddy
- CORS headers for browser clients
- Per-client rate limiting, including IPv6 `/64` grouping
- Persistent PostgreSQL data
- Health checks and automatic container restarts
- No public Nominatim or PostgreSQL ports

## API

Caddy exposes three routes:

| Route | What it does |
| --- | --- |
| `GET /search` | Finds coordinates from a place or address |
| `GET /reverse` | Finds an address from coordinates |
| `GET /health` | Checks whether Nominatim is ready |

### Search

```bash
curl --get "https://geo.example.com/search" \
  --data-urlencode "q=Amir Temur street, Toshkent" \
  --data "format=jsonv2" \
  --data "addressdetails=1" \
  --data "accept-language=uz" \
  --data "limit=5"
```

`q` is required. You can use any language code or an ordered language list in
`accept-language`. The result still depends on which translated names are
available in OpenStreetMap.

### Reverse

```bash
curl --get "https://geo.example.com/reverse" \
  --data "lat=41.3111" \
  --data "lon=69.2797" \
  --data "format=jsonv2" \
  --data "addressdetails=1" \
  --data "accept-language=uz"
```

`lat` and `lon` are required. If you need consistent address categories across
countries, try `format=geocodejson`.

There are more examples in [docs/API.md](docs/API.md).

## Server requirements

- Linux with Docker Engine and Docker Compose v2
- A domain pointing to the server
- Ports 80 and 443 open
- SSD space for the imported database and future updates
- At least 2 GB of RAM for Nominatim; more is better on a shared server

The first import is mostly limited by CPU, memory, and disk speed. I left the
defaults at one import thread and one API worker so the stack can run on a small
server.

## Setup

```bash
git clone https://github.com/itsjasur/uzbekistan-geocoder.git
cd uzbekistan-geocoder
cp .env.example .env
```

Open `.env` and set your domain and an internal PostgreSQL password:

```dotenv
GEOCODER_DOMAIN=geo.example.com
NOMINATIM_PASSWORD=replace-with-a-random-password
```

Then start it:

```bash
docker compose pull nominatim
docker compose build caddy
docker compose up -d
docker compose logs -f nominatim
```

On the first run, Nominatim downloads the Uzbekistan extract and builds the
database. This can take a while. A `502` from Caddy during the import is normal
because the API is not running yet.

When the log says Nominatim is ready, check the public endpoint:

```bash
curl "https://geo.example.com/health"
curl "https://geo.example.com/search?q=Toshkent&format=jsonv2"
```

## Settings

The defaults are in `.env.example`.

| Variable | Default | Meaning |
| --- | --- | --- |
| `GEOCODER_DOMAIN` | required | Public hostname used by Caddy |
| `NOMINATIM_PASSWORD` | required | Password for the internal PostgreSQL database |
| `PBF_URL` | Uzbekistan latest | OSM file used for the first import |
| `REPLICATION_URL` | Uzbekistan updates | Feed used for later OSM updates |
| `UPDATE_MODE` | `continuous` | Applies OSM updates in the background |
| `IMPORT_STYLE` | `address` | Imports addresses and administrative places without general POIs |
| `THREADS` | `1` | Parallelism during the first import |
| `GUNICORN_WORKERS` | `1` | Number of API worker processes |
| `RATE_LIMIT_EVENTS` | `120` | Requests allowed per window for each client |
| `RATE_LIMIT_WINDOW` | `1m` | Rate-limit window |
| `RATE_LIMIT_BURST` | `20` | Extra short burst allowed |

`IMPORT_STYLE` is applied when the database is created. Changing it later does
not rebuild an existing database; you need a fresh volume and a new import.

## Network setup

Only Caddy publishes ports to the host. Nominatim and PostgreSQL stay inside the
Docker network, and Caddy sends requests to `nominatim:8080`.

The trusted proxy list in `Caddyfile` is for Cloudflare. Remove or change it if
you do not use Cloudflare. Caddy handles TLS automatically once the domain points
to the server and ports 80 and 443 are reachable.

I use Caddy here to keep the project ready to run. If you already use Nginx,
Traefik, HAProxy, or another proxy, replace the Caddy service and proxy the same
three routes to `nominatim:8080`.

The included rate limit is a sensible starting point, not complete DDoS
protection. Watch your traffic, resource use, and `429` responses and tune it for
your server.

## Updates and storage

With `UPDATE_MODE=continuous`, the container downloads Uzbekistan OSM updates
in the background. It needs working DNS and outbound HTTPS.

```bash
docker compose ps
docker compose logs --tail=100 nominatim
curl "https://geo.example.com/health"
```

The imported database lives in the `nominatim-data` Docker volume. Recreating a
container keeps the data. Deleting that volume starts a full import again.

For upgrades or import-setting changes, build and test a second volume before
switching production traffic. Keep the old volume until the new one works. See
[docs/OPERATIONS.md](docs/OPERATIONS.md) for the commands and the main things to
watch out for.

## A note about results

Reverse geocoding finds the closest suitable OSM object. It is not a strict
point-in-polygon lookup, so results near a boundary can sometimes look wrong.
Names and address detail also depend on the quality of OpenStreetMap data in
that area.

## Attribution and licenses

If you publish a service or app using these results, show this attribution:

> Data © OpenStreetMap contributors

Link it to <https://www.openstreetmap.org/copyright>. The
[OSMF geocoding guideline](https://osmfoundation.org/wiki/Licence/Community_Guidelines/Geocoding_-_Guideline)
has more details.

- Nominatim uses its [upstream license](https://github.com/osm-search/Nominatim).
- The [MediaGIS Docker image](https://github.com/mediagis/nominatim-docker) is CC0-1.0.
- OpenStreetMap data is available under the Open Database License.
- The files written for this repo are available under the MIT License.

This project is independent and is not endorsed by Nominatim, MediaGIS,
OpenStreetMap Foundation, Geofabrik, Caddy, or Cloudflare.

## Contributing

Issues and pull requests are welcome. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) first.

## Disclaimer

Geocoding data can be incomplete, old, or wrong. Do not use this service as the
only source for emergency response, legal boundaries, navigation safety, or
other high-stakes decisions.
