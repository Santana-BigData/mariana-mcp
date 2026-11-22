#!/usr/bin/env bash
# Checks the repo before a release:
#  1. every JSON file parses
#  2. the plugin version matches server.json and the CHANGELOG
#  3. `claude plugin validate` (if Claude Code is installed)
#  4. with MARIANA_TOKEN set: talks to the live server (initialize, tools/list, whoami)
set -euo pipefail
cd "$(dirname "$0")/.."
URL="${MARIANA_URL:-https://mariana.santanabigdata.com.br/mcp}"

echo "== JSON"
find . -name '*.json' -not -path './.git/*' -print0 | while IFS= read -r -d '' f; do
  python3 -m json.tool "$f" >/dev/null || { echo "invalid JSON: $f"; exit 1; }
  echo "ok  $f"
done

echo "== version"
v_plugin=$(python3 -c 'import json;print(json.load(open("plugins/mariana/.claude-plugin/plugin.json"))["version"])')
v_server=$(python3 -c 'import json;print(json.load(open("server.json"))["version"])')
[ "$v_plugin" = "$v_server" ] || { echo "plugin.json ($v_plugin) != server.json ($v_server)"; exit 1; }
grep -q "^## \[$v_plugin\]" CHANGELOG.md || { echo "CHANGELOG.md has no section for $v_plugin"; exit 1; }
echo "ok  $v_plugin"

echo "== claude plugin validate"
# CLAUDE=... para usar outra instalação; sem `claude` recente, usa o npx
CLAUDE="${CLAUDE:-claude}"
if ! "$CLAUDE" plugin validate ./plugins/mariana >/dev/null 2>&1 && command -v npx >/dev/null; then
  CLAUDE="npx -y @anthropic-ai/claude-code@latest"
fi
$CLAUDE plugin validate ./plugins/mariana | grep -E "✔|✘|❯ root"
$CLAUDE plugin validate . | grep -E "✔|✘"

echo "== live server ($URL)"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$URL" -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}')
[ "$code" = 401 ] || { echo "expected 401 without a token, got $code"; exit 1; }
echo "ok  401 without a token"
if [ -n "${MARIANA_TOKEN:-}" ]; then
  rpc() { curl -sf -X POST "$URL" -H "authorization: Bearer $MARIANA_TOKEN" -H 'content-type: application/json' -d "$1"; }
  rpc '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"check","version":"1"}}}' \
    | python3 -c 'import sys,json;r=json.load(sys.stdin)["result"];print("ok  initialize", r["serverInfo"]["name"], r["protocolVersion"])'
  rpc '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
    | python3 -c 'import sys,json;print("ok  tools:", ", ".join(t["name"] for t in json.load(sys.stdin)["result"]["tools"]))'
  rpc '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"whoami","arguments":{}}}' \
    | python3 -c 'import sys,json;u=json.load(sys.stdin)["result"]["structuredContent"]["user"];print("ok  whoami", u["email"], u["role"])'
else
  echo "skip authenticated checks (set MARIANA_TOKEN)"
fi
echo "all good"
