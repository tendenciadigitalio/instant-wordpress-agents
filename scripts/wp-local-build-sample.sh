#!/usr/bin/env bash
set -euo pipefail

# Sample local build steps using WP-CLI inside Docker container
# Adjust WP_CONTAINER if your container name differs
WP_CONTAINER="${WP_CONTAINER:-wp-dev}"

run_wp() {
  docker exec -i "$WP_CONTAINER" wp --allow-root "$@"
}

# Sanity check
docker ps --format '{{.Names}}' | grep -q "^${WP_CONTAINER}$" || {
  echo "Container ${WP_CONTAINER} not running. Start Docker stack (e.g., docker compose up -d)." >&2
  exit 1
}

# Permalinks
run_wp rewrite structure '/%postname%/'
run_wp rewrite flush

# Base pages
for p in Home About Blog Contact "Privacy Policy" Terms; do
  run_wp post create \
    --post_type=page \
    --post_title="$p" \
    --post_status=publish \
    --porcelain || true
done

# Sample post
run_wp post create \
  --post_type=post \
  --post_title="Sample Post" \
  --post_status=publish \
  --post_content="Hello world"

# Menus (requires theme locations configured)
run_wp menu create "Primary" || true
run_wp menu location assign primary Primary || true
run_wp menu item add-custom Primary "Home" /
run_wp menu item add-custom Primary "Blog" /blog/
run_wp menu item add-custom Primary "Case Studies" /case-studies/
run_wp menu item add-custom Primary "About" /about/
run_wp menu item add-custom Primary "Contact" /contact/

echo "Local build sample completed."
