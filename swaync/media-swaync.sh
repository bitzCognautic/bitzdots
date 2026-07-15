#!/usr/bin/env bash

# ════════════════════════════════
# CONFIG
# ════════════════════════════════
DELIM="|"
DEFAULT_TEXT="Nada reproduciendo"

# ════════════════════════════════
# FUNCIONES
# ════════════════════════════════

get_media_data() {
    local raw_data status artist title player album

    # Obtener metadata (una sola llamada)
    raw_data=$(playerctl metadata \
        --format "{{status}}${DELIM}{{artist}}${DELIM}{{title}}${DELIM}{{playerName}}${DELIM}{{album}}" \
        2>/dev/null)

    # Si no hay nada activo
    if [[ -z "$raw_data" ]]; then
        printf '{"text": "%s", "class": "stopped"}\n' "$DEFAULT_TEXT"
        return
    fi

    # Parseo
    IFS="$DELIM" read -r status artist title player album <<< "$raw_data"

    # ════════════════════════════════
    # FALLBACKS
    # ════════════════════════════════

    # Artista fallback (YouTube, navegadores, etc.)
    if [[ -z "$artist" || "$artist" == "null" ]]; then
        artist="${album:-$player}"
    fi

    # Título fallback
    if [[ -z "$title" || "$title" == "null" ]]; then
        title="Desconocido"
    fi

    # ════════════════════════════════
    # OUTPUT
    # ════════════════════════════════

    printf '{"text": "%s - %s", "class": "%s"}\n' \
        "$artist" "$title" "${status,,}"
}

# ════════════════════════════════
# LOOP PRINCIPAL (OPTIMIZADO)
# ════════════════════════════════

# En lugar de polling agresivo, usa follow (mejor rendimiento)
playerctl -F metadata --format "{{status}}" 2>/dev/null | while read -r _; do
    get_media_data
done

# Fallback (por si playerctl -F falla)
while true; do
    get_media_data
    sleep 2
done