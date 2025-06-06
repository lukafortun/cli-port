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

generate_pages_arrays() {
  local pages_dir="$BASE_DIR/pages"
  echo "PAGE_TITLES=()" > "$pages_dir/_flat_pages.sh"
  echo "PAGE_CONTENTS=()" >> "$pages_dir/_flat_pages.sh"
  for pagefile in "$pages_dir"/*.sh; do
    unset PAGE_TITLE PAGE_CONTENT
    source "$pagefile"
    if [[ -n "$PAGE_TITLE" && -n "$PAGE_CONTENT" ]]; then
      esc_title=$(printf '%q' "$PAGE_TITLE")
      esc_content=$(printf '%q' "$PAGE_CONTENT")
      echo "PAGE_TITLES+=($esc_title)" >> "$pages_dir/_flat_pages.sh"
      echo "PAGE_CONTENTS+=($esc_content)" >> "$pages_dir/_flat_pages.sh"
    fi
  done
}

generate_pages_arrays

sed -i '/^for pagefile in.*; do/,/^done$/c\source "$BASE_DIR/pages/_flat_pages.sh"' "$BASE_DIR/pages.sh"

while grep -q 'source "\$BASE_DIR/' "$OUTPUT_FILE"; do
  inline_sources "$OUTPUT_FILE"
done

echo "Files merged : $OUTPUT_FILE"

rm -f "$BASE_DIR/pages/_flat_pages.sh"
