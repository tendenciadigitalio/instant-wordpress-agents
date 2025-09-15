# Troubleshooting

## 1) 404 on all posts/pages after migration
- Symptom: Home works but posts/pages return 404.
- Fix:
  ```bash
  # On server
  wp --allow-root rewrite structure '/%postname%/'
  wp --allow-root rewrite flush
  ```
- If using Apache: ensure `AllowOverride All` for the site and `.htaccess` exists.

## 2) `.htaccess` missing or ignored
- Symptom: Pretty permalinks not working.
- Fix:
  - Apache vhost should include `AllowOverride All` for the WP directory.
  - Create or re-generate `.htaccess` via WP Permalinks settings or copy default rules.

## 3) `/sitemap.xml` 404
- Symptom: SEO tools can’t find the sitemap.
- Fix:
  - Check core sitemap: `/wp-sitemap.xml`.
  - If using an SEO plugin that overrides sitemaps, confirm the plugin is active and configured.

## 4) Robots blocking production
- Symptom: `robots.txt` disallows crawling in production.
- Fix:
  - Check Settings > Reading visibility.
  - Ensure `robots.txt` or plugin-generated robots are set for production.

## 5) WP-CLI not found on server
- Symptom: `wp: command not found`.
- Fix:
  - Install WP-CLI: https://wp-cli.org/
  - Run commands with `sudo -u www-data` if needed or `--allow-root` when appropriate.

## 6) Docker `wp-dev` container not running (local)
- Symptom: `docker exec -i wp-dev wp ...` fails.
- Fix:
  ```bash
  docker compose up -d
  docker ps
  ```

## 7) Playwright MCP issues
- Symptom: `/wp-validate` fails to run.
- Fix:
  ```bash
  npx @playwright/mcp@latest --help
  # Reinstall or ensure Node/NPX available
  ```

## 8) SSL issues (HTTPS not working)
- Symptom: Browser warns about insecure connection.
- Fix:
  - Install certificate with `certbot --apache` or Nginx equivalent.
  - Update WordPress `home` and `siteurl` to `https://`.

## 9) Mixed content after enabling HTTPS
- Symptom: Some assets load over HTTP.
- Fix:
  - Update theme/plugins to use protocol-relative or HTTPS URLs.
  - Search/replace old URLs in DB cautiously (use wp-cli `search-replace`).

## 10) Where are reports?
- Healthcheck: `artifacts/wp/reports/healthcheck.md`
- Post-deploy: `artifacts/wp/reports/deploy.md`
- QA validation: `artifacts/wp/reports/validation.md`
