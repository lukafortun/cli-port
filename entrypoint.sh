#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/input.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/fold.sh"
source "$BASE_DIR/core/stylise.sh"
source "$BASE_DIR/pages.sh"

STATE=0
resize_needed=1
page=0

on_resize() {
  resize_needed=1
}

percent_of() {
  local base=$1
  local percent=$2
  echo $(( (base * percent + 50) / 100 )) 
}

draw_box_content(){
	local total_width=$1
	local rows=$2
	local cols=$3
	local cut_width=$(percent_of total_width 75)
        local box_height=$(( rows <  40 ? (rows - 2) : 40 ))
        local box_width=$cut_width
        local start_row=$(( (rows - box_height) / 2 ))
        local start_col=$(( (cols - total_width) / 2 ))

draw_box $start_row $start_col $box_width $box_height "$content"
index_content=$(get_index_content)
draw_box $start_row $((start_col + box_width)) $((total_width - box_width)) $box_height "$index_content"
}

get_index_content() {
  echo -e "$(stylise "index" "\x1b[31m")\n"
  for i in "${!PAGE_TITLES[@]}"; do
    if [[ $i -eq $page ]]; then
      echo -e "\x1b[31;4;1m  $(($i+1)) - ${PAGE_TITLES[$i]}\e[0m"
    else
      echo -e "  $(($i+1)) - ${PAGE_TITLES[$i]}"
    fi
  done
}

get_page_content() {
  local idx=$(( $1 - 1 ))
  local title="${PAGE_TITLES[$idx]}"
  local content="${PAGE_CONTENTS[$idx]}"
  echo -e "$(stylise "$title" "\x1b[34m")\n\n$content"
}

content=$(get_page_content 1);

trap on_resize SIGWINCH

while true; do
    [[ "$resize_needed" -eq 1 ]] && {
        rows=$(tput lines)
        cols=$(tput cols)
        clear
        total_width=$(( cols < 150 ? cols : 150 ))
        draw_box_content $total_width $rows $cols
        resize_needed=0
    }

    if read -rsn1 -t 0.2 key; then
        case "$key" in
            [1-${#PAGE_TITLES[@]}])
                page=$((key - 1))
                content=$(get_page_content "$((page + 1))")
                resize_needed=1
                ;;
            $'\e[B')
                page=$(( (page + 1) % ${#PAGE_TITLES[@]} ))
                content=$(get_page_content "$((page + 1))")
                resize_needed=1
                ;;
            $'\e[A')
                page=$(( (page + ${#PAGE_TITLES[@]} - 1) % ${#PAGE_TITLES[@]} ))
                content=$(get_page_content "$((page + 1))")
                resize_needed=1
                ;;
            q|Q)
                clear; exit 0
                ;;
        esac
    fi
done

