# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| Main / Master | :white_check_mark: |

## Reporting a Vulnerability

If you discover a potential security vulnerability within Krishi Setu, please do not disclose it via public GitHub issues.

Please contact the project maintainers directly or submit a private security advisory through GitHub.

Maintainers will review the report and coordinate remediation and release.

## Authentication & Credentials Architecture

- **Client Configuration:** The frontend embeds a Supabase URL and a publishable (anon) key. In Supabase's security model, the publishable key is public client configuration protected by PostgreSQL Row Level Security (RLS) policies. It is **not** a secret and does not grant administrative database access.
- **Service-Role Key:** Never place, commit, or configure the Supabase `service_role` key in frontend client code. Service-role operations are restricted to server-side edge functions.
- **Historical References:** Any inactive or legacy testing project URLs referenced in past development commits are deprecated. Live deployments should use newly provisioned, isolated Supabase projects.
