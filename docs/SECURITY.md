# Security Analysis & Pre-Deployment Checks

This document outlines the security analysis methodology for WordPress deployments using the Claude Code subagents system.

## Methodology

### 1) Automated Security Audit (`wp-security-check.sh`)
Run the security audit script before deployment to identify common vulnerabilities:

```bash
chmod +x scripts/wp-security-check.sh
./scripts/wp-security-check.sh
```

**Checks Performed:**
- WordPress core version and available updates
- Debug settings (WP_DEBUG should be OFF in production)
- Default admin user presence
- File permissions (uploads directory)
- Plugin/theme hygiene (basic status check)
- Database prefix (default wp_ is flagged)
- Security keys/salts customization
- Basic malware pattern scanning

**Output:** `artifacts/wp/reports/security.md`

### 2) Manual Security Review (security-auditor agent)
After running the script, the security-auditor agent performs additional checks:

- User role review (no unnecessary admins)
- SSL certificate validity
- Firewall configuration
- Server hardening (Apache/Nginx config)

### 3) Pre-Deployment Security Gates
- **No FAIL items:** Address all critical security issues
- **No WARN items:** Review and mitigate warnings
- **WP_DEBUG=OFF:** Ensure debug mode disabled
- **Salts rotated:** Use unique, strong salts
- **Admin user renamed:** Remove default 'admin' user

## Common Vulnerabilities & Remediation

### WordPress Core Outdated
- **Risk:** Known exploits
- **Remediation:**
  ```bash
  docker exec -i wp-dev wp --allow-root core update
  ```

### Default Admin User
- **Risk:** Brute force attacks
- **Remediation:**
  ```bash
  docker exec -i wp-dev wp --allow-root user create newadmin newadmin@example.com --role=administrator
  docker exec -i wp-dev wp --allow-root user delete admin
  ```

### Weak Salts
- **Risk:** Session hijacking, data exposure
- **Remediation:**
  ```bash
  # Generate new salts
  docker exec -i wp-dev wp --allow-root eval "\$keys = array('AUTH_KEY','SECURE_AUTH_KEY','LOGGED_IN_KEY','NONCE_KEY','AUTH_SALT','SECURE_AUTH_SALT','LOGGED_IN_SALT','NONCE_SALT'); foreach(\$keys as \$key) { echo \"define('$key', '\" . wp_generate_password(64, true, true) . \"');\\n\"; }"
  # Copy output to wp-config.php
  ```

### File Permissions Too Open
- **Risk:** Unauthorized file access/modification
- **Remediation:**
  ```bash
  # Inside container
  find /var/www/html -type d -exec chmod 755 {} \;
  find /var/www/html -type f -exec chmod 644 {} \;
  ```

### Default Database Prefix
- **Risk:** SQL injection easier if prefix known
- **Remediation:** Change to custom prefix (requires DB migration)

### Malware/Suspicious Files
- **Risk:** Code injection, backdoors
- **Remediation:** Scan and remove infected files, update all components

## Integration with Deployment Flow

The security audit is integrated into the `/wp-one-shot` command preflight:

1) Run healthcheck
2) Run security audit
3) Address any FAIL/WARN items
4) Proceed with deployment only if security gates pass

## Production Hardening Checklist

- [ ] SSL certificate installed and valid
- [ ] Firewall enabled (UFW, iptables)
- [ ] SSH hardened (no root login, key-only auth)
- [ ] Automatic backups configured
- [ ] Monitoring/alerting set up
- [ ] Rate limiting implemented
- [ ] Security headers configured (HSTS, CSP, etc.)
- [ ] Regular security updates scheduled

## References
- WordPress Security Codex: https://wordpress.org/support/article/hardening-wordpress/
- OWASP WordPress Security: https://owasp.org/www-pdf-archive/OWASP_WordPress_Security_Implementation_Guide.pdf
