---
name: security
description: Security best practices, secrets management, OWASP patterns
globs:
  - "**/*"
---

# Security Best Practices

Security is not optional. Every project must pass security checks.

## Required .gitignore Entries

**NEVER commit these:**

```gitignore
# Environment files
.env
.env.*
!.env.example

# Secrets and credentials
*.pem
*.key
*.p12
credentials.json
secrets.json
*-credentials.json
service-account*.json

# IDE secrets
.idea/
.vscode/settings.json
```

## Environment Variables

### Create .env.example

Document required vars without values:

```bash
# Server-side only (never expose to client)
DATABASE_URL=
API_SECRET_KEY=
ANTHROPIC_API_KEY=

# Client-side safe (public, non-sensitive)
API_BASE_URL=
```



### Validate at Startup




## OWASP Top 10 Checklist

| Vulnerability | Prevention |
|---------------|------------|
| Injection (SQL, NoSQL, Command) | Parameterized queries, input validation |
| Broken Auth | Secure session management, MFA |
| Sensitive Data Exposure | Encryption at rest and in transit |
| XXE | Disable external entity processing |
| Broken Access Control | Verify permissions on every request |
| Security Misconfiguration | Secure defaults, minimal permissions |
| XSS | Output encoding, CSP headers |
| Insecure Deserialization | Validate all serialized data |
| Using Vulnerable Components | Keep dependencies updated |
| Insufficient Logging | Log security events, monitor |

## Input Validation

```
RULE: Never trust user input. Validate everything.

- Validate type, length, format, range
- Sanitize before storage
- Encode before output
- Use allowlists over denylists
```

## Secrets Detection

Before committing, check for:

- API keys (usually 32+ chars, specific patterns)
- Passwords in code
- Connection strings with credentials
- Private keys (BEGIN RSA/EC/PRIVATE KEY)
- Tokens (jwt, bearer, oauth)

## Security Review Checklist

Before PR merge:

- [ ] No secrets in code or config
- [ ] Input validation on all user data
- [ ] Output encoding where displayed
- [ ] Authentication checked on protected routes
- [ ] Authorization verified for resources
- [ ] Dependencies scanned for vulnerabilities
- [ ] Error messages don't leak internals
