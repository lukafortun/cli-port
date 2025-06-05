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
  stty -echo -icanon time 0 min 1
  local key
  IFS= read -rsn1 -t 0.1 key
  stty sane
  echo "$key"
}

# END /home/user/cli-port/core/input.sh
# BEGIN /home/user/cli-port/core/config.sh
AUTHOR_NAME="John Doe"
EMAIL="john.doe@example.com"

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
        local box_height=40
        local box_width=$cut_width
        local start_row=$(( (rows - box_height) / 2 ))
        local start_col=$(( (cols - total_width) / 2 ))

draw_box $start_row $start_col $box_width $box_height "$content"
index_content=$(get_index_content)
draw_box $start_row $((start_col + box_width)) $((total_width - box_width)) $box_height "$index_content"
}

landing_page_content() {  
  echo -e "\x1b[34m█░█ █▀█ █▀▄▀█ █▀▀
\x1b[34m█▀█ █▄█ █░▀░█ ██▄\n
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sit amet elit faucibus, aliquam elit ac, facilisis justo. Vivamus ac ornare eros, tincidunt facilisis tellus. Pellentesque rutrum ante eu eros viverra malesuada. Etiam nec lacus non lacus pulvinar venenatis. Vestibulum porttitor fringilla nisi, faucibus lacinia erat laoreet non. Sed elementum, enim eget euismod feugiat, libero lectus porta nisi, in dignissim nibh odio non eros. Etiam sodales fermentum metus sit amet pellentesque. Nam feugiat elementum varius. Quisque ultrices eleifend mollis. Nunc venenatis ornare purus in scelerisque. Donec eu lacus id felis hendrerit posuere. Donec condimentum malesuada mauris. Ut sed luctus purus. Suspendisse lobortis lacinia ex.

Ut vestibulum nulla et urna pharetra, quis commodo odio pharetra. Nulla lobortis nibh nibh, non dapibus arcu pulvinar ut. Donec porttitor ligula ac nisl porta, id consectetur eros efficitur. Donec erat nunc, rutrum eget metus eget, gravida viverra erat. Pellentesque augue ex, auctor sed pretium et, viverra vitae massa. Curabitur fermentum odio turpis. Nam scelerisque pretium velit non facilisis. Suspendisse tempus molestie dolor sed aliquam. Praesent placerat, nisi vitae viverra accumsan, magna nibh commodo odio, nec facilisis lorem nisl a velit.";}

about_page_content()    { 
  echo -e "\x1b[34m▄▀█ █▄▄ █▀█ █░█ ▀█▀   █▀▄▀█ █▀▀
\x1b[34m█▀█ █▄█ █▄█ █▄█ ░█░   █░▀░█ ██▄\n
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sit amet elit faucibus, aliquam elit ac, facilisis justo. Vivamus ac ornare eros, tincidunt facilisis tellus. Pellentesque rutrum ante eu eros viverra malesuada. Etiam nec lacus non lacus pulvinar venenatis. Vestibulum porttitor fringilla nisi, faucibus lacinia erat laoreet non. Sed elementum, enim eget euismod feugiat, libero lectus porta nisi, in dignissim nibh odio non eros. Etiam sodales fermentum metus sit amet pellentesque. Nam feugiat elementum varius. Quisque ultrices eleifend mollis. Nunc venenatis ornare purus in scelerisque. Donec eu lacus id felis hendrerit posuere. Donec condimentum malesuada mauris. Ut sed luctus purus. Suspendisse lobortis lacinia ex.

Ut vestibulum nulla et urna pharetra, quis commodo odio pharetra. Nulla lobortis nibh nibh, non dapibus arcu pulvinar ut. Donec porttitor ligula ac nisl porta, id consectetur eros efficitur. Donec erat nunc, rutrum eget metus eget, gravida viverra erat. Pellentesque augue ex, auctor sed pretium et, viverra vitae massa. Curabitur fermentum odio turpis. Nam scelerisque pretium velit non facilisis. Suspendisse tempus molestie dolor sed aliquam. Praesent placerat, nisi vitae viverra accumsan, magna nibh commodo odio, nec facilisis lorem nisl a velit.";}

projects_page_content() { echo -e "\x1b[34m█▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀
\x1b[34m█▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█\n
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sit amet elit faucibus, aliquam elit ac, facilisis justo. Vivamus ac ornare eros, tincidunt facilisis tellus. Pellentesque rutrum ante eu eros viverra malesuada. Etiam nec lacus non lacus pulvinar venenatis. Vestibulum porttitor fringilla nisi, faucibus lacinia erat laoreet non. Sed elementum, enim eget euismod feugiat, libero lectus porta nisi, in dignissim nibh odio non eros. Etiam sodales fermentum metus sit amet pellentesque. Nam feugiat elementum varius. Quisque ultrices eleifend mollis. Nunc venenatis ornare purus in scelerisque. Donec eu lacus id felis hendrerit posuere. Donec condimentum malesuada mauris. Ut sed luctus purus. Suspendisse lobortis lacinia ex.

Ut vestibulum nulla et urna pharetra, quis commodo odio pharetra. Nulla lobortis nibh nibh, non dapibus arcu pulvinar ut. Donec porttitor ligula ac nisl porta, id consectetur eros efficitur. Donec erat nunc, rutrum eget metus eget, gravida viverra erat. Pellentesque augue ex, auctor sed pretium et, viverra vitae massa. Curabitur fermentum odio turpis. Nam scelerisque pretium velit non facilisis. Suspendisse tempus molestie dolor sed aliquam. Praesent placerat, nisi vitae viverra accumsan, magna nibh commodo odio, nec facilisis lorem nisl a velit."; }

skills_page_content()   { echo -e "\x1b[34m█▀ █▄▀ █ █░░ █░░ █▀
\x1b[34m▄█ █░█ █ █▄▄ █▄▄ ▄█\n
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sit amet elit faucibus, aliquam elit ac, facilisis justo. Vivamus ac ornare eros, tincidunt facilisis tellus. Pellentesque rutrum ante eu eros viverra malesuada. Etiam nec lacus non lacus pulvinar venenatis. Vestibulum porttitor fringilla nisi, faucibus lacinia erat laoreet non. Sed elementum, enim eget euismod feugiat, libero lectus porta nisi, in dignissim nibh odio non eros. Etiam sodales fermentum metus sit amet pellentesque. Nam feugiat elementum varius. Quisque ultrices eleifend mollis. Nunc venenatis ornare purus in scelerisque. Donec eu lacus id felis hendrerit posuere. Donec condimentum malesuada mauris. Ut sed luctus purus. Suspendisse lobortis lacinia ex.

Ut vestibulum nulla et urna pharetra, quis commodo odio pharetra. Nulla lobortis nibh nibh, non dapibus arcu pulvinar ut. Donec porttitor ligula ac nisl porta, id consectetur eros efficitur. Donec erat nunc, rutrum eget metus eget, gravida viverra erat. Pellentesque augue ex, auctor sed pretium et, viverra vitae massa. Curabitur fermentum odio turpis. Nam scelerisque pretium velit non facilisis. Suspendisse tempus molestie dolor sed aliquam. Praesent placerat, nisi vitae viverra accumsan, magna nibh commodo odio, nec facilisis lorem nisl a velit."; }

contact_page_content()  { echo -e "\x1b[34m█▀▀ █▀█ █▄░█ ▀█▀ ▄▀█ █▀▀ ▀█▀
\x1b[34m█▄▄ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░\n
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sit amet elit faucibus, aliquam elit ac, facilisis justo. Vivamus ac ornare eros, tincidunt facilisis tellus. Pellentesque rutrum ante eu eros viverra malesuada. Etiam nec lacus non lacus pulvinar venenatis. Vestibulum porttitor fringilla nisi, faucibus lacinia erat laoreet non. Sed elementum, enim eget euismod feugiat, libero lectus porta nisi, in dignissim nibh odio non eros. Etiam sodales fermentum metus sit amet pellentesque. Nam feugiat elementum varius. Quisque ultrices eleifend mollis. Nunc venenatis ornare purus in scelerisque. Donec eu lacus id felis hendrerit posuere. Donec condimentum malesuada mauris. Ut sed luctus purus. Suspendisse lobortis lacinia ex.

Ut vestibulum nulla et urna pharetra, quis commodo odio pharetra. Nulla lobortis nibh nibh, non dapibus arcu pulvinar ut. Donec porttitor ligula ac nisl porta, id consectetur eros efficitur. Donec erat nunc, rutrum eget metus eget, gravida viverra erat. Pellentesque augue ex, auctor sed pretium et, viverra vitae massa. Curabitur fermentum odio turpis. Nam scelerisque pretium velit non facilisis. Suspendisse tempus molestie dolor sed aliquam. Praesent placerat, nisi vitae viverra accumsan, magna nibh commodo odio, nec facilisis lorem nisl a velit."; }


get_index_content(){
    echo -e "\x1b[31m█ █▄░█ █▀▄ █▀▀ ▀▄▀
\x1b[31m█ █░▀█ █▄▀ ██▄ █░█\n"
    case "$page" in
      0) echo -e "\e[1m  0 - Home\e[0m\n  1 - About me\n  2 - Projects\n  3 - Skills\n  4 - Contact";;
      1) echo -e "  0 - Home\n\e[1m  1 - About me\e[0m\n  2 - Projects\n  3 - Skills\n  4 - Contact";;
      2) echo -e "  0 - Home\n  1 - About me\n\e[1m  2 - Projects\e[0m\n  3 - Skills\n  4 - Contact";;
      3) echo -e "  0 - Home\n  1 - About me\n  2 - Projects\n\e[1m  3 - Skills\e[0m\n  4 - Contact";;
      4) echo -e "  0 - Home\n  1 - About me\n  2 - Projects\n  3 - Skills\n\e[1m  4 - Contact\e[0m";;
    esac
}
content=$(landing_page_content);

trap on_resize SIGWINCH
echo ">> Redimensionne ta fenêtre…"
while true; do
    [[ "$resize_needed" -eq 1 ]] && {
        rows=$(tput lines)
        cols=$(tput cols)
  	clear
    total_width=$(( cols <   150 ? cols : 150 ))
	  draw_box_content $total_width $rows $cols
        resize_needed=0
    }

    key=$(get_key)
    case "$key" in
        0) content=$(landing_page_content); page=0;resize_needed=1;;
        1) content=$(about_page_content); page=1;resize_needed=1;;
        2) content=$(projects_page_content); page=2;resize_needed=1;;
        3) content=$(skills_page_content); page=3;resize_needed=1;;
        4) content=$(contact_page_content); page=4;resize_needed=1;;
        q|Q) clear; exit 0;;
    esac
done

