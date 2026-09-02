# Project-Specific Rules

<!-- Repo-specific agent instructions. The rollout script never touches this file. -->

<!-- ── Migrated from CLAUDE.md ── -->

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 6. Testing Policy
- **Unit Tests**: Coverage thresholds are enforced in `vitest.config.ts`.
- **Ratcheting**: Thresholds must never be lowered; they should only go up as coverage improves.
- **New Code**: All new features and bug fixes must ship with matching unit tests.
---
<!-- OPENWIKI:START -->
## OpenWiki
This repository uses OpenWiki for recurring code documentation. Start with `openwiki/quickstart.md`, then follow its links to architecture, workflows, domain concepts, operations, integrations, testing guidance, and source maps.
The scheduled OpenWiki GitHub Actions workflow refreshes the repository wiki. Do not hand-edit generated OpenWiki pages unless explicitly asked; prefer updating source code/docs and letting OpenWiki regenerate.
<!-- OPENWIKI:END -->
