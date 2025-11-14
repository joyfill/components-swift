#!/bin/sh
# create_release_mdx.sh — Generate a docs-compatible releases.mdx from a CHANGELOG
#
# POSIX sh script. Requires common POSIX utilities and awk.
#
# Usage:
#   ./create_release_mdx.sh <CHANGELOG_MD_PATH> <OUTPUT_MDX_PATH>
#
# Arguments:
#   CHANGELOG_MD_PATH  Path to source CHANGELOG.md
#   OUTPUT_MDX_PATH    Destination path for generated releases.mdx
#
# Behavior:
#   - Writes a fixed MDX frontmatter (see HEADER below) to OUTPUT.
#   - Transforms the CHANGELOG content so it renders correctly on the docs site:
#     * Normalize version H2 headers: "## [x.y.z]" -> "## x.y.z"
#     * Replace section H3 ("### Added/Changed/Fixed") with styled <span> badges.
#   - Leaves all other content untouched.
#
# Exit codes:
#   0 on success; non-zero if any command in the pipeline fails.
#
# Example:
#   ./create_release_mdx.sh ./CHANGELOG.md ./docs/ios/changelogs/releases.mdx

HEADER="---
title: \"Release Notes\"
description: \"Complete changelog of Joyfill iOS SDK releases\"
icon: \"apple\"
---
"

CHANGELOG=$1
OUTPUT=$2

mkdir -p "$(dirname "$OUTPUT")"
# Use the frontmatter (first 5 lines) from the template and append the raw CHANGELOG content
echo "$HEADER" > "$OUTPUT"
# Transform CHANGELOG.md:
# - Remove square brackets around versions in H2 (## [x.y.z] -> ## x.y.z)
# - Replace section H3 (### Added/Changed/Fixed) with styled span badges used by the docs site
awk '
    BEGIN {
      added = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #10b981'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#10b981'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"'}}>ADDED</span>";
      changed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>CHANGED</span>";
      fixed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>FIXED</span>";
    }
    # Strip square brackets around version headings like: ## [2.0.0-RC7]
    /^## \[[^\]]+\][[:space:]]*$/ {
      line = $0
      sub(/^## \[/, "## ", line)
      sub(/\][[:space:]]*$/, "", line)
      print line
      next
    }
    # Replace section headers with styled badges
    /^###[[:space:]]+Added[[:space:]]*$/   { print added;   print ""; next }
    /^###[[:space:]]+Changed[[:space:]]*$/ { print changed; print ""; next }
    /^###[[:space:]]+Fixed[[:space:]]*$/   { print fixed;   print ""; next }
    # Default: print the line as-is
    { print }
' "$CHANGELOG" >> "$OUTPUT"

