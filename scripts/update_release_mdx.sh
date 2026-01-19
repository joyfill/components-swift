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
    
    # SAFETY: Remove any source links if they accidentally exist in the input
    /^> Source:/ { next }

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

# 3. Format the New Entry (This is now just the text/badges)
NEW_ENTRY_STYLED=$(apply_styles "$CHANGELOG_SOURCE")

# 4. INJECT AFTER SOURCE LINE
# This reads the Target File line-by-line. 
# When it sees "> Source:", it prints it, and then IMMEDIATELY prints the new content.
TEMP_FILE=$(mktemp)

awk -v new_content="$NEW_ENTRY_STYLED" '
    /^> Source:/ {
        print $0             # Print the existing Source line
        print ""             # Spacer
        print new_content    # <--- INSERT NEW CONTENT HERE
        print ""             # Spacer
        next
    }
    { print }                # Print every other line normally
' "$TARGET_MDX" > "$TEMP_FILE"

# 5. Overwrite the original file
mv "$TEMP_FILE" "$TARGET_MDX"

echo "Successfully inserted new release notes after the Source line."
