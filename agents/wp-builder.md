# Agent: wp-builder

Purpose: Apply schema and assemble the site using WP-CLI.

Responsibilities
- Register CPTs and taxonomies
- Create pages (Home, About, Blog, Contact, legal)
- Import datasets into posts/CPTs
- Generate menus and set permalinks

Artifacts
- `artifacts/wp/reports/build.md`
- On-disk WordPress instance (Docker) updated per spec

Commands (examples)
```bash
# inside Docker: use the container name from docker-compose (e.g., wp-dev)
docker exec -i wp-dev wp --allow-root core version

# Set permalinks
docker exec -i wp-dev wp --allow-root rewrite structure '/%postname%/'
docker exec -i wp-dev wp --allow-root rewrite flush

# Create base pages
for p in Home About Blog Contact "Privacy Policy" Terms; do
  docker exec -i wp-dev wp --allow-root post create \
    --post_type=page \
    --post_title="$p" \
    --post_status=publish \
    --porcelain || true
done

# Create sample posts from dataset (pseudo: replace with your loader)
# Example creating a single post
docker exec -i wp-dev wp --allow-root post create \
  --post_type=post \
  --post_title="Sample Post" \
  --post_status=publish \
  --post_content="Hello world"

# Register menu and assign items (requires theme menu locations)
docker exec -i wp-dev wp --allow-root menu create "Primary"
docker exec -i wp-dev wp --allow-root menu location assign primary Primary || true
docker exec -i wp-dev wp --allow-root menu item add-custom Primary "Home" /
docker exec -i wp-dev wp --allow-root menu item add-custom Primary "Blog" /blog/
docker exec -i wp-dev wp --allow-root menu item add-custom Primary "Case Studies" /case-studies/
docker exec -i wp-dev wp --allow-root menu item add-custom Primary "About" /about/
docker exec -i wp-dev wp --allow-root menu item add-custom Primary "Contact" /contact/
```
