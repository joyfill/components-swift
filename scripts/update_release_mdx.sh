#!/bin/sh
# scripts/update_release_mdx.sh

CHANGELOG_SOURCE=$1   # The file containing ONLY the new release info
TARGET_MDX=$2         # The existing docs file to update

# 1. Define styling logic (CLEANED: No Source Link Here)
apply_styles() {
    awk '
    BEGIN {
      added = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #10b981'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#10b981'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"'}}>ADDED</span>";
      changed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>CHANGED</span>";
      fixed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>FIXED</span>";
    }

    # Clean Header: ## [3.0.0] -> ## 3.0.0
    /^## \[[^\]]+\][[:space:]]*$/ {
      line = $0
      sub(/^## \[/, "## ", line)
      sub(/\][[:space:]]*$/, "", line)
      print line
      print ""
      next
    }
    
    # Fallback Header
    /^## [0-9]/ {
      print $0
      print ""
      next
    }
    
    # Strip unwanted lines from the release body
    /^> Source:/              { next }   # never copy the source link into new entries
    /^\*\*Full Changelog\*\*/ { next }   # GitHub auto-appends this comparison URL
    /^# /                     { next }   # strip top-level # headings (release title)
    # Skip non-version ## headings e.g. "## What's Changed" (GitHub auto-adds this)
    /^## [^0-9\[]/ { next }

    # Badges
    /^###[[:space:]]+Added[[:space:]]*$/   { print added;   print ""; next }
    /^###[[:space:]]+Changed[[:space:]]*$/ { print changed; print ""; next }
    /^###[[:space:]]+Fixed[[:space:]]*$/   { print fixed;   print ""; next }
    
    { print }
    ' "$1"
}

# 2. Check if Target File exists
if [ ! -f "$TARGET_MDX" ]; then
    echo "Error: Target file $TARGET_MDX not found!"
    exit 1
fi

# 3. Format the New Entry into a temp file
NEW_ENTRY_FILE=$(mktemp)
apply_styles "$CHANGELOG_SOURCE" > "$NEW_ENTRY_FILE"

# 4. INJECT AFTER SOURCE LINE
# Reads new content from a file via getline — avoids awk -v mangling backslashes
# (e.g. Swift's \(variable) interpolation would be corrupted by awk -v).
TEMP_FILE=$(mktemp)

awk -v new_file="$NEW_ENTRY_FILE" '
    /^> Source:/ {
        print $0             # Print the existing Source line
        print ""             # Spacer
        while ((getline line < new_file) > 0) {
            print line       # Stream new content line-by-line from file
        }
        print ""             # Spacer
        next
    }
    { print }                # Print every other line normally
' "$TARGET_MDX" > "$TEMP_FILE"

rm -f "$NEW_ENTRY_FILE"

# 5. Overwrite the original file
mv "$TEMP_FILE" "$TARGET_MDX"

echo "Successfully inserted new release notes after the Source line."
