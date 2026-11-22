#!/usr/bin/env bash
# Adds Mariana to Claude Code without the plugin (plain MCP server).
# Usage: MARIANA_TOKEN=mrnk_... ./clients/claude-code.sh [user|project|local]
set -euo pipefail
: "${MARIANA_TOKEN:?set MARIANA_TOKEN (create one at https://mariana.santanabigdata.com.br/tokens)}"
scope="${1:-user}"
claude mcp add --transport http --scope "$scope" mariana \
  https://mariana.santanabigdata.com.br/mcp \
  --header "Authorization: Bearer ${MARIANA_TOKEN}"
claude mcp get mariana | grep -i status || true
