#!/usr/bin/env bash
set -euo pipefail

if [ ! -x "$0" ]; then
    chmod +x "$0" || true
fi

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null && pwd)"
core_proj="red-core"

cd "$root_dir"

projects=()
while IFS= read -r -d '' dir; do
    name="$(basename "$dir")"
    if [[ "$name" != "$core_proj" ]]; then
        projects+=("$name")
    fi
done < <(find . -maxdepth 1 -type d ! -name "." -print0)

echo "Select the target project to link 'Core':"
for i in "${!projects[@]}"; do
    printf "  %d) %s\n" $((i+1)) "${projects[i]}"
done

read -rp "Enter choice [1-${#projects[@]}]: " sel
if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel<1 || sel>${#projects[@]} )); then
    echo "ERROR: Invalid option." >&2
    exit 1
fi
target="${projects[sel-1]}"

source="$root_dir/$core_proj/Core"
dest="$root_dir/$target/Assets/Core"

echo
echo "Source:      $source"
echo "Destination: $dest"
echo

if [[ -L "$dest" || -d "$dest" ]]; then
    echo "Removing existing link/directory..."
    rm -rf "$dest"
fi

echo "Creating symlink..."
if ln -s "$source" "$dest"; then
    echo "SUCCESS: Symlink created at $dest"
else
    echo "ERROR: Failed to create symlink." >&2
    exit 1
fi
