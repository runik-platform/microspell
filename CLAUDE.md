# CLAUDE.md — microspell

Shared concepts live in the [root CLAUDE.md](../../../CLAUDE.md) and [docs/vocabulary.md](../../../docs/vocabulary.md). This file only covers what is specific to the microspell trinket.

## 1. Role

Microspell is an opinionated microservice trinket. It reuses summon's workload and storage templates (consumed by name from the bundled `glyphs.git` submodule) and layers microservice-specific features on top:

- Istio mesh features (internal + external VirtualService, circuit breaking, retries, timeouts, subdomain / prefix / rewrite).
- Vault integration (auto-policy, secrets with pluggable location).
- PostgreSQL datastore (managed CNPG cluster; the external selector path is reserved but currently a stub).

## 2. How it is registered — defaultTrinket replacement

Microspell is not a key-triggered trinket. It is set as the `defaultTrinket` for a book or chapter:

```yaml
defaultTrinket:
  repository: ...
  path: ./charts/trinkets/microspell
  revision: upstream
```

Every spell in that scope without `chart:` or `path:` uses microspell as the primary source in place of summon.

## 3. Bundled glyphs

`charts/trinkets/microspell/charts/` is a git submodule of `glyphs.git`, aligned with the other consumers (kaster, summon, covenant, tarot) — all tracking the same canonical repository on branch `upstream`. Microspell consumes glyph templates by name: `summon.workload.*`, `summon.service`, `summon.configMap`, `istio.virtualService`, `vault.prolicy`, `postgresql.cluster`, and so on.

Edit rule: edit only in the canonical path `charts/glyphs/`; bump the submodule reference in every consumer afterwards.

## 4. What microspell renders

### `templates/base.yaml` — summon-equivalent layer

| Include | When |
|---------|------|
| `summon.workload.<type>` | `workload.enabled` |
| `summon.configMap` | for `configMaps` entries with `location: create` |
| `summon.secrets` | for `secrets` entries with `location: create` |
| `summon.serviceAccount` | `serviceAccount.enabled` |
| `summon.autoscaling` | `autoscaling.enabled` |
| `summon.service` | `service.enabled` and workload is deployment / statefulset / daemonset |
| `summon.pv`, `summon.persistentVolumeClaim` | pvc-type entries in `volumes` |

### `templates/microservice.yaml` — opinionated CRD layer

| Include | When |
|---------|------|
| `istio.virtualService` (internal) | always when `service.enabled` |
| `istio.virtualService` (external) | when `service.external` |
| `vault.prolicy` | when `infrastructure.prolicy.enabled` |
| `<location>.secret` | for each entry in `secrets` whose `location` is neither `local` nor `create` (dispatches to `vault.secret`, `external-secrets.secret`, ...) |

### `templates/psql/` — PostgreSQL integration

`main.tpl` routes to `managed.tpl` or `external.tpl` based on whether `dataStore.psql.selector` is empty (managed) or populated (external). `managed.tpl` renders a CNPG `Cluster` + a Vault DB Engine credentials block. `external.tpl` is currently a stub — see §7.

## 5. Opinionated defaults vs summon

- `service.*` mesh fields: `circuitBreaking`, `retry`, `timeout`, `external`, `prefix`, `subdomain`, `rewrite`.
- `infrastructure.prolicy` for auto-created Vault policies.
- `dataStore.psql` for managed PostgreSQL integration; selector-based external integration is not implemented yet.
- `workload.replicas` default is 2 (summon defaults to 1).
- `autoscaling` is disabled by default; when enabled its defaults are 2–10 replicas with a 70% CPU target.

## 6. Relationship to summon's internal dispatcher

Microspell does not run summon's `range $root.Subcharts` loop. It calls named summon templates directly and renders specific CRDs through explicit conditionals. **Top-level glyph-like keys** (`vault:`, `istio:`, etc. at the spell root) **are ignored by microspell** — they are only handled by summon's own dispatcher.

In a microspell-based spell, use microspell's own conventions for infrastructure it supports (`service.*`, `infrastructure.*`, `dataStore.*`, `secrets.*`). Anything else goes under `glyphs:` so kaster picks it up as a separate ArgoCD source.

## 7. Current state notes

- `templates/psql/external.tpl` is a stub — an empty `define` block with design notes preserved inside a template comment. Spells that set `dataStore.psql.selector` render no external-psql plumbing until this path is implemented.

## 8. Testing

`examples/` contains ten examples: `basic-microservice`, `advanced-microservice`, `datastore-psql-managed`, `datastore-psql-external`, `vault-secrets-comprehensive`, `volumes-comprehensive`, `statefulset-redis-cluster`, `cronjob-backup-scheduler`, `job-data-processor`, `staging-microservice`.

Render through a book that sets microspell as `defaultTrinket`:

```
make render   book <name>
make snapshot book <name>
make test     book <name>
```

## 9. Related docs

- [Root CLAUDE.md](../../../CLAUDE.md) — framework-wide concepts.
- [docs/vocabulary.md](../../../docs/vocabulary.md) — glossary.
- [librarian/CLAUDE.md](../../../librarian/CLAUDE.md) — what reaches microspell.
- [charts/summon/CLAUDE.md](../../summon/CLAUDE.md) — the templates microspell reuses.
- [docs/usage/trinkets.md](../../../docs/usage/trinkets.md) — Microspell spell-author reference.
