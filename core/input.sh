get_key() {
  IFS= read -rsn1 key
  if [[ $key == $'\e' ]]; then
    IFS= read -rsn2 rest
    key+="$rest"
  fi
  echo "$key"
}
