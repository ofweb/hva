#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd -P)"
SAMPLE="$ROOT/env/env-source-sample.sh"
TARGET="$ROOT/env/env-source.sh"

if [[ ! -f "$SAMPLE" ]]; then
  echo "missing sample env file: $SAMPLE" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if [[ ! -f "$TARGET" ]]; then
  install -m 0644 "$SAMPLE" "$TARGET"
  echo "created env/env-source.sh from sample"
  exit 0
fi

missing_vars=()
missing_lines=()

while IFS= read -r line; do
  if [[ "$line" =~ ^export[[:space:]]+([A-Z0-9_]+)= ]]; then
    var_name="${BASH_REMATCH[1]}"
    if ! grep -Eq "^[[:space:]]*export[[:space:]]+${var_name}=" "$TARGET"; then
      missing_vars+=("$var_name")
      missing_lines+=("$line")
    fi
  fi
done < "$SAMPLE"

if (( ${#missing_lines[@]} == 0 )); then
  exit 0
fi

{
  echo
  echo "# Added by internals/sync-env-source.sh"
  printf '%s\n' "${missing_lines[@]}"
} >> "$TARGET"

echo "updated env/env-source.sh with missing vars: ${missing_vars[*]}"
