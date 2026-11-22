# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow [Semantic Versioning](https://semver.org/).

## [0.1.2] - 2026-11-22

### Changed

- Documented the Premium plan (R$ 299,90/month: 10,000 queries per month, up to 5,000 rows per query, complete data with no masking).
- Skill: `whoami` now reports the plan (`tier`) and the quota period (day on free, month on Premium).

## [0.1.1] - 2026-11-22

### Changed

- README: step-by-step for the Claude Code extension in VS Code (`/plugins` window; typed `/plugin …` commands don't work in the panel).
- Documented the free plan: personal data is masked in every result; exact CPF/CNPJ search still works.
- `explain` now validates without running; the detailed plan is for admin accounts.

## [0.1.0] - 2026-11-22

### Added

- Claude Code marketplace `mariana-mcp` with the `mariana` plugin: remote MCP server (`list_graphs`, `get_schema`, `query`, `explain`, `get_node`, `neighbors`, `whoami`) and the token prompt on install.
- `query` skill with the Mariana Cypher guide.
- MCP Registry `server.json`.
- Configs for Claude Code without the plugin, VS Code, Cursor and Claude Desktop.
- `scripts/check.sh` release checks.
