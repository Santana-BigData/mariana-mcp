---
name: query
description: Answer questions with data from the Mariana graph database (people, companies, addresses, phones, lawsuits, debts and how they connect). Use when the user asks about Mariana data, relationships between entities, or wants a Cypher query run on Mariana.
---

# Querying Mariana

Mariana is a graph database: nodes have labels and properties, and typed relationships connect them. Use the `mariana` MCP tools; they are read-only.

## Workflow

1. **Know where you are.** Call `whoami` once: it tells the account role and, for regular accounts, the plan (`quota.tier`: `free` or `premium`), the quota (`used` of `limit` per `period`: day on free, month on Premium) and the row ceiling (`max_rows`). Call `list_graphs` to see which graphs you can query (regular accounts see only `global`).
2. **Read the schema before writing Cypher.** `get_schema(graph)` lists labels with their properties (type, `required`, `unique`, `searchable`) and relationship types with the allowed `from → to` label pairs. Use only names that exist there; labels and relationship types are case-sensitive.
3. **Write a narrow query.** Start from something selective, in this order of preference:
   - a `unique` property with an exact value: `MATCH (p:Pessoa {cpf: $cpf})`
   - `id(n) = $id`
   - a `searchable` property: `WHERE search(p.nome, 'joze silva')` (relevance, typo-tolerant; `score(p)` gives the score)
   - other property filters
   - scanning a whole label only with `LIMIT` and no `ORDER BY`, or with `allow_scan: true` (expensive; avoid)
4. **Check queries first when unsure.** `explain` validates the query without running it (and without using quota); admin accounts also get the plan and estimated cost.
5. **Run with `query`.** Always pass values as `params` (`$name` in the Cypher), never by string concatenation. Always use `LIMIT`.
6. **Explore around a node** with `neighbors(graph, id)` when the user wants "everything connected to X".

## Cypher that works

Read-only: `MATCH` with multi-hop paths, directions (`->`, `<-`, `-`) and alternative types (`:A|B`); `WHERE` with comparisons, `AND/OR/NOT`, `IN`, `IS NULL`, `STARTS WITH`, `ENDS WITH`, `CONTAINS`; `WITH`; `RETURN` with `AS` and `DISTINCT`; `count`, `sum`, `avg`, `min`, `max`, `collect`; `ORDER BY`, `SKIP`, `LIMIT`.

- String comparisons ignore accents, case and punctuation. For an exact match use `exact(p.nome) = 'José'`.
- Return nodes and relationships (`RETURN p, r, e`) when the user wants to see the network; return properties (`RETURN p.nome, e.razao_social`) for tables and counts.
- Not supported: writes (`CREATE`, `MERGE`, `SET`, `DELETE`), `OPTIONAL MATCH`, variable-length paths (`*1..3`). Chain explicit hops instead.

Examples (graph `global`):

```cypher
// partners in common
MATCH (p:Pessoa)-[s1:SOCIO_DE]->(e:Empresa)<-[s2:SOCIO_DE]-(q:Pessoa)
RETURN p, s1, e, s2, q LIMIT 40

// a person's companies and their lawsuits
MATCH (p:Pessoa {cpf: $cpf})-[s:SOCIO_DE]->(e:Empresa)-[pe:PARTE_EM]->(pr:Processo)
RETURN p, s, e, pe, pr LIMIT 50

// relevance search
MATCH (p:Pessoa) WHERE search(p.nome, $name)
RETURN p.nome, p.cpf, score(p) ORDER BY score(p) DESC LIMIT 10
```

## Limits and errors

- Regular accounts: each `query` and `neighbors` call uses 1 of the daily quota (resets at midnight, Brasília time); `explain`, `get_schema` and `get_node` are free. Results are cut at the account's row ceiling; `truncated: true` means there may be more rows. Prefer aggregates (`count`) and tighter filters over paging through rows, and tell the user when a result was truncated.
- Free accounts see personal data **masked** (CPF like `***.456.789-**`, names as first name + initials, contacts, addresses, amounts and dates masked). Searching by an exact CPF/CNPJ works (`{cpf: $cpf}` or `WHERE p.cpf = $cpf`); prefix, substring, range or ORDER BY on identifiers is rejected. Never try to unmask or infer hidden values; tell the user the data is masked on the free plan and that the Premium plan (Premium page on the Mariana site) shows it complete. Premium accounts (`whoami` → `quota.tier: "premium"`) get complete data, a monthly quota (`period: "month"`) and a higher row limit.
- Tool errors come back with the server's message (in Portuguese). Read it, fix the query (unknown label, missing `LIMIT`, needs `allow_scan`, quota reached, graph not allowed) and retry once; don't loop.
- Do not invent data: if a query returns nothing, say so and suggest a broader search.
