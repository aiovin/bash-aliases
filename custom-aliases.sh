# === BEGIN CUSTOM ALIASES ===

update-aliases() {
  bash -c "$(curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh)" -- "$@" && source ~/.bashrc
}

export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/usr/sbin:/sbin"

if locale -a 2>/dev/null | grep -qix 'C\.utf8'; then
    export LANG=C.UTF-8
else
    export LANG=C
fi

export EDITOR=nano
export VISUAL=nano

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ll='ls -lah'

alias cls='clear'
alias сды='clear'
alias act='source venv/bin/activate'
alias x='exit'

alias update='sudo apt update && sudo apt upgrade -y'

listen() { if [[ -n "$1" ]]; then sudo ss -tulnp | grep -P ":\K$1(?=\s)|\"[^\",]*\K$1"; else sudo ss -tulnp; fi; }

# Make dysk print sizes in binary units
alias dysk='dysk -u binary'

# Format numbers in a human-readable form
alias hr='numfmt --to=iec --suffix=b'

# Upload text to termbin (cat text.txt | tb)
# Retention: one week
alias tb="nc termbin.com 9999"

# Current weather via wttr.in
alias wtt='curl wttr.in/Abakan?format="%l:+%t+%C+(Feels+like+%f)\n"'
# Same wttr.in source, but returns a 3-day forecast by default
alias goweather="curl -s https://goweather.xyz/v2/weather/Abakan | jq ."

# Motivational quote
alias zenquote='curl -s "https://zenquotes.io/api/random" | jq -r ".[0].q"'

# Sunset today (+ time left until it)
function sunset {
  local result=$(curl -s 'wttr.in/Abakan?format=Sunset+in+Abakan:+%s')
  local target_time=$(echo "$result" | awk -F': ' '{print $2}')

  # Get the current time in HH:MM:SS format
  local current_time=$(date +%H:%M:%S)

  # Convert the times to seconds
  local current_seconds=$(date -d "$current_time" +%s)
  local target_seconds=$(date -d "today $target_time" +%s)  # Explicitly specify "today"

  # Calculate the difference (negative if the target time has already passed)
  local time_diff=$((target_seconds - current_seconds))

  # Convert the difference back to HH:MM:SS
  local time_diff_formatted=$(date -u -d @$((time_diff < 0 ? -time_diff : time_diff)) +%H:%M:%S)

  if (( time_diff >= 0 )); then
      result="${result} (time left: $time_diff_formatted)"
  fi
  echo "${result}"
}

# Sunrise today
alias sunrise='curl -s wttr.in/Abakan?format="Sunrise+in+Abakan:+%S\n"'

# Moon today
alias moon='curl -s wttr.in/moon | head -n -2'

# Get a lorem ipsum paragraph
alias lorem="curl -s 'https://baconipsum.com/api/?type=meat-and-filler&paras=1&start-with-lorem=1' | jq -r '.[0]'"

# Pick Yes or No
alias yesno="curl -s https://yesno.wtf/api | jq -r '.answer'"

# Generate a password
passgen() {
    tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "${1:-16}"
    echo
}

# Generate random ports
alias portgen='echo $(shuf -i 1024-9999 -n 10)'

# Play Ode to Joy
alias ode="aplay $HOME/.sounds/ode.wav"

# To use mid3v2 from the virtual environment
alias mid3v2="$HOME/python_projects/venv/bin/mid3v2"

# Show video info
# "vv" - info for all videos in the folder; "vv video.mp4" - info for a single video
vv() {
  if [[ -z "$1" ]]; then
    for f in *.mp4 *.avi *.mkv *.mov; do
      [ -f "$f" ] || continue
      echo "$f:"
      ffprobe -v error -show_entries stream=codec_name,width,height,duration,bit_rate -of default=noprint_wrappers=1 "$f"
      echo
    done
  else
    ffprobe -v error -show_entries stream=codec_name,width,height,duration,bit_rate -of default=noprint_wrappers=1 "$1"
  fi
}

# Show photo info
# "pp" - all photos in the folder; "pp photo.jpg" - short info for one file; "pp -v photo.jpg" - detailed info for one file
pp() {
  if [ "$1" = "-v" ]; then
    if [ -n "$2" ]; then
      ffprobe -v quiet -show_streams -show_entries stream_tags=* "$2"
    fi
    return
  fi

  if [ -z "$1" ]; then
    for f in *.{jpg,jpeg,JPG,png}; do
      [ -f "$f" ] || continue
      echo "$f:"
      ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=noprint_wrappers=1 "$f"
      echo
    done
  else
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height -of default=noprint_wrappers=1 "$1"
  fi
}

# Get info about an IP or a domain (resolving it to an IP first)
ipinfo() {
  [[ -z "$1" ]] && { echo "usage: ipinfo [ip|domain]"; return 1; }

  local target="$1"
  local ip

  if [[ "$target" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    ip="$target"
  elif [[ "$target" =~ : ]]; then
    ip="$target"
  else
    local ips
    mapfile -t ips < <(host "$target" 2>/dev/null | awk '/has address/{print $NF} /has IPv6 address/{print $NF}')
    [[ ${#ips[@]} -eq 0 ]] && { echo "error: could not resolve '$target'"; return 1; }

    if [[ ${#ips[@]} -gt 1 ]]; then
      echo "found ${#ips[@]} addresses for '$target':"
      for i in "${!ips[@]}"; do
        echo "  ${ips[$i]}"
      done
      echo
    fi

    ip="${ips[0]}"
  fi

  curl -s "https://ipinfo.io/$ip" | jq .
}

# Look up a port via lsof
port() { sudo lsof -nP -i:"${1:-80}"; }

# Sum a column. First argument - column number, second - delimiter
total ()
{
  awk -F "${2:- }" '{s += $'${1:-1}'} END {print s}'
}

# Generate a string of digits
digigen () {
  tr -dc '0-9' < /dev/urandom | head -c "${1:-20}";
  echo
}

# === END CUSTOM ALIASES ===
