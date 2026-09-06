# API reference

Requests are passed through to Nominatim. This page covers the options I expect
most clients to need. The [Nominatim API docs](https://nominatim.org/release-docs/5.3/api/Overview/)
have the full parameter list.

## Base URL

```text
https://YOUR_DOMAIN
```

The default setup does not require an API key.

## Forward geocoding

`GET /search` finds coordinates from a place name or address.

```bash
curl --get "https://YOUR_DOMAIN/search" \
  --data-urlencode "q=Toshkent, Amir Temur street" \
  --data "format=jsonv2" \
  --data "addressdetails=1" \
  --data "accept-language=uz" \
  --data "limit=5"
```

Common parameters:

| Parameter | Required | Description |
| --- | --- | --- |
| `q` | yes | Free-form place or address query |
| `format` | recommended | `jsonv2`, `geocodejson`, `geojson`, or `xml` |
| `addressdetails` | no | Set to `1` for structured address parts |
| `accept-language` | no | Any preferred language code or ordered language list |
| `limit` | no | Maximum number of results |

## Reverse geocoding

`GET /reverse` finds the closest suitable OSM address for WGS84 coordinates.

```bash
curl --get "https://YOUR_DOMAIN/reverse" \
  --data "lat=41.3111" \
  --data "lon=69.2797" \
  --data "format=geocodejson" \
  --data "addressdetails=1" \
  --data "accept-language=uz"
```

Common parameters:

| Parameter | Required | Description |
| --- | --- | --- |
| `lat` | yes | Latitude from `-90` to `90` |
| `lon` | yes | Longitude from `-180` to `180` |
| `format` | recommended | Output format |
| `addressdetails` | no | Set to `1` for structured address parts |
| `accept-language` | no | Any preferred language code or ordered language list |
| `zoom` | no | Controls the requested address-detail level |

This is a nearest-object lookup, not a strict point-in-polygon check. A result
near an administrative boundary may occasionally be surprising.

## Languages

Use a single language code or a normal `Accept-Language` preference list:

```text
accept-language=ko
accept-language=fr-CA,fr;q=0.9,en;q=0.7
```

You can send the same value in the HTTP `Accept-Language` header. Available
translations come from OpenStreetMap. If the requested translation is missing,
Nominatim falls back to a local or default name.

## Health

```bash
curl "https://YOUR_DOMAIN/health"
```

A ready Nominatim instance responds with `OK`.

## Errors and limits

- `404`: unsupported route, unavailable result, or forward search disabled in the imported database
- `429`: client rate limit exceeded; respect the `Retry-After` header
- `502`/`503`: Nominatim is starting, importing, restarting, or temporarily unavailable

Set a timeout in your client. Retry temporary failures with backoff, and cache
successful results when that makes sense for your app.

## Attribution

Applications using results must display `Data © OpenStreetMap contributors` with a link to <https://www.openstreetmap.org/copyright>.
