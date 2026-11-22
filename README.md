# Mariana MCP

Query the **[Mariana](https://mariana.santanabigdata.com.br)** graph database from Claude Code (and any MCP client): ask in plain language, and Claude reads the schema, writes Cypher, runs it and explains the result.

*Leia em português: [README.pt-BR.md](README.pt-BR.md).*

- **Remote server, nothing to run locally:** `https://mariana.santanabigdata.com.br/mcp` (MCP streamable HTTP).
- **Read-only.** No tool writes to the database.
- **Your account, your limits.** Regular accounts query the public graph (`global`) with a daily query quota and a row limit per query.

## 1. Get a token

1. [Create a free account](https://mariana.santanabigdata.com.br/signup) and confirm your email (or sign in if you have one).
2. Open **API tokens** in the user menu ([direct link](https://mariana.santanabigdata.com.br/tokens)) and create a token, e.g. "Claude Code on my laptop".
3. Copy it (`mrnk_…`). It is shown only once and is valid until you revoke it. Treat it like a password.

## 2. Install in Claude Code (plugin, recommended)

Inside Claude Code:

```text
/plugin marketplace add <this repository>
/plugin install mariana@mariana-mcp
```

`<this repository>` is the git URL of this repo (or `owner/repo` on GitHub). Needs a recent Claude Code (the token prompt uses plugin user settings): run `claude update` if `/plugin install` complains about `userConfig`. Claude Code asks for your **Mariana API token** when the plugin is enabled and keeps it in secure storage. Then run `/mcp`: `plugin:mariana:mariana` should show **connected**.

The plugin brings:

- the `mariana` MCP server (tools below);
- the `/mariana:query` skill, which teaches Claude how to query Mariana well (schema first, selective entry points, parameters, limits, quota). Claude also uses it on its own when you ask about Mariana data.

Update with `/plugin marketplace update mariana-mcp`; remove with `/plugin uninstall mariana@mariana-mcp` (and revoke the token).

### Without the plugin

Plain MCP server, token from an environment variable:

```bash
export MARIANA_TOKEN='mrnk_...'
claude mcp add --transport http --scope user mariana \
  https://mariana.santanabigdata.com.br/mcp \
  --header "Authorization: Bearer $MARIANA_TOKEN"
```

(or run [`clients/claude-code.sh`](clients/claude-code.sh)). For a team project, commit [`clients/project.mcp.json`](clients/project.mcp.json) as `.mcp.json`: the token stays out of git, each person exports `MARIANA_TOKEN`.

## 3. Use it

- "What graphs can I query in Mariana, and what's in the `global` schema?"
- "Find people named José Silva and show who they are connected to."
- "Which partners of companies with tax debt also appear in lawsuits?"
- "Show people who share the same phone number or address."
- "Explain the plan for this query before running it: `MATCH (p:Pessoa)-[:SOCIO_DE]->(e:Empresa) RETURN e.razao_social, count(p) ORDER BY count(p) DESC LIMIT 10`"

## Tools

| Tool | What it does | Uses quota |
|---|---|---|
| `list_graphs` | Graphs your account can query | no |
| `get_schema` | Labels, properties (type, required, unique, searchable) and relationship types with their label pairs | no |
| `query` | Runs read-only Cypher; returns columns, rows, cost, `truncated` and your `quota` | yes |
| `explain` | Plan and estimated cost, without running | no |
| `get_node` | A node's labels and properties by ID | no |
| `neighbors` | A node, its neighbors and the edges between them | yes |
| `whoami` | Your email, role and today's quota | no |

Query errors (unknown label, syntax, quota reached, graph not allowed) come back as tool errors with the server's message, so Claude can fix the query and retry.

## Other clients

| Client | Config |
|---|---|
| VS Code (Copilot agent mode) | [`clients/vscode.mcp.json`](clients/vscode.mcp.json) → `.vscode/mcp.json` (asks for the token) |
| Cursor | [`clients/cursor.mcp.json`](clients/cursor.mcp.json) → `~/.cursor/mcp.json` (reads `MARIANA_TOKEN`) |
| Claude Desktop | [`clients/claude-desktop.json`](clients/claude-desktop.json) → `claude_desktop_config.json` (via [`mcp-remote`](https://github.com/geelen/mcp-remote); needs Node 18+) |
| Anything else | streamable HTTP at `https://mariana.santanabigdata.com.br/mcp` with `Authorization: Bearer <token>` |

The MCP Registry entry is [`server.json`](server.json).

## Troubleshooting

- **401 / "failed to connect":** wrong, revoked or missing token. Check it is listed as active on the API tokens page. With the env-var setups, `MARIANA_TOKEN` must exist in the shell that started the client.
- **"your account can only query the graph …":** regular accounts query only `global`.
- **"daily limit of N queries reached":** the quota resets at midnight (Brasília time).
- Test by hand:

```bash
curl -s https://mariana.santanabigdata.com.br/mcp \
  -H "Authorization: Bearer $MARIANA_TOKEN" -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"whoami","arguments":{}}}'
```

## Repository layout

```text
.claude-plugin/marketplace.json     Claude Code marketplace (this repo)
plugins/mariana/.claude-plugin/plugin.json   plugin: MCP server + token prompt
plugins/mariana/skills/query/SKILL.md        skill: how to query Mariana
plugins/mariana/README.md, .claude-plugin/icon.png   plugin listing
server.json                         MCP Registry entry
clients/                            configs for other clients
scripts/check.sh                    checks before a release
```

## Releasing

1. Bump `version` in `plugins/mariana/.claude-plugin/plugin.json` **and** `server.json` (same value, [SemVer](https://semver.org)); add a section to [`CHANGELOG.md`](CHANGELOG.md).
2. `./scripts/check.sh` (with `MARIANA_TOKEN` set, it also checks the live server).
3. Commit, tag and push: `git tag v0.2.0 && git push --follow-tags`.
4. Users get it with `/plugin marketplace update mariana-mcp`. To publish in the MCP Registry: `mcp-publisher validate && mcp-publisher publish` (the `br.com.santanabigdata/` namespace needs DNS authentication of the domain).

## License

[MIT](LICENSE).
