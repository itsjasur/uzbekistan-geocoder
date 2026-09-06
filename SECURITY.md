# Security

If you find a security problem, please report it privately through GitHub's
security advisory feature instead of opening a public issue. A useful report
includes steps to reproduce the problem, its impact, and a possible fix if you
have one.

This repo provides a starting configuration, but you are still responsible for
securing your server, Docker, DNS, firewall, backups, and monitoring. The Caddy
rate limit helps with ordinary abuse; it is not a replacement for upstream DDoS
protection.

Do not expose Nominatim's PostgreSQL port to the internet.
