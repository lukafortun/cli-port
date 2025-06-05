get_key() {
  stty -echo -icanon time 0 min 1
  local key
  IFS= read -rsn1 -t 0.1 key
  stty sane
  echo "$key"
}

