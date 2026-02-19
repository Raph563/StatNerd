#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ADDON_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

CONFIG_PATH="${1:-}"
if [ -z "$CONFIG_PATH" ]; then
	if [ -d "$ADDON_ROOT/../config" ]; then
		CONFIG_PATH="$ADDON_ROOT/../config"
	else
		echo "ERREUR: chemin config manquant et ../config introuvable." >&2
		exit 1
	fi
fi

SOURCE_FILE="$CONFIG_PATH/data/custom_js_nerdstats.html"
if [ ! -f "$SOURCE_FILE" ]; then
	SOURCE_FILE="$CONFIG_PATH/data/custom_js.html"
fi
DEST_FILE="$ADDON_ROOT/dist/custom_js.html"

if [ ! -f "$SOURCE_FILE" ]; then
	echo "ERREUR: source introuvable: $SOURCE_FILE" >&2
	exit 1
fi

cp "$SOURCE_FILE" "$DEST_FILE"
echo "Export OK: $SOURCE_FILE -> $DEST_FILE"

