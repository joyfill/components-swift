# Joyfill iOS SDK Documentation

This directory contains documentation for the Joyfill iOS SDK development and release processes.

## Documents

### Release Process

- **[iOS_RELEASE_AUTOMATION.md](./iOS_RELEASE_AUTOMATION.md)** - Guide to the iOS release process
  - How releases are cut (manually) and what automation the published release triggers
  - Workflow and helper-script reference
  - Troubleshooting guide and manual fallback

- **[KOTLIN_RELEASE_PROCESS.md](./KOTLIN_RELEASE_PROCESS.md)** - Documentation of the Kotlin SDK release process (reference)
  - Serves as the inspiration for iOS release automation
  - Details the Kotlin workflow components
  - Useful for understanding the overall approach

## Quick Start: Releasing a New Version

1. **Update `CHANGELOG.md`** on `main` with a section for the new version.

2. **Create and push the tag** (bare version, no `v` prefix, matching existing tags):
   ```bash
   git tag -a 3.0.0-rc25 -m "Release 3.0.0-rc25"
   git push origin 3.0.0-rc25
   ```

3. **Publish the GitHub Release** for that tag, pasting the changelog section as the body.
   Use `### Added` / `### Changed` / `### Fixed` headings and omit any `**Release Date:**`
   line — the automation generates it.

4. **Wait for automation.** Publishing the release runs `update-docs.yml`, which opens:
   - a release-notes PR on `joyfill/docs`
   - a DocC API-reference PR on `joyfill/api-references`

5. **Merge those two PRs** to publish the documentation.

Tag creation, GitHub Release creation, and CocoaPods publishing are **not** automated.

## Workflow Files

- `.github/workflows/update-docs.yml` - Post-release docs + API references automation
- `.github/workflows/api-references.yml` - Generates DocC documentation (called by the above)
- `.github/workflows/pr_pipeline_workflow.yml` - CI on pull requests (not release-related)

## Helper Scripts

- `scripts/update_release_mdx.sh` / `scripts/update_release_mdx.py` - Insert a styled
  release-notes entry into the docs site's `RELEASE_NOTES.mdx`

## Prerequisites

### Required GitHub Secret

- `UPDATE_DOCS_TOKEN` - Write access to `joyfill/api-references` and `joyfill/docs`

See [iOS_RELEASE_AUTOMATION.md](./iOS_RELEASE_AUTOMATION.md#prerequisites) for detailed setup instructions.

## Need Help?

- For release automation issues, see [Troubleshooting](./iOS_RELEASE_AUTOMATION.md#troubleshooting)
- For the manual process, see [Manual fallback](./iOS_RELEASE_AUTOMATION.md#manual-fallback)
- For the Kotlin process, see [KOTLIN_RELEASE_PROCESS.md](./KOTLIN_RELEASE_PROCESS.md)
