# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow [Semantic Versioning](https://semver.org/).

## [0.1.1] - 2026-11-22

### Changed

- Documented the free plan: personal data is masked in every result; exact CPF/CNPJ search still works.
- `explain` now validates without running; the detailed plan is for admin accounts.

## [0.1.0] - 2026-11-22

### Added

- Claude Code marketplace `mariana-mcp` with the `mariana` plugin: remote MCP server (`list_graphs`, `get_schema`, `query`, `explain`, `get_node`, `neighbors`, `whoami`) and the token prompt on install.
- `query` skill with the Mariana Cypher guide.
- MCP Registry `server.json`.
- Configs for Claude Code without the plugin, VS Code, Cursor and Claude Desktop.
- `scripts/check.sh` release checks.
