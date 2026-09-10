{{/*
SPDX-License-Identifier: AGPL-3.0-only
*/}}
{{- define "microspell.psql.external" -}}
{{- /* TODO: external psql path — not yet implemented. Draft notes below. */ -}}
{{- end -}}

{{/*
WIP draft — preserved as notes until the external psql path is implemented.
Do not uncomment without rewriting as valid Go template code.

$root := index . 0

runicIndexer $glyphDefinition.selector = existing pgsql
runicIndexer $glyphDefinition.secretStore

$secretGlyphDefinition := dict  (create random secret)
include "external-secrets.push-secret" $root $secretGlyphDefinition  (USER Y PASSWORD psql)

$jobDefinition := dict  (create user in cluster)
include "workload.job" $root $jobDefinition
*/}}
