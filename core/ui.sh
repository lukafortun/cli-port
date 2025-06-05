
strip_ansi() {
  echo -e "$1" | sed -E 's/\x1B\[[0-9;]*m//g'
}

draw_box() {
  local x=$1       
  local y=$2       
  local width=$3   
  local height=$4  
  local text="$5"  

  local i line

  tput cup "$x" "$y"; echo -n "╔"
  printf '═%.0s' $(seq 1 $((width - 2)))
  echo "╗"

  for ((i = 1; i < height - 1; i++)); do
    tput cup $((x + i)) "$y"; echo -n "║"
    tput cup $((x + i)) $((y + width - 1)); echo "║"
  done

  tput cup $((x + height - 1)) "$y"; echo -n "╚"
  printf '═%.0s' $(seq 1 $((width - 2)))
  echo "╝"

  text=$(echo -e "$text")
  local raw_lines=()
  while IFS= read -r l || [[ -n $l ]]; do
    raw_lines+=("$l")
  done < <(printf "%s" "$text")

  local lines=()
  for line in "${raw_lines[@]}"; do
    if [[ -z "$line" ]]; then
      lines+=("")
    else
      while IFS= read -r wrapped; do
        lines+=("$wrapped")
      done < <(split_ansi_lines $((width - 4)) "$line")
    fi
  done

  for i in "${!lines[@]}"; do
    [[ $i -ge $((height - 2)) ]] && break
    tput cup $((x + i)) $((y + 1))
    printf " %-*s " $((width - 4)) "${lines[$i]}"
  done
}

