# Security Policy

This policy applies to repositories under `moon-rize-official` unless a repository publishes a stricter `SECURITY.md`.

## Reporting a vulnerability

Do not publish exploitable vulnerability details, live credentials, private keys or sensitive operational information in public issues, discussions, pull requests or commit messages.

Preferred reporting method:

1. Use GitHub private vulnerability reporting on the affected repository when enabled.
2. If private reporting is unavailable, email `ciphermoony@proton.me`.

Include, when known:

- affected repository, service or component;
- affected version, release or commit;
- impact and likely severity;
- prerequisites for exploitation;
- concise reproduction steps;
- relevant logs or evidence with unrelated sensitive data removed;
- suggested mitigation, if available.

## Secret exposure procedure

If a credential, token, password, recovery code or private key is exposed:

1. revoke or rotate it immediately;
2. determine where it was used and what authority it carried;
3. review relevant access and audit logs;
4. remove it from active configuration;
5. replace dependent deployments or credentials as required;
6. remove accidental repository exposure where practical without destroying required historical evidence;
7. record the incident and remediation.

Deleting a secret from the latest revision is not sufficient if the exposed secret remains valid.

## Security-sensitive changes

The following require additional review and explicit verification:

- authentication and authorization;
- identity and role configuration;
- secrets management;
- firewall, routing and network policy;
- remote execution;
- machine provisioning and disk-erasure operations;
- production deployment;
- backup and restore;
- cryptography, signing and trust stores;
- dependency and supply-chain controls;
- changes that broaden administrative access.

## Dependency handling

Pin or constrain dependencies where reproducibility or supply-chain integrity requires it. Major upgrades should be tested before production adoption. Remove abandoned, redundant and unnecessary dependencies.

## Supported versions

Unless a repository states otherwise, the current default branch and latest supported release line receive active security maintenance.

## Sensitive repository content

Repositories must not contain live secrets, unrestricted production exports or private recovery material. Examples and templates must use clearly non-secret placeholders.

## Third-party services

Vulnerabilities in third-party services should be reported to the responsible provider unless the issue results from Moon Rize configuration or integration, in which case report the configuration problem through the process above.
