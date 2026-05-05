# Security Policy

## Supported Versions
This project is maintained from the default branch. Security fixes are applied there first.

## Reporting a Vulnerability
Please do not report vulnerabilities through public GitHub issues.

Open a private GitHub security advisory if the repository has that feature enabled, or contact the maintainer directly with:

- A short description of the issue
- Steps to reproduce
- Potential impact
- Any suggested fix or mitigation

Please avoid including real user data, access tokens, signing keys, or other secrets in the report.

## Secrets
The app expects sensitive configuration, such as `GOOGLE_SERVER_CLIENT_ID`, to be provided through build-time configuration:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_GOOGLE_SERVER_CLIENT_ID
```

Do not commit `.env` files, signing keys, Google service files, or local secret files.
