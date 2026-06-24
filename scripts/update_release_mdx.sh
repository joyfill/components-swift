#!/bin/sh
# Delegates to Python — avoids dash/awk quoting bugs and maps GitHub release text to docs badges.
set -e
dir=$(dirname "$0")
exec python3 "$dir/update_release_mdx.py" "$@"
