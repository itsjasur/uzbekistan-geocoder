# Contributing

Issues and pull requests are welcome.

For a small fix, feel free to open a pull request directly. For a bigger change
to the API or deployment layout, please open an issue first so we can agree on
the direction.

Before sending a pull request:

1. Keep the configuration generic and do not include server-specific values.
2. Run `docker compose --env-file .env.example config --quiet`.
3. Build the Caddy image and validate `Caddyfile`.
4. Update the docs if the setup or public API changed.
5. Explain what you changed and how you tested it.

Please never commit `.env` files, passwords, access tokens, database dumps, OSM
extracts, production logs, or user coordinates.
