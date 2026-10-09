# Statusbar for dwm: "vol 40%  |  bat 87% Discharging  |  Fri 09 Oct 21:30"
# dwm shows the name of the X root window in its bar; `xsetroot -name` sets it.
# (No shebang: Nix wraps this file with bash and the tools it needs — see desktop.nix.)

volume() {
  local out
  out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || { echo "vol n/a"; return; }
  if [[ $out == *MUTED* ]]; then
    echo "vol muted"
  else
    awk '{ printf "vol %d%%", $2 * 100 }' <<<"$out"
  fi
}

battery() {   # prints nothing and fails on machines without a battery
  local dir cap state
  for dir in /sys/class/power_supply/BAT*; do
    [ -r "$dir/capacity" ] || continue
    read -r cap < "$dir/capacity"
    read -r state < "$dir/status"
    echo "bat ${cap}% ${state}"
    return 0
  done
  return 1
}

while true; do
  status="$(volume)  |  "
  if bat=$(battery); then status+="${bat}  |  "; fi
  status+="$(date '+%a %d %b %H:%M')"
  xsetroot -name "$status" || exit 0   # X is gone (logged out): stop
  sleep 5
done
