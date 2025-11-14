#!/bin/sh

VERSION=$1
CHANGELOG_PATH=$2
TEMP_PATH=$3

HEADER="## [$VERSION]

### Added
-

### Changed
-

### Fixed
-
"

echo "$HEADER" | cat - "$CHANGELOG_PATH" > "$TEMP_PATH" && mv "$TEMP_PATH" "$CHANGELOG_PATH"

