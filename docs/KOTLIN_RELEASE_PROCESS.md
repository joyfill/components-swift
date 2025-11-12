# Kotlin SDK Release Process Documentation

## Overview
This document describes the automated release process implemented in the Kotlin SDK (components-kotlin repository), which serves as the reference for the iOS SDK release automation.

## Release Workflow Components

### 1. Release Preparation (`release-prepare.yml`)
**Trigger**: Manual workflow dispatch
**Input**: Version string (e.g., `2.0.0-RC8`)

**Actions**:
- Updates `gradle/versions/joyfill.toml` with new version
- Updates `CHANGELOG.md` by adding a new version section using `scripts/add_version_to_changelog.sh`
- Creates a PR with branch `release/{version}` targeting `main`
- Automatically triggers API reference generation workflow

**Permissions**: `contents:write`, `pull-requests:write`

### 2. Release Publishing (`release.yml`)
**Triggers**: 
- Manual workflow dispatch
- PR closed on `main` branch

**Actions**:
1. **Check Release PR**: Detects if merged PR branch matches `release/*` pattern and extracts version
2. **Create Tag**: Creates and pushes git tag `v{version}` (this triggers Maven publishing)
3. **Create GitHub Release**: 
   - Extracts changelog section for the specific version
   - Creates GitHub release
   - Marks as prerelease if version contains `RC`, `beta`, or `alpha`
4. **Create Docs PR**: Calls the docs workflow to update changelog documentation

**Permissions**: `contents:write`

### 3. Maven Publishing (`maven-publish.yml`)
**Triggers**: 
- Manual workflow dispatch
- Push of any tag (`*`)

**Actions**:
- Publishes artifacts to Maven Central via `./gradlew publishAllToMavenCentral`
- Uses signing keys and Maven credentials from secrets

**Environment**: Java 17 (Corretto), Ubuntu

**Secrets Used**:
- `SIGNING_KEY`: GPG signing key for Maven artifacts
- `SIGNING_PASSWORD`: GPG key password
- `MVN_USERNAME`: Maven Central username
- `MVN_PASSWORD`: Maven Central password
- `LICENSE_PUBLIC_KEY`: License public key

### 4. API References (`api-references.yml`)
**Type**: Reusable workflow
**Input**: `version` (string)

**Actions**:
- Checks out `joyfill/api-references` repository
- Generates Dokka HTML documentation via `./gradlew dokkaHtmlMultiModule`
- Moves generated docs to `reference/kotlin` directory
- Creates PR in `joyfill/api-references` if changes are detected

**Environment**: Java 17 (Corretto), Ubuntu
**Secrets**: `API_REF_REPO_TOKEN`

### 5. Changelog Documentation (`docs.yml`)
**Type**: Reusable workflow
**Input**: `version` (string)

**Actions**:
- Checks out `joyfill/docs` repository
- Generates `releases.mdx` via `scripts/create_release_mdx.sh`
- Transforms CHANGELOG.md into docs-compatible MDX format
- Creates PR in `joyfill/docs` if changes are detected

**Environment**: Ubuntu
**Secrets**: `API_REF_REPO_TOKEN`

## Helper Scripts

### `scripts/add_version_to_changelog.sh`
Prepends a new version section to CHANGELOG.md with template structure:
- Added section
- Changed section
- Fixed section

### `scripts/create_release_mdx.sh`
Transforms CHANGELOG.md into docs-compatible releases.mdx:
- Adds MDX frontmatter
- Normalizes version headers (removes square brackets)
- Replaces section headers with styled span badges
- Compatible with the docs site rendering

## Complete Release Flow

```
1. Run release-prepare.yml with version number
   ↓
2. Review and merge the release/{version} PR
   ↓
3. release.yml automatically triggers on PR merge
   ↓
4. Git tag v{version} is created
   ↓
5. maven-publish.yml triggers on tag creation
   ↓
6. Artifacts published to Maven Central
   ↓
7. GitHub Release created with changelog
   ↓
8. API references PR created in joyfill/api-references
   ↓
9. Changelog docs PR created in joyfill/docs
```

## Key Design Principles

1. **Automation First**: Minimal manual intervention required
2. **PR-Based**: All changes go through PR review
3. **Versioned Releases**: Clear version management
4. **Documentation Sync**: API references and changelog automatically updated
5. **Multi-Repository**: Coordinates changes across multiple repositories
6. **Prerelease Support**: Automatic detection of RC, beta, alpha versions

## Secrets Management

All workflows use GitHub Actions secrets for sensitive data:
- Repository access tokens for cross-repo operations
- Signing keys for artifact publishing
- Maven credentials for Central publishing

## Testing Workflows

The repository also includes comprehensive testing workflows:
- `tests.yml`: Latest SDK tests (iOS and JVM)
- `tests-legacy.yml`: Legacy module tests
- `tests-wisdom.yml`: Wisdom module tests
- `sample.yml`: Sample application builds

These run on every push to main and on all PRs.

## References

- PR: https://github.com/joyfill/components-kotlin/pull/376
- Original documentation: See `docs/ci.md` in components-kotlin repository

