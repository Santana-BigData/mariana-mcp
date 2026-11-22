# Mariana MCP

Consulte o banco de dados em grafo **[Mariana](https://mariana.santanabigdata.com.br)** pelo Claude Code (e qualquer cliente MCP): pergunte em português, e o Claude lê o schema, escreve o Cypher, executa e explica o resultado.

*Read in English: [README.md](README.md).*

- **Servidor remoto, nada para rodar na sua máquina:** `https://mariana.santanabigdata.com.br/mcp` (MCP via HTTP).
- **Só leitura.** Nenhuma ferramenta escreve no banco.
- **Sua conta, seus limites.** Contas comuns consultam o grafo público (`global`), com cota diária de consultas e teto de linhas por consulta.

## 1. Pegue um token

1. [Crie uma conta grátis](https://mariana.santanabigdata.com.br/signup?lang=pt) e confirme o e-mail (ou entre, se já tiver).
2. Abra **Tokens de API** no menu do usuário ([link direto](https://mariana.santanabigdata.com.br/tokens?lang=pt)) e crie um token, por exemplo "Claude Code no notebook".
3. Copie (`mrnk_…`). Ele aparece uma vez só e vale até ser revogado. Trate como senha.

## 2. Instale no Claude Code (plugin, recomendado)

Dentro do Claude Code:

```text
/plugin marketplace add Santana-BigData/mariana-mcp
/plugin install mariana@mariana-mcp
```

(ou a URL completa: `https://github.com/Santana-BigData/mariana-mcp.git`). Precisa de um Claude Code recente (o pedido do token usa as configurações de usuário do plugin): rode `claude update` se o `/plugin install` reclamar de `userConfig`. O Claude Code pede o **token de API do Mariana** ao ativar o plugin e guarda em armazenamento seguro. Depois, `/mcp` deve mostrar `plugin:mariana:mariana` **conectado**.

O plugin traz:

- o servidor MCP `mariana` (ferramentas abaixo);
- a skill `/mariana:query`, que ensina o Claude a consultar bem o Mariana (schema primeiro, entrada seletiva, parâmetros, limites, cota). O Claude também a usa sozinho quando você pergunta sobre dados do Mariana.

Atualize com `/plugin marketplace update mariana-mcp`; remova com `/plugin uninstall mariana@mariana-mcp` (e revogue o token).

### Sem o plugin

Servidor MCP simples, com o token numa variável de ambiente:

```bash
export MARIANA_TOKEN='mrnk_...'
claude mcp add --transport http --scope user mariana \
  https://mariana.santanabigdata.com.br/mcp \
  --header "Authorization: Bearer $MARIANA_TOKEN"
```

(ou rode [`clients/claude-code.sh`](clients/claude-code.sh)). Para um projeto do time, versione [`clients/project.mcp.json`](clients/project.mcp.json) como `.mcp.json`: o token fica fora do git e cada pessoa exporta o próprio `MARIANA_TOKEN`.

## 3. Use

- "Quais grafos eu posso consultar no Mariana e o que tem no schema do `global`?"
- "Encontre as pessoas chamadas José Silva e mostre com quem elas estão ligadas."
- "Quais sócios de empresas com dívida ativa também aparecem em processos?"
- "Mostre pessoas que dividem o mesmo telefone ou o mesmo endereço."
- "Explique o plano desta consulta antes de rodar: `MATCH (p:Pessoa)-[:SOCIO_DE]->(e:Empresa) RETURN e.razao_social, count(p) ORDER BY count(p) DESC LIMIT 10`"

## Ferramentas

| Ferramenta | O que faz | Gasta cota |
|---|---|---|
| `list_graphs` | Grafos que a conta pode consultar | não |
| `get_schema` | Labels, propriedades (tipo, obrigatória, única, pesquisável) e relações com os pares de labels | não |
| `query` | Executa Cypher somente leitura; devolve colunas, linhas, custo, `truncated` e a `quota` | sim |
| `explain` | Plano e custo estimado, sem executar | não |
| `get_node` | Labels e propriedades de um nó pelo ID | não |
| `neighbors` | Um nó, os vizinhos e as arestas entre eles | sim |
| `whoami` | E-mail, papel e cota do dia | não |

Erros de consulta (label que não existe, sintaxe, cota esgotada, grafo sem permissão) voltam como erro da ferramenta, com a mensagem do servidor, para o Claude corrigir e tentar de novo.

## Outros clientes

| Cliente | Configuração |
|---|---|
| VS Code (Copilot, modo agente) | [`clients/vscode.mcp.json`](clients/vscode.mcp.json) → `.vscode/mcp.json` (pede o token) |
| Cursor | [`clients/cursor.mcp.json`](clients/cursor.mcp.json) → `~/.cursor/mcp.json` (lê `MARIANA_TOKEN`) |
| Claude Desktop | [`clients/claude-desktop.json`](clients/claude-desktop.json) → `claude_desktop_config.json` (via [`mcp-remote`](https://github.com/geelen/mcp-remote); precisa de Node 18+) |
| Qualquer outro | HTTP em `https://mariana.santanabigdata.com.br/mcp` com `Authorization: Bearer <token>` |

## Problemas comuns

- **401 / "failed to connect":** token errado, revogado ou ausente. Confira se ele aparece ativo na tela Tokens de API. Nas configurações por variável de ambiente, `MARIANA_TOKEN` precisa existir no shell que abriu o cliente.
- **"sua conta só pode consultar o grafo …":** contas comuns consultam só o `global`.
- **"limite diário de N consultas atingido":** a cota volta à meia-noite (horário de Brasília).

## Versões

Veja [Releasing](README.md#releasing) no README em inglês e o [`CHANGELOG.md`](CHANGELOG.md).

## Licença

[MIT](LICENSE).
