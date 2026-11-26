#!/usr/bin/env bash

if ! [ -d "/run/systemd/system" ] || ! [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    echo "This script requires a systemd-based system (Ubuntu/Debian)."
    exit 1
fi

# ===========================

aliases_url="https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/custom-aliases.sh"

begin_marker="# === BEGIN CUSTOM ALIASES ==="
end_marker="# === END CUSTOM ALIASES ==="

cur_bashrc="$HOME/.bashrc"

# ===========================

usage() {
    cat <<EOF
Usage: ${0##*/} [-w|--weather-city CITY] [-h|--help]

Updates the aliases block in ~/.bashrc from the GitHub repository.

Options:
  -w, --weather-city CITY  city for the weather forecast (default: Abakan)
  -h, --help       show this help message
EOF
}

weather_city=""
new_bashrc=""
trap 'rm -f "$new_bashrc"' EXIT

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help|-help) usage; exit 0 ;;

        -w|--weather-city|-weather-city) if [[ -n "$2" && "$2" =~ ^[A-Za-z_-]+$ ]]; then
                weather_city="$2"
                shift 2
            else
                echo "Error: the --weather-city option requires a city name (Latin letters, '_' and '-' only)."
                exit 1
            fi ;;
        -*)   echo "Invalid option: $1"; exit 1 ;;
        *)    echo "Unknown argument: $1"; exit 1 ;;
    esac
done

# ===========================

if [[ ! -f "$cur_bashrc" ]]; then
       echo "File $cur_bashrc not found."
       exit 1
fi

# ===========================

# Checking if both markers are found in current bashrc
has_begin=0; has_end=0
grep -qxF "$begin_marker" "$cur_bashrc" && has_begin=1
grep -qxF "$end_marker" "$cur_bashrc" && has_end=1

if (( has_begin && !has_end )); then
    echo "Error: found BEGIN marker but END marker is missing in $cur_bashrc."
    exit 1
elif (( !has_begin && has_end )); then
    echo "Error: found END marker but BEGIN marker is missing in $cur_bashrc."
    exit 1
fi

# Downloading new bashrc
new_bashrc=$(mktemp)
if ! curl -SsfL "$aliases_url" -o "$new_bashrc"; then
       echo "Failed to download the aliases file."
       exit 1
fi

# Normalize line endings
sed -i 's/\r$//' "$new_bashrc"

# Make sure the downloaded file is not corrupted
if [[ ! -s "$new_bashrc" ]] ||
   [[ "$(head -1 "$new_bashrc")" != "$begin_marker" ]] ||
   [[ "$(tail -1 "$new_bashrc")" != "$end_marker" ]]; then
       echo "The downloaded file looks corrupted."
       exit 1
fi

# Backup
cp "$cur_bashrc" "$cur_bashrc.bak" || exit 1

# Remove the old block
sed -i "/^${begin_marker}\$/,/^${end_marker}\$/d" "$cur_bashrc"

# Append the new block
echo >> "$cur_bashrc"
cat "$new_bashrc" >> "$cur_bashrc"

# Cleanup (collapse consecutive blank lines)
sed -i '/^$/N;/^\n$/D' "$cur_bashrc"

if [[ -n "$weather_city" ]]; then
    sed -i "s/\bAbakan\b/$weather_city/g" "$cur_bashrc"
fi

# Done
echo "[$(date +'%d/%m/%Y %H:%M')] Aliases successfully updated."
