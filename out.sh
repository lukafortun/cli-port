#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# BEGIN /home/user/cli-port/core/ui.sh

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

# END /home/user/cli-port/core/ui.sh
# BEGIN /home/user/cli-port/core/input.sh
get_key() {
  IFS= read -rsn1 key
  if [[ $key == $'\e' ]]; then
    IFS= read -rsn2 rest
    key+="$rest"
  fi
  echo "$key"
}
# END /home/user/cli-port/core/input.sh
# BEGIN /home/user/cli-port/core/config.sh
# END /home/user/cli-port/core/config.sh
# BEGIN /home/user/cli-port/fold.sh
#!/bin/bash


parse_ansi(){
  local input="$1"
  echo -e "$input" | awk '
  BEGIN { style_stack = "" }
  {
    while (match($0, /\033\[[0-9;]*m/)) {
      ansi = substr($0, RSTART, RLENGTH)
      before = substr($0, 1, RSTART - 1)
      $0 = substr($0, RSTART + RLENGTH)

      if (before != "")
        print "STYLE=" style_stack "|TEXT=" before

      if (ansi == "\033[0m") {
        style_stack = "\033[0m"
      } else {
        style_stack = style_stack ansi
      }
    }
    if ($0 != "")
      print "STYLE=" style_stack "|TEXT=" $0
  }'

}

split_ansi_lines() {
  local MAX=$1
  local count=0
  local buffer=""

  flush_buffer() {
    if [[ -n "$buffer" ]]; then
      buffer="${buffer#" "}"      
      buffer="${buffer%" "}"       
      echo -e "$buffer"
      buffer=""
      count=0
    fi
  }

  while IFS='|' read -r stylepart textpart; do
    local style="${stylepart#STYLE=}"
    local text="${textpart#TEXT=}"

    local i=0
    while (( i < ${#text} )); do
      local word=""
      local word_len=0
      local had_space=false

      while (( i < ${#text} )); do
        local char="${text:$i:1}"
        if [[ "$char" == " " ]]; then
          had_space=true
          ((i++))
          break
        fi
        word+="$char"
        ((word_len++))
        ((i++))
      done

      if (( word_len > MAX )); then
        flush_buffer
        local j=0
        while (( j + MAX < word_len )); do
          local part="${word:j:MAX}"
          echo -e "${style}${part}\033[0m"
          ((j+=MAX))
        done

        local part="${word:j}"
        buffer="${style}${part}\033[0m"
        count=${#part}
        if $had_space; then
          buffer+=" "
          ((count++))
        fi
        continue
      fi

      local extra_space=0
      $had_space && extra_space=1
      if (( count + word_len + extra_space > MAX )); then
        flush_buffer
      fi

      buffer+="${style}${word}\033[0m"
      ((count += word_len))
      if $had_space; then
        buffer+=" "
        ((count++))
      fi
    done
  done < <(parse_ansi "$2")

  flush_buffer
}















# END /home/user/cli-port/fold.sh
# BEGIN /home/user/cli-port/core/stylise.sh
stylise() {
    local text="$1"
    local color="$2"
    local -A top bottom


# ▄▀█ █▄▄ █▀▀ █▀▄ █▀▀ █▀▀ █▀▀ █░█ █ ░░█ █▄▀ █░░ █▀▄▀█ █▄░█ █▀█ █▀█ █▀█ █▀█ █▀ ▀█▀ █░█ █░█ █░█░█ ▀▄▀ █▄█ ▀█
# █▀█ █▄█ █▄▄ █▄▀ ██▄ █▀░ █▄█ █▀█ █ █▄█ █░█ █▄▄ █░▀░█ █░▀█ █▄█ █▀▀ ▀▀█ █▀▄ ▄█ ░█░ █▄█ ▀▄▀ ▀▄▀▄▀ █░█ ░█░ █▄

    top=(
        ["A"]="▄▀█" ["B"]="█▄▄" ["C"]="█▀▀" ["D"]="█▀▄" ["E"]="█▀▀" ["F"]="█▀▀" ["G"]="█▀▀" ["H"]="█░█" ["I"]="█" ["J"]="░░█" ["K"]="█▄▀" ["L"]="█░░"
        ["M"]="█▀▄▀█" ["N"]="█▄░█" ["O"]="█▀█" ["P"]="█▀█" ["Q"]="█▀█" ["R"]="█▀█" ["S"]="█▀" ["T"]="▀█▀" ["U"]="█░█" ["V"]="█░█"
        ["W"]="█░█░█" ["X"]="▀▄▀" ["Y"]="█▄█" ["Z"]="▀█"
    )
    bottom=(
        ["A"]="█▀█" ["B"]="█▄█" ["C"]="█▄▄" ["D"]="█▄▀" ["E"]="██▄" ["F"]="█▀░" ["G"]="█▄█" ["H"]="█▀█" ["I"]="█" ["J"]="█▄█" ["K"]="█░█" ["L"]="█▄▄"
        ["M"]="█░▀░█" ["N"]="█░▀█" ["O"]="█▄█" ["P"]="█▀▀" ["Q"]="▀▀█" ["R"]="█▀▄" ["S"]="▄█" ["T"]="░█░" ["U"]="█▄█" ["V"]="▀▄▀"
        ["W"]="▀▄▀▄▀" ["X"]="█░█" ["Y"]="░█░" ["Z"]="█▄"
    )

    local line1="$color"
    local line2="$color"


    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"
        char=$(echo "$char" | tr '[:lower:]' '[:upper:]')
        line1+="${top[$char]:-  } "
        line2+="${bottom[$char]:-  } "
    done

    echo -e "$line1"
    echo -e "$line2"
}


# END /home/user/cli-port/core/stylise.sh
# BEGIN /home/user/cli-port/pages.sh
PAGE_TITLES=()
PAGE_CONTENTS=()

# BEGIN /home/user/cli-port/pages/_flat_pages.sh
PAGE_TITLES=()
PAGE_CONTENTS=()
PAGE_TITLES+=(Home)
PAGE_CONTENTS+=(Bienvenue\ sur\ la\ page\ d\'accueil\ \!)
PAGE_TITLES+=(About\ me)
PAGE_CONTENTS+=(À\ propos\ de\ moi.)
PAGE_TITLES+=(Projects)
PAGE_CONTENTS+=($'🏠 HomeServer Ecosystem\nA multi-node home server running custom self-hosted apps.\n• Used: Spring Boot, ReactJS, Flask, Docker Swarm\n• Features: NAT bypassing, secure auth (OIDC + LDAP), container orchestration\n\n📦 AS24 Internship (2024)\nBuilt document management APIs with Java + Spring Boot.\n• Migrated millions of documents\n• Integrated with Microsoft tools: SharePoint, AD, Graph SDK\n\n🧠 3D Scanner Project\nContributed to an open-source 3D scanning app using Vulkan in C++.')
# END /home/user/cli-port/pages/_flat_pages.sh

# for pagefile in "$BASE_DIR/pages/"*.sh; do
#   unset PAGE_TITLE PAGE_CONTENT
#   source "$pagefile"
#   PAGE_TITLES+=("$PAGE_TITLE")
#   PAGE_CONTENTS+=("$PAGE_CONTENT")
# done

# END /home/user/cli-port/pages.sh

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

    key=$(get_key)
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
done

