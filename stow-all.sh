#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./stow-all.sh
  ./stow-all.sh --adopt

Options:
  --adopt   First-time setup. Adopt existing files in $HOME into the stow layout.
EOF
}

mode="restow"

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
    --adopt)
      mode="adopt"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
fi

echo "Pulling latest changes in $repo_dir"
git -C "$repo_dir" pull --ff-only

packages=()
for dir in "$repo_dir"/*/; do
  [[ -d "$dir" ]] || continue
  packages+=("$(basename "$dir")")
done

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No stow packages found in $repo_dir" >&2
  exit 1
fi

echo "Stowing packages: ${packages[*]}"

if [[ "$mode" == "adopt" ]]; then
  stow --dotfiles --adopt --target="$HOME" "${packages[@]}"
else
  stow --dotfiles -R --target="$HOME" "${packages[@]}"
fi
