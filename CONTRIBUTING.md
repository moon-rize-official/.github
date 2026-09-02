# Contributing to Moon Rize

## Purpose

This document defines the default contribution workflow for repositories in the `moon-rize-official` organization. Repository-specific instructions take precedence where they are stricter or more specialized.

## Core principles

1. Keep each change scoped to one clear objective.
2. Preserve existing behavior unless the change explicitly intends to alter it.
3. Prefer reviewable, reversible changes over large unstructured rewrites.
4. Treat configuration, infrastructure and deployment changes as production-impacting until proven otherwise.
5. Never commit credentials, private keys, tokens, passwords or environment secrets.
6. Use the machine-readable Moon Rize prefix `moonrize-*` for newly created Moon Rize identifiers.
7. Keep historical records and provenance intact when renaming or migrating systems.

## Branch naming

Use one of the following forms:

- `feat/<issue>-<short-description>`
- `fix/<issue>-<short-description>`
- `docs/<issue>-<short-description>`
- `infra/<issue>-<short-description>`
- `security/<issue>-<short-description>`
- `refactor/<issue>-<short-description>`
- `chore/<issue>-<short-description>`

Example:

```text
feat/42-add-deployment-receipts
```

## Commit messages

Use concise imperative subjects. Conventional Commit prefixes are recommended when practical:

```text
feat: add MAAS deployment verification
fix: correct inventory group resolution
docs: document image promotion policy
infra: add observability node role
security: restrict provisioning network access
```

Do not place secrets, access tokens, customer data or sensitive operational details in commit messages.

## Pull requests

Every pull request should include:

- the problem or objective;
- scope and non-goals;
- implementation summary;
- verification performed;
- operational or security impact;
- rollback information for consequential changes;
- linked issue or decision record where applicable.

Changes affecting infrastructure, authentication, secrets, networking, deployment, data retention, backups or destructive operations require explicit verification before merge.

## Review expectations

Reviewers should evaluate:

- correctness;
- maintainability;
- security boundaries;
- failure handling;
- rollback or recovery path;
- consistency with architecture and naming standards;
- documentation impact;
- test coverage and evidence.

## Testing

Run the repository's documented local checks before opening a pull request. CI remains authoritative. Do not bypass failing required checks merely to merge a change.

## Documentation

Update documentation in the same pull request when a change affects:

- architecture;
- operator procedures;
- configuration;
- interfaces;
- deployment;
- recovery;
- user-facing behavior;
- naming or lifecycle rules.

## Security reports

Do not open public issues for vulnerabilities, exposed secrets or credential leaks. Follow `SECURITY.md`.
