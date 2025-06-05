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















