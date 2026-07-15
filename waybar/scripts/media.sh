#!/usr/bin/env bash

MAX=45

# Función para procesar y emitir el JSON
emit() {
    status=$1
    artist=$2
    title=$3
    album=$4
    player=$5

    # Si no hay estado, el reproductor está cerrado
    if [[ -z "$status" || "$status" == "No players found" ]]; then
        echo '{"text":"","class":"stopped","tooltip":""}'
        return
    fi

    # Configurar icono y clase según el estado
    case "$status" in
        Playing) icon="󰏤"; class="playing" ;;
        Paused)  icon="󰐊"; class="paused" ;;
        *) echo '{"text":"","class":"stopped","tooltip":""}'; return ;;
    esac

    # Lógica de etiqueta: Priorizar Artista — Título
    if [[ -n "$artist" && -n "$title" ]]; then
        label="$artist — $title"
    elif [[ -n "$title" ]]; then
        label="$title"
    else
        label="$player"
    fi

    # Truncar si es muy largo
    (( ${#label} > MAX )) && label="${label:0:$((MAX-1))}…"

    # Preparar Tooltip
    tooltip="Reproductor: $player"
    [[ -n "$album" ]] && tooltip+="\\n󰝚 $album"

    # Salida JSON para Waybar
    printf '{"text":"%s  %s", "class":"%s", "tooltip":"%s"}\n' \
        "$icon" "$label" "$class" "$tooltip"
}

# 1. Emisión inicial para que no aparezca vacío al arrancar Waybar
# Usamos un delimitador especial ( | ) para separar los campos
initial_metadata=$(playerctl metadata --format "{{status}}|{{artist}}|{{title}}|{{album}}|{{playerName}}" 2>/dev/null)
if [[ -n "$initial_metadata" ]]; then
    IFS='|' read -r s ar t al p <<< "$initial_metadata"
    emit "$s" "$ar" "$t" "$al" "$p"
else
    emit "" "" "" "" ""
fi

# 2. Bucle de escucha en tiempo real (Follow)
# Escuchamos cambios en metadata y estado simultáneamente
# Usamos stdbuf para asegurar que Waybar reciba la línea al instante
stdbuf -oL playerctl metadata --follow --format "{{status}}|{{artist}}|{{title}}|{{album}}|{{playerName}}" 2>/dev/null | \
while IFS='|' read -r status artist title album player; do
    emit "$status" "$artist" "$title" "$album" "$player"
done