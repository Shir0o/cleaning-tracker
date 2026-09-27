# ADR 0001: Android release automation pipeline

- Status: Accepted
- Date: 2026-09-26

## Context

Prior to this setup, releases were manually tracked and Android release builds relied on debug keystore signing. Cutting a release involved manual version bumping, manual tagging, and manual artifact generation and uploads.

## Decision

We adopt an automated release pipeline modeled after `~/attd` consisting of:

1. **release-please** as the single source of truth for versioning, CHANGELOG generation, tag pushing, and GitHub Release creation.
2. **fastlane supply** for Play Console uploads.
3. **Play App Signing** for keystore management — CI uses a dedicated upload key, Google holds the app-signing key.
4. **Internal-track-first** delivery — automated uploads land on the internal testing track as draft releases; production promotion remains a deliberate manual action in the Google Play Console UI.

Release-please reads PR titles (conventional commits) when PRs are merged onto `main`. PR title linting enforces this on every pull request.

## Alternatives considered

- **Manual version bumps & uploads**: Error-prone, inconsistent changelogs, high maintenance friction.
- **Direct production upload via CI**: Too risky for client-side Android applications; internal track allows verification and staged promotion.
