# iOS SDK Release Automation

## Overview

This document describes the automated release process for the Joyfill iOS SDK. The automation is inspired by the Kotlin SDK release process and adapted for iOS/Swift development.

## Release Workflow Architecture

The release automation consists of four main GitHub Actions workflows:

1. **release-prepare.yml** - Prepares a release PR
2. **release.yml** - Creates tags, GitHub releases, and publishes to CocoaPods
3. **api-references.yml** - Generates DocC documentation
4. **docs.yml** - Updates changelog documentation

## Prerequisites

### Required Secrets

The following secret must be configured in the GitHub repository:

- `API_REF_REPO_TOKEN`: GitHub Personal Access Token with access to:
  - `joyfill/api-references` repository
  - `joyfill/docs` repository
  - Requires `repo` scope for private repositories or `public_repo` for public ones

### Repository Structure

```
components-swift/
├── .github/
│   └── workflows/
│       ├── release-prepare.yml
│       ├── release.yml
│       ├── api-references.yml
│       └── docs.yml
├── scripts/
│   ├── add_version_to_changelog.sh
│   └── create_release_mdx.sh
├── CHANGELOG.md
├── Package.swift
└── Joyfill.podspec
```

## Complete Release Flow

### Step 1: Initiate Release Preparation

**Action**: Manually trigger the `release-prepare.yml` workflow

```bash
# Via GitHub UI:
# Actions → Prepare iOS Release → Run workflow → Enter version

# Or via gh CLI:
gh workflow run release-prepare.yml -f version=1.0.0
```

**What Happens**:
1. Verifies version format
2. Adds new version section to `CHANGELOG.md`
3. Creates PR with branch `release/{version}`
4. Triggers API references generation workflow
5. Creates PR in `joyfill/api-references` with DocC documentation

**Output**: Two PRs created:
- Release PR in `components-swift`
- API references PR in `joyfill/api-references`

### Step 2: Fill in Changelog

**Action**: Manually edit the `CHANGELOG.md` in the release PR

Edit the auto-generated sections:
```markdown
## [1.0.0]

### Added
- New feature X
- Support for Y

### Changed
- Improved performance of Z

### Fixed
- Bug fix for issue #123
```

### Step 3: Review and Merge Release PR

**Action**: Review and merge the release PR

**Checklist before merging**:
- [ ] CHANGELOG.md is complete and accurate
- [ ] Version number is correct
- [ ] All tests pass
- [ ] API reference generation succeeded

### Step 4: Automatic Release (Triggered on Merge)

**Trigger**: Merging the release PR automatically triggers `release.yml`

**What Happens Automatically**:

1. **Detect Release PR**
   - Checks if merged branch name matches `release/*`
   - Extracts version number

2. **Create Git Tag**
   - Creates tag `v{version}`
   - Pushes tag to repository

3. **Create GitHub Release**
   - Extracts changelog section for the version
   - Creates GitHub release with:
     - Release notes from CHANGELOG
     - SPM installation instructions
     - Pre-release flag if version contains RC/beta/alpha
   - Makes package automatically available via Swift Package Manager

4. **Create Documentation PR**
   - Triggers `docs.yml` workflow
   - Generates `releases.mdx` from CHANGELOG
   - Creates PR in `joyfill/docs`

**Outputs**:
- Git tag `v{version}` (SPM uses this automatically)
- GitHub Release
- Documentation PR in `joyfill/docs`

### Step 5: Merge Documentation PRs

**Action**: Review and merge documentation PRs

Two PRs need to be merged:
1. API references PR in `joyfill/api-references`
2. Changelog docs PR in `joyfill/docs`

## Workflow Details

### 1. Release Preparation (`release-prepare.yml`)

**Trigger**: Manual workflow dispatch

**Inputs**:
- `version`: Version number (e.g., `1.0.0`, `1.0.0-RC1`, `1.0.0-beta.1`)

**Jobs**:
- `prepare-release`: Updates files and creates PR
- `create-api-references`: Generates DocC documentation (calls `api-references.yml`)

**Runner**: macOS 14

