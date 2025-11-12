# Joyfill iOS SDK Documentation

This directory contains documentation for the Joyfill iOS SDK development and release processes.

## Documents

### Release Process

- **[iOS_RELEASE_AUTOMATION.md](./iOS_RELEASE_AUTOMATION.md)** - Complete guide to the automated iOS release process
  - Overview of the release workflow
  - Step-by-step release instructions
  - Workflow details and configurations
  - Troubleshooting guide
  - Comparison with Kotlin release process

- **[KOTLIN_RELEASE_PROCESS.md](./KOTLIN_RELEASE_PROCESS.md)** - Documentation of the Kotlin SDK release process (reference)
  - Serves as the inspiration for iOS release automation
  - Details the Kotlin workflow components
  - Useful for understanding the overall approach

## Quick Start: Releasing a New Version

1. **Initiate Release**:
   ```bash
   gh workflow run release-prepare.yml -f version=1.0.0
   ```

2. **Fill in Changelog**: Edit the CHANGELOG.md in the generated PR

3. **Merge Release PR**: Review and merge the release PR

4. **Wait for Automation**: The release workflow will automatically:
   - Create git tag
   - Create GitHub release
   - Publish to CocoaPods
   - Generate API documentation
   - Create documentation PRs

5. **Merge Documentation PRs**: Review and merge PRs in:
   - `joyfill/api-references`
   - `joyfill/docs`

## Workflow Files

The release automation consists of these GitHub Actions workflows:

- `.github/workflows/release-prepare.yml` - Prepares release PR
- `.github/workflows/release.yml` - Publishes release
- `.github/workflows/api-references.yml` - Generates DocC documentation
- `.github/workflows/docs.yml` - Updates changelog docs

## Helper Scripts

- `scripts/add_version_to_changelog.sh` - Adds version section to CHANGELOG
- `scripts/create_release_mdx.sh` - Converts CHANGELOG to MDX format

## Prerequisites

### Required GitHub Secrets

- `API_REF_REPO_TOKEN` - Access to api-references and docs repositories
- `COCOAPODS_TRUNK_TOKEN` - CocoaPods publishing token

See [iOS_RELEASE_AUTOMATION.md](./iOS_RELEASE_AUTOMATION.md#prerequisites) for detailed setup instructions.

## Need Help?

- For release automation issues, see [Troubleshooting](./iOS_RELEASE_AUTOMATION.md#troubleshooting)
- For manual release process, see [Manual Release](./iOS_RELEASE_AUTOMATION.md#manual-release-process-fallback)
- For comparison with Kotlin process, see [Comparison](./iOS_RELEASE_AUTOMATION.md#comparison-with-kotlin-release-process)

