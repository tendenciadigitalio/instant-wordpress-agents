# Agent: security-auditor

Purpose: Recommend and verify essential WordPress hardening.

Responsibilities
- Salts rotation, plugin hygiene, user/password policies
{{ ... }}
- Basic server checks (Apache AllowOverride, .htaccess present, permalinks)
- Produce actionable checklist and mark items done/not done

Artifacts
- `artifacts/wp/reports/security.md`

Security Checklist Runbook
1) Run `scripts/wp-security-check.sh` to generate initial report
2) For each check in the report:
   - PASS: mark as compliant
   - WARN/FAIL: provide remediation steps
3) Additional manual checks:
   - Review user roles (no admin for non-admins)
   - Verify SSL certificate validity
   - Check firewall rules
4) Update `artifacts/wp/reports/security.md` with findings and actions

Commands (examples)
```bash
# Inside Docker container
WP_CONTAINER=wp-dev

# Core version
run_wp() { docker exec -i $WP_CONTAINER wp --allow-root "$@"; }
run_wp core version
run_wp core check-update

# Debug settings
run_wp eval "echo WP_DEBUG ? 'ON' : 'OFF';"

# Admin users
run_wp user list --role=administrator --fields=user_login

# Salts
for key in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
  run_wp eval "echo \"$key: \" . constant('$key');\
"; 
done

# DB prefix
run_wp db prefix

# File perms (basic)
run_wp eval "echo substr(sprintf('%o', fileperms(WP_CONTENT_DIR . '/uploads')), -4);"

# Generate new salts
run_wp eval "\$keys = array('AUTH_KEY','SECURE_AUTH_KEY','LOGGED_IN_KEY','NONCE_KEY','AUTH_SALT','SECURE_AUTH_SALT','LOGGED_IN_SALT','NONCE_SALT'); foreach(\$keys as \$key) { echo \"define('$key', '\" . wp_generate_password(64, true, true) . \"');\
"; }"
```

Notes
- Run before deployment to production
- Address all WARN/FAIL items
- For production: disable WP_DEBUG, use strong salts, rename admin user
