# Mariana plugin for Claude Code

Read-only access to the Mariana graph database from Claude Code. The plugin adds the remote `mariana` MCP server (list graphs, read the schema, run Cypher, explain plans, fetch a node and its neighbors) and the `/mariana:query` skill, which teaches Claude to read the schema first, start from selective properties, pass values as parameters and respect the account's quota and row limit.

When you enable the plugin, Claude Code asks for a Mariana API token (`mrnk_…`). Create one at https://mariana.santanabigdata.com.br/tokens after signing up at https://mariana.santanabigdata.com.br/signup. The token is kept in Claude Code's secure storage.

Full instructions, other clients and troubleshooting: see the repository README.
