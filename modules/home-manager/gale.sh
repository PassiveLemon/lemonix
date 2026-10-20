#!/usr/bin/env bash

GAME="$1"
shift

PROFILEPATH="${HOME}/.local/share/com.kesomannen.gale/${GAME}/profiles"
PROFILES=$(find "$PROFILEPATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v "^Default$" | sort -u)

PROFILEARRAY=(
  "Vanilla"
  "Default"
)

while IFS= read -r profile; do
  PROFILEARRAY+=("$profile")
done <<< "$PROFILES"

# This allows Zenity to be themed in the pressure vessel sandbox. I have no idea why it works.
PROFILE=$(env -u LD_LIBRARY_PATH /usr/bin/zenity --list --title="Select Profile" --column="Profile" "${PROFILEARRAY[@]}")

if [ "$PROFILE" == "" ]; then
  echo "No profile selected."
  exit 1
fi

if [ "$PROFILE" == "Vanilla" ]; then
  "$@"
else
  exec "${PROFILEPATH}/${PROFILE}/start_game_bepinex.sh" "$@"
fi

