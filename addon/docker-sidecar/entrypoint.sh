#!/bin/sh
set -eu

GROCY_CONFIG_PATH="${GROCY_CONFIG_PATH:-/grocy-config}"
ADDON_SOURCE="${ADDON_SOURCE:-/addon/dist/custom_js.html}"
BACKUP_ENABLED="${BACKUP_ENABLED:-true}"
STATE_FILENAME="${STATE_FILENAME:-grocy-addon-state.json}"
ADDON_TARGET_FILENAME="${ADDON_TARGET_FILENAME:-custom_js_nerdstats.html}"
ACTIVE_TARGET_FILENAME="${ACTIVE_TARGET_FILENAME:-custom_js.html}"
COMPOSE_SOURCES="${COMPOSE_SOURCES:-custom_js_nerdstats.html,custom_js_product_helper.html}"
COMPOSE_ENABLED="${COMPOSE_ENABLED:-true}"
KEEP_ALIVE="${KEEP_ALIVE:-false}"

DATA_DIR="${GROCY_CONFIG_PATH%/}/data"
TARGET_FILE="$DATA_DIR/$ADDON_TARGET_FILENAME"
ACTIVE_FILE="$DATA_DIR/$ACTIVE_TARGET_FILENAME"
STATE_FILE="$DATA_DIR/$STATE_FILENAME"

if [ ! -d "$DATA_DIR" ]; then
	echo "ERREUR: dossier data introuvable: $DATA_DIR" >&2
	exit 1
fi

if [ ! -f "$ADDON_SOURCE" ]; then
	echo "ERREUR: addon source introuvable: $ADDON_SOURCE" >&2
	exit 1
fi

BACKUP_FILE=""
if [ -f "$ACTIVE_FILE" ] && [ "$BACKUP_ENABLED" = "true" ]; then
	TS="$(date -u +%Y%m%d_%H%M%S)"
	BACKUP_FILE="$DATA_DIR/custom_js.html.bak_addon_${TS}"
	cp "$ACTIVE_FILE" "$BACKUP_FILE"
	echo "Backup cree: $BACKUP_FILE"
fi

cp "$ADDON_SOURCE" "$TARGET_FILE"

compose_custom_js() {
	if [ "$COMPOSE_ENABLED" = "false" ] || [ "$COMPOSE_ENABLED" = "0" ]; then
		cp "$TARGET_FILE" "$ACTIVE_FILE"
		return 0
	fi
	TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/grocy-addon-sidecar-compose.XXXXXX")"
	trap 'rm -f "$TMP_FILE"' EXIT
	printf '<!-- managed by docker-sidecar entrypoint (Grocy) -->\n' > "$TMP_FILE"
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
		cp "$TARGET_FILE" "$ACTIVE_FILE"
		return 0
	fi
	mv "$TMP_FILE" "$ACTIVE_FILE"
	trap - EXIT
}

compose_custom_js

cat > "$STATE_FILE" <<EOF
{
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "installed_by": "docker-sidecar",
  "addon_file": "$ADDON_SOURCE",
  "target_file": "$TARGET_FILE",
  "active_file": "$ACTIVE_FILE",
  "backup_file": "$BACKUP_FILE"
}
EOF

echo "Payload addon installe via sidecar: $TARGET_FILE"
echo "Fichier actif compose: $ACTIVE_FILE"
echo "Etat: $STATE_FILE"

if [ "$KEEP_ALIVE" = "true" ]; then
	echo "Mode KEEP_ALIVE actif."
	tail -f /dev/null
fi