**Permissions**: `contents:write`, `pull-requests:write`

### 2. Release Publishing (`release.yml`)

**Triggers**:
- Manual workflow dispatch
- PR closed on `main` branch (only proceeds if merged and branch matches `release/*`)

**Jobs**:

1. **check-release-pr**
   - Validates the PR is a release PR
   - Extracts version number
   - Runner: Ubuntu

2. **create-tag**
   - Creates and pushes git tag `v{version}`
   - Runner: Ubuntu
   - Permissions: `contents:write`

3. **create-release**
   - Extracts changelog section
   - Creates GitHub release
   - Marks as pre-release if version contains RC/beta/alpha
   - Runner: Ubuntu
   - Permissions: `contents:write`

4. **create-docs-pr**
   - Calls `docs.yml` workflow
   - Creates changelog documentation PR

### 3. API References (`api-references.yml`)

**Type**: Reusable workflow

**Triggers**:
- Manual workflow dispatch
- Called by `release-prepare.yml`

**Inputs**:
- `version`: Version number

**What It Does**:
1. Generates DocC documentation for all modules:
   - Joyfill (main UI library)
   - JoyfillModel
   - JoyfillFormulas
   - JoyfillAPIService

2. Converts DocC archives to static HTML using:
   ```bash
   xcodebuild docbuild -scheme {Module} -destination 'generic/platform=iOS'
   xcrun docc process-archive transform-for-static-hosting \
     {archive} \
     --output-path {output} \
     --hosting-base-path /api-references/ios/{Module}
   ```
   
   **Note**: The `--hosting-base-path` must match the GitHub Pages URL structure (`/api-references/ios/*`) for navigation to work correctly.

3. Copies generated docs to `joyfill/api-references` repository at `ios/{Module}/`
4. Creates PR with the updated documentation

**Runner**: macOS 14

**Requirements**:
- Xcode (latest stable)
- Access to `joyfill/api-references` repository via `API_REF_REPO_TOKEN`

### 4. Changelog Documentation (`docs.yml`)

**Type**: Reusable workflow

**Triggers**:
- Manual workflow dispatch
- Called by `release.yml`

**Inputs**:
- `version`: Version number

**What It Does**:
1. Transforms CHANGELOG.md to docs-compatible MDX format
2. Uses `scripts/create_release_mdx.sh` script
3. Outputs to `ios/changelogs/releases.mdx` in docs repository
4. Creates PR in `joyfill/docs` repository

**Runner**: Ubuntu

**Requirements**:
- Access to `joyfill/docs` repository via `API_REF_REPO_TOKEN`

## Helper Scripts

### `scripts/add_version_to_changelog.sh`

**Purpose**: Prepends a new version section to CHANGELOG.md

**Usage**:
```bash
./scripts/add_version_to_changelog.sh <VERSION> <CHANGELOG_PATH> <TEMP_PATH>
```

**Template**:
```markdown
## [VERSION]

### Added
-

### Changed
-

### Fixed
-
```

### `scripts/create_release_mdx.sh`

**Purpose**: Converts CHANGELOG.md to docs-compatible MDX format

**Usage**:
```bash
./scripts/create_release_mdx.sh <CHANGELOG_MD_PATH> <OUTPUT_MDX_PATH>
```

**Transformations**:
- Adds MDX frontmatter with title, description, and icon
- Removes square brackets from version headers: `## [1.0.0]` → `## 1.0.0`
- Replaces section headers with styled span badges:
  - `### Added` → Styled green badge
  - `### Changed` → Styled orange badge
  - `### Fixed` → Styled orange badge

## Version Management

### Version Format

Supports semantic versioning with pre-release tags:
- Stable: `1.0.0`, `1.2.3`
- Release Candidate: `1.0.0-RC1`, `1.0.0-RC2`
- Beta: `1.0.0-beta.1`, `1.0.0-beta.2`
- Alpha: `1.0.0-alpha.1`, `1.0.0-alpha.2`

### Pre-release Detection

GitHub releases are automatically marked as pre-release if the version contains:
- `RC` (Release Candidate)
- `beta`
- `alpha`

