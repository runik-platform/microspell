{{/*Runik Platform
Copyright (C) 2025 namenmalkav@gmail.com
SPDX-License-Identifier: AGPL-3.0-only

Main orchestrator for dataStore.psql feature
Detects strategy (managed vs external) and delegates to appropriate templates
*/}}

{{- if .Values.dataStore.psql.enabled }}

{{- if eq (include "microspell.psql.isExternal" .) "true" }}
  {{/*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/}}
  {{/* EXTERNAL CLUSTER (has selector)   */}}
  {{/*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/}}

  {{- include "microspell.psql.external" . }}

{{- else }}
  {{/*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/}}
  {{/* MANAGED CLUSTER (no selector)     */}}
  {{/*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/}}

  {{- include "microspell.psql.managed" . }}

{{- end }}

{{- end }}
