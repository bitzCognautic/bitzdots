#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"
WIKI_URL="https://github.com/bitzCognautic/bitzdots.wiki.git"

echo "This script pushes prepared wiki content to the GitHub wiki."
echo ""
echo "Prerequisite: Visit https://github.com/bitzCognautic/bitzdots/wiki"
echo "and click 'Create the first page' (save a minimal page)."
echo ""
read -rp "Have you created the first wiki page? (y/N): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 1

TMP="$(mktemp -d)"
trap "rm -rf '$TMP'" EXIT

git clone "$WIKI_URL" "$TMP"
cp "$DIR"/*.md "$TMP/"
cd "$TMP"
git add -A
git commit -m "Populate wiki with full documentation"
git push
echo "Wiki pages pushed successfully!"
