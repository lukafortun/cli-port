#!/usr/bin/env bash

show_help() {
  echo "Usage: $0 -i input_file -o output_file"
  echo
  echo "Flags:"
  echo "  -i    Input file (main script to flatten)"
  echo "  -o    Output file (where to save the flattened script)"
  echo "  -h    Show this help message"
  exit 1
}

while getopts "i:o:h" opt; do
  case ${opt} in
    i) INPUT_FILE="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    h) show_help ;;
    *) show_help ;;
  esac
done

if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" ]]; then
  echo "Flags -i and -o are required."
  show_help
fi

BASE_DIR="$(cd "$(dirname "$INPUT_FILE")" && pwd)"

cp "$INPUT_FILE" "$OUTPUT_FILE" || { echo "File not found"; exit 1; }

inline_sources() {
  local file=$1
  local temp_file=$(mktemp)

  while IFS= read -r line; do
    if [[ "$line" =~ ^source\ \"\$BASE_DIR/(.*)\"$ ]]; then
      src_path="$BASE_DIR/${BASH_REMATCH[1]}"
      if [[ -f "$src_path" ]]; then
        echo "# BEGIN ${src_path}" >> "$temp_file"
        cat "$src_path" >> "$temp_file"
        echo "# END ${src_path}" >> "$temp_file"
      else
        echo "File not found : $src_path" >&2
        echo "$line" >> "$temp_file"
      fi
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$file"

  mv "$temp_file" "$file"
}

while grep -q 'source "\$BASE_DIR/' "$OUTPUT_FILE"; do
  inline_sources "$OUTPUT_FILE"
done

echo "Files merged : $OUTPUT_FILE"
