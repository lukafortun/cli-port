#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/core/ui.sh"
source "$BASE_DIR/core/input.sh"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/fold.sh"

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
      0) echo -e "\x1b[31;4;1m  0 - Home\e[0m\n  1 - About me\n  2 - Projects\n  3 - Skills\n  4 - Contact";;
      1) echo -e "  0 - Home\n\x1b[31;4;1m  1 - About me\e[0m\n  2 - Projects\n  3 - Skills\n  4 - Contact";;
      2) echo -e "  0 - Home\n  1 - About me\n\x1b[31;4;1m  2 - Projects\e[0m\n  3 - Skills\n  4 - Contact";;
      3) echo -e "  0 - Home\n  1 - About me\n  2 - Projects\n\x1b[31;4;1m  3 - Skills\e[0m\n  4 - Contact";;
      4) echo -e "  0 - Home\n  1 - About me\n  2 - Projects\n  3 - Skills\n\x1b[31;4;1m  4 - Contact\e[0m";;
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

