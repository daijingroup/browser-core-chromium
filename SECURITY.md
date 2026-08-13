# Security

`browser-core-chromium` is a security-sensitive private repository.

## Reporting

Do not disclose suspected vulnerabilities through public issues or public discussions.

Report security concerns through the organisation's private security reporting process or directly to authorised repository/security maintainers.

## Repository rules

Never commit:

- credentials or API tokens;
- signing/private keys;
- Porticullus credentials or recovery material;
- user/browser profile data;
- production secrets;
- decrypted customer data.

Build and bootstrap tooling must use pinned upstream revisions where practical and must not silently replace a declared Chromium baseline with a moving upstream reference.

Security fixes to Chromium may advance the pinned revision under the release policy defined in `daijingroup/browser-spec`.
