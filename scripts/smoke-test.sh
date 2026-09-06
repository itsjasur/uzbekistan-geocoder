#!/bin/sh
set -eu

base_url="${1:-http://localhost:8080}"

curl --fail --silent --show-error "${base_url}/health"
printf '\n'

curl --fail --silent --show-error --get "${base_url}/search" \
  --data-urlencode "q=Toshkent" \
  --data "format=jsonv2" \
  --data "limit=1" >/dev/null

curl --fail --silent --show-error --get "${base_url}/reverse" \
  --data "lat=41.3111" \
  --data "lon=69.2797" \
  --data "format=jsonv2" >/dev/null

printf 'Forward and reverse geocoding checks passed.\n'

