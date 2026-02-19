#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ADDON_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ADDON_FILE="$ADDON_ROOT/dist/custom_js.html"

if [ ! -f "$ADDON_FILE" ]; then
	echo "ERREUR: addon introuvable: $ADDON_FILE" >&2
	exit 1
fi

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
		return 0
	fi

	TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/grocy-addon-compose.XXXXXX")"
	trap 'rm -f "$TMP_FILE"' EXIT
	printf '<!-- managed by install.sh (Grocy) -->\n' > "$TMP_FILE"

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
}

if [ ! -d "$DATA_DIR" ]; then
	mkdir -p "$DATA_DIR"
fi

BACKUP_FILE=""
if [ -f "$ACTIVE_FILE" ] && [ "${NO_BACKUP:-0}" != "1" ]; then
	TS="$(date -u +%Y%m%d_%H%M%S)"
	BACKUP_FILE="$DATA_DIR/custom_js.html.bak_addon_${TS}"
	cp "$ACTIVE_FILE" "$BACKUP_FILE"
	echo "Backup cree: $BACKUP_FILE"
fi

cp "$ADDON_FILE" "$TARGET_FILE"

if ! compose_custom_js; then
	cp "$TARGET_FILE" "$ACTIVE_FILE"
	chmod 0644 "$ACTIVE_FILE" 2>/dev/null || chmod a+r "$ACTIVE_FILE" 2>/dev/null || true
fi

cat > "$STATE_FILE" <<EOF
{
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "installed_by": "install.sh",
  "addon_file": "$ADDON_FILE",
  "target_file": "$TARGET_FILE",
  "active_file": "$ACTIVE_FILE",
  "backup_file": "$BACKUP_FILE"
}
EOF

echo "Payload addon installe: $TARGET_FILE"
echo "Fichier actif compose: $ACTIVE_FILE"
echo "Etat: $STATE_FILE"
