#!/usr/bin/env bash

# Replaces the references to my_program_name and MyProgram1111111111111111111111111111111111 with the provided name and ID, respectively

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

NAME_FILES=(
  "$ROOT_DIR"/.solitarc.js
  "$ROOT_DIR"/.ammanrc.js
  "$ROOT_DIR"/program/Cargo.toml
  "$ROOT_DIR"/program/Cargo.lock
  "$ROOT_DIR"/yarn.lock
)
NAME_FILES_TS=(
  "$ROOT_DIR"/js/package.json
  "$ROOT_DIR"/package.json
  "$ROOT_DIR"/js/typedoc.json
  "$ROOT_DIR"/yarn.lock
)
ID_FILES=(
  "$ROOT_DIR"/program/src/lib.rs
  "$ROOT_DIR"/.ammanrc.js
)
RENAME_DIRS=(
  "$ROOT_DIR"/js/src
)

OLD_NAME="my_program_name"
OLD_ID="MyProgram1111111111111111111111111111111111"

NEW_NAME=""
NEW_ID=""

print_usage() {
  printf "Usage: \n-n: Name to replace %s \n-i: Base-58 ID to replace %s \n" $OLD_NAME $OLD_ID
}

while getopts 'n:i:r:a:h' flag; do
  case "${flag}" in
  n) NEW_NAME="${OPTARG}" ;;
  i) NEW_ID="${OPTARG}" ;;
  r) OLD_NAME="${OPTARG}" ;;
  a) OLD_ID="${OPTARG}" ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done

OLD_NAME_TS=$(echo "$OLD_NAME" | tr _ -)
NEW_NAME_TS=$(echo "$NEW_NAME" | tr _ -)

if [ "$NEW_ID" == "" ] && [ "$NEW_NAME" == "" ]; then
  print_usage
  exit 1
fi

function replace() {
  if [ "$2" != "" ]; then
    local old=$1
    local new=$2
    shift
    shift
    local arr=("$@")
    for file in "${arr[@]}"; do
      sed -i "" "s/$old/$new/g" "${file}"
    done
    echo "Replaced all $old's with $new!"
  fi
}

function rename() {
  if [ "$2" != "" ]; then
    local old=$1
    local new=$2
    shift
    shift
    local arr=("$@")
    for dir in "${arr[@]}"; do
      mv "${dir}"/"$old".ts "${dir}"/"$new".ts
    done
    echo "Renamed the default files!"
  fi
}

replace "$OLD_ID" "$NEW_ID" "${ID_FILES[@]}"
replace "$OLD_NAME" "$NEW_NAME" "${NAME_FILES[@]}"
replace "$OLD_NAME_TS" "$NEW_NAME_TS" "${NAME_FILES_TS[@]}"
rename "$OLD_NAME_TS" "$NEW_NAME_TS" "${RENAME_DIRS[@]}"
