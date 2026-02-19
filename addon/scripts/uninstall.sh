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

DATA_DIR="$CONFIG_PATH/data"
PAYLOAD_FILE_NAME="${ADDON_PAYLOAD_FILENAME:-custom_js_nerdstats.html}"
ACTIVE_FILE_NAME="${ACTIVE_TARGET_FILENAME:-custom_js.html}"
COMPOSE_SOURCES="${COMPOSE_SOURCES:-custom_js_nerdstats.html,custom_js_product_helper.html}"
COMPOSE_ENABLED="${COMPOSE_ENABLED:-1}"

TARGET_FILE="$DATA_DIR/$PAYLOAD_FILE_NAME"
ACTIVE_FILE="$DATA_DIR/$ACTIVE_FILE_NAME"
STATE_FILE="$DATA_DIR/grocy-addon-state.json"

compose_custom_js() {
	if [ "$COMPOSE_ENABLED" = "0" ] || [ "$COMPOSE_ENABLED" = "false" ]; then
		return 1
	fi

	TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/grocy-addon-compose.XXXXXX")"
	trap 'rm -f "$TMP_FILE"' EXIT
	printf '<!-- managed by uninstall.sh (Grocy) -->\n' > "$TMP_FILE"

	ADDED=0
	OLD_IFS="$IFS"
	IFS=','
	for raw in $COMPOSE_SOURCES; do
		src="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
		if [ -z "$src" ]; then
			continue
		fi
		path="$DATA_DIR/$src"
		if [ ! -s "$path" ]; then
			continue
		fi
		printf '\n<!-- source: %s -->\n' "$src" >> "$TMP_FILE"
		cat "$path" >> "$TMP_FILE"
		printf '\n' >> "$TMP_FILE"
		ADDED=1
	done
	IFS="$OLD_IFS"

	if [ "$ADDED" != "1" ]; then
		rm -f "$TMP_FILE"
		trap - EXIT
		return 1
	fi

	mv "$TMP_FILE" "$ACTIVE_FILE"
	chmod 0644 "$ACTIVE_FILE" 2>/dev/null || chmod a+r "$ACTIVE_FILE" 2>/dev/null || true
	trap - EXIT
	return 0
}

if [ ! -d "$DATA_DIR" ]; then
	echo "ERREUR: dossier data introuvable: $DATA_DIR" >&2
	exit 1
fi

RESTORE_FILE=""
if [ -f "$STATE_FILE" ]; then
	RESTORE_FILE="$(sed -n 's/.*"backup_file":[[:space:]]*"\(.*\)".*/\1/p' "$STATE_FILE" | head -n 1 || true)"
fi

rm -f "$TARGET_FILE"
rm -f "$STATE_FILE"

if compose_custom_js; then
	echo "Addon retire: $TARGET_FILE"
	echo "Fichier actif recompose: $ACTIVE_FILE"
	exit 0
fi

if [ -z "$RESTORE_FILE" ] || [ ! -f "$RESTORE_FILE" ]; then
	RESTORE_FILE="$(ls -1t "$DATA_DIR"/custom_js.html.bak_addon_* 2>/dev/null | head -n 1 || true)"
fi

if [ -n "$RESTORE_FILE" ] && [ -f "$RESTORE_FILE" ]; then
	cp "$RESTORE_FILE" "$ACTIVE_FILE"
	chmod 0644 "$ACTIVE_FILE" 2>/dev/null || chmod a+r "$ACTIVE_FILE" 2>/dev/null || true
	echo "Restaure depuis: $RESTORE_FILE"
	echo "Fichier actif: $ACTIVE_FILE"
	exit 0
fi

rm -f "$ACTIVE_FILE"
echo "Addon retire: $TARGET_FILE"
echo "Aucun autre addon actif, fichier supprime: $ACTIVE_FILE"
