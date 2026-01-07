#!/bin/sh
# scripts/update_release_mdx.sh

CHANGELOG_SOURCE=$1   # The file containing ONLY the new release info
TARGET_MDX=$2         # The existing docs file to update

# 1. Define styling logic
apply_styles() {
    awk '
    BEGIN {
      added = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #10b981'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#10b981'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"'}}>ADDED</span>";
      changed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>CHANGED</span>";
      fixed = "<span style={{display: '"'"'inline-block'"'"', padding: '"'"'4px 12px'"'"', border: '"'"'1.5px solid #f97316'"'"', borderRadius: '"'"'6px'"'"', color: '"'"'#f97316'"'"', fontWeight: '"'"'600'"'"', fontSize: '"'"'13px'"'"', marginBottom: '"'"'12px'"'"', marginTop: '"'"'16px'"'"'}}>FIXED</span>";
    }
    /^## \[[^\]]+\][[:space:]]*$/ {
      line = $0
      sub(/^## \[/, "## ", line)
      sub(/\][[:space:]]*$/, "", line)
      print line
      next
    }
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

# 3. Split the Existing File
FRONTMATTER=$(awk 'BEGIN {count=0} /^---$/ {count++} {print} count==2 {exit}' "$TARGET_MDX")
OLD_CONTENT=$(awk 'BEGIN {count=0; printing=0} /^---$/ {count++} count==2 && printing==0 {printing=1; next} printing==1 {print}' "$TARGET_MDX")

# 4. Format the New Entry
NEW_ENTRY_STYLED=$(apply_styles "$CHANGELOG_SOURCE")

# 5. Reassemble
echo "$FRONTMATTER" > "$TARGET_MDX"
echo "" >> "$TARGET_MDX"
echo "$NEW_ENTRY_STYLED" >> "$TARGET_MDX"
echo "" >> "$TARGET_MDX"
echo "$OLD_CONTENT" >> "$TARGET_MDX"

echo "Successfully inserted new release notes."