### Version Storage

Versions are managed via **Git Tags**:
- Swift Package Manager uses git tags for versioning
- Format: `v{version}` (e.g., `v1.0.0`)
- Tags are created automatically during the release process
- No version file needed in the repository

## Publishing Targets

### 1. GitHub Releases

**What**: Official releases with changelog and installation instructions

**Access**: Public, available at `https://github.com/joyfill/components-swift/releases`

**Content**:
- Release notes extracted from CHANGELOG
- SPM installation instructions for both Package.swift and Xcode
- Pre-release flag for RC/beta/alpha versions
- Attached assets (if any)

### 2. Swift Package Manager

**What**: Native Swift dependency manager (primary distribution method)

**Installation via Package.swift**:
```swift
dependencies: [
    .package(url: "https://github.com/joyfill/components-swift.git", from: "1.0.0")
]
```

**Installation via Xcode**:
1. File → Add Package Dependencies
2. Enter repository URL
3. Select version

**Note**: SPM automatically uses git tags, no additional publishing step needed

## Documentation Publishing

### API References

**Target**: `joyfill/api-references` repository

**Location**: `ios/{Module}/`

**Format**: Static HTML generated from DocC

**Modules**:
- `ios/Joyfill/` - Main UI library
- `ios/JoyfillModel/` - Data models
- `ios/JoyfillFormulas/` - Formula engine
- `ios/JoyfillAPIService/` - API client

**Hosting**: Published via GitHub Pages at `https://joyfill.github.io/api-references/`

**Base Paths** (configured for proper navigation):
- `/api-references/ios/Joyfill` → https://joyfill.github.io/api-references/ios/Joyfill/
- `/api-references/ios/JoyfillModel` → https://joyfill.github.io/api-references/ios/JoyfillModel/
- `/api-references/ios/JoyfillFormulas` → https://joyfill.github.io/api-references/ios/JoyfillFormulas/
- `/api-references/ios/JoyfillAPIService` → https://joyfill.github.io/api-references/ios/JoyfillAPIService/

**Important**: The hosting base paths must match the GitHub Pages URL structure for internal navigation and links to work correctly.

### Changelog Documentation

**Target**: `joyfill/docs` repository

**Location**: `ios/changelogs/releases.mdx`

**Format**: MDX (Markdown with JSX)

**Content**: Complete changelog with styled sections

## Troubleshooting

### Release PR Not Triggering Release

**Problem**: Merged PR but no release was created

**Solutions**:
1. Check if branch name matches `release/*` pattern
2. Verify PR was merged (not closed without merging)
3. Check workflow logs in Actions tab
4. Manually trigger `release.yml` if needed

### DocC Generation Fails

**Problem**: API references workflow fails during DocC generation

**Solutions**:
1. Check Xcode version compatibility
2. Verify all schemes are shared (required for xcodebuild)
3. Check for compilation errors in the code
4. Ensure all modules have public APIs to document

### Documentation Links Not Working

**Problem**: Navigation and internal links broken in published documentation

**Solution**:
1. Verify hosting base paths match GitHub Pages structure
2. Should be `/api-references/ios/{Module}` not `/reference/ios/{Module}`
3. Check the `--hosting-base-path` parameter in `api-references.yml`
4. Regenerate documentation if paths were incorrect

### PR Creation in External Repos Fails

**Problem**: Cannot create PRs in api-references or docs repos

**Solutions**:
1. Verify `API_REF_REPO_TOKEN` secret exists
2. Check token has required permissions (`repo` scope)
3. Verify token hasn't expired
4. Ensure token owner has write access to target repos

## Manual Release Process (Fallback)

If automation fails, here's the manual process:

1. **Update CHANGELOG**:
   ```bash
   # Update CHANGELOG.md
   git add CHANGELOG.md
   git commit -m "chore: bump version to X.Y.Z"
   git push origin main
   ```

2. **Create Tag**:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

3. **Create GitHub Release**:
   - Go to Releases → Draft a new release
   - Choose tag vX.Y.Z
   - Copy changelog content
   - Publish release

