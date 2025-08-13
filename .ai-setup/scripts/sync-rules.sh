#!/usr/bin/env bash
set -euo pipefail

SRC=".ai-setup/rules"             # updated source directory
CUR=".cursor/rules"
WIN=".windsurf/rules"
GH=".github/instructions"
CLAUDE="CLAUDE.md"

echo "📁 Creating directories if they don't exist..."
mkdir -p "$CUR" "$WIN" "$GH"

echo "🧹 Cleaning target directories..."
find "$CUR" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
find "$WIN" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
find "$GH" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true

echo "📁 Preparing directories..."
mkdir -p "$CUR" "$WIN/tmp" "$GH/tmp"

echo "🔎 Checking source files in $SRC:"
ls -la "$SRC"

echo "📤 Syncing Cursor (.mdc only)..."
rsync -av \
  --include='*/' \
  --include='*.mdc' \
  --exclude='*' \
  "$SRC"/ "$CUR"/

echo "📤 Syncing Windsurf (.mdc → .md)..."
rsync -av \
  --include='*/' \
  --include='*.mdc' \
  --exclude='*' \
  "$SRC"/ "$WIN/tmp"/

echo "📤 Syncing GitHub Copilot (.mdc → .md)..."
rsync -av \
  --include='*/' \
  --include='*.mdc' \
  --exclude='*' \
  "$SRC"/ "$GH/tmp"/

echo "🔄 Converting and moving for Windsurf..."
for src in "$WIN/tmp/"*.mdc; do
  mv "$src" "$WIN/$(basename "${src%.mdc}.md")"
done
rm -rf "$WIN/tmp"

echo "🔄 Converting and moving for GitHub Copilot..."
for src in "$GH/tmp/"*.mdc; do
  mv "$src" "$GH/$(basename "${src%.mdc}.md")"
done
rm -rf "$GH/tmp"

echo "📄 Generating combined CLAUDE.md..."
{
  for f in "$SRC"/*.mdc; do
    echo -e "\n<!-- Source: $(basename "$f") -->"
    cat "$f"
  done
} > "$CLAUDE"

echo "✅ Sync complete! Cursor has .mdc, Windsurf has .md, GitHub Copilot has .md, and CLAUDE.md is updated."
