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
TARGET_FILE="$DATA_DIR/custom_js.html"
STATE_FILE="$DATA_DIR/grocy-addon-state.json"

if [ ! -d "$DATA_DIR" ]; then
	mkdir -p "$DATA_DIR"
fi

BACKUP_FILE=""
if [ -f "$TARGET_FILE" ] && [ "${NO_BACKUP:-0}" != "1" ]; then
	TS="$(date -u +%Y%m%d_%H%M%S)"
	BACKUP_FILE="$DATA_DIR/custom_js.html.bak_addon_${TS}"
	cp "$TARGET_FILE" "$BACKUP_FILE"
	echo "Backup cree: $BACKUP_FILE"
fi

cp "$ADDON_FILE" "$TARGET_FILE"

cat > "$STATE_FILE" <<EOF
{
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "installed_by": "install.sh",
  "addon_file": "$ADDON_FILE",
  "target_file": "$TARGET_FILE",
  "backup_file": "$BACKUP_FILE"
}
EOF

echo "Addon installe: $TARGET_FILE"
echo "Etat: $STATE_FILE"