4. **Generate DocC**:
   ```bash
   xcodebuild docbuild -scheme Joyfill -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData
   # Find .doccarchive and convert to static HTML
   xcrun docc process-archive transform-for-static-hosting ...
   ```

5. **Update Documentation**:
   - Manually create PRs in api-references and docs repos

## Comparison with Kotlin Release Process

### Similarities

1. **PR-based workflow**: Both use release PRs for review
2. **Automated tagging**: Both create git tags automatically
3. **Multi-repository**: Both update external documentation repos
4. **Changelog automation**: Both use scripts to manage CHANGELOG
5. **Pre-release detection**: Both auto-detect RC/beta/alpha versions

### Differences

| Aspect | Kotlin | iOS |
|--------|--------|-----|
| **Package Registry** | Maven Central | GitHub Releases |
| **Doc Generator** | Dokka | DocC |
| **Version File** | gradle/versions/joyfill.toml | Git tags only |
| **Primary Package Manager** | Gradle/Maven | SPM (git tags) |
| **Build Environment** | JVM (Ubuntu) | Xcode (macOS) |
| **Artifact Publishing** | Maven Central push | Git tag (automatic) |

### iOS-Specific Considerations

1. **macOS runners required**: DocC generation requires Xcode on macOS
2. **Git tags as versions**: SPM uses git tags exclusively, no version file needed
3. **DocC output format**: Static HTML with specific hosting paths for each module
4. **GitHub Pages hosting**: Base paths must match deployment URL structure (`/api-references/ios/*`)
5. **Scheme sharing**: Xcode schemes must be shared for CI
6. **Simplified publishing**: No package registry push needed, git tag is sufficient
7. **Navigation dependencies**: Internal doc links rely on correct hosting base paths

## Best Practices

1. **Test locally before releasing**:
   ```bash
   # Test SPM build
   swift build
   
   # Run tests
   swift test
   
   # Test DocC generation with correct hosting paths
   xcodebuild docbuild -scheme Joyfill -destination 'generic/platform=iOS' \
     -derivedDataPath ./DerivedData
   
   # Test static HTML conversion (optional)
   xcrun docc process-archive transform-for-static-hosting \
     "DerivedData/Build/Products/Debug-iphoneos/Joyfill.doccarchive" \
     --output-path ./test-output \
     --hosting-base-path /api-references/ios/Joyfill
   ```

2. **Use semantic versioning**: Follow semver.org guidelines

3. **Write clear changelog entries**: Focus on user impact

4. **Review API references**: Check generated documentation before merging PR
   - Verify navigation works in the PR preview
   - Check internal links
   - Confirm hosting paths are correct

5. **Test pre-releases**: Use RC/beta/alpha for testing before stable

6. **Keep documentation in sync**: Merge docs PRs promptly after release

7. **Verify GitHub Pages deployment**: After merging docs PR, check live URLs:
   - https://joyfill.github.io/api-references/ios/Joyfill/
   - https://joyfill.github.io/api-references/ios/JoyfillModel/
   - https://joyfill.github.io/api-references/ios/JoyfillFormulas/
   - https://joyfill.github.io/api-references/ios/JoyfillAPIService/

## Future Enhancements

Potential improvements to consider:

1. **Automated testing**: Run full test suite before release
2. **Release notes generation**: Auto-generate from commit messages
3. **Slack notifications**: Notify team of releases
4. **Version bump PR**: Auto-create version bump PRs on schedule
5. **Binary framework**: Generate and attach XCFramework to releases
6. **License validation**: Verify license headers before release
7. **API compatibility check**: Detect breaking changes automatically

## References

- Kotlin Release PR: https://github.com/joyfill/components-kotlin/pull/376
- DocC Documentation: https://developer.apple.com/documentation/docc
- CocoaPods Guides: https://guides.cocoapods.org/
- Swift Package Manager: https://swift.org/package-manager/
- GitHub Actions: https://docs.github.com/en/actions

## Support

For issues with the release automation:
1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Consult the Kotlin release process for reference
4. Contact DevOps team for secrets/permissions issues

