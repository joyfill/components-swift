# Quick Start: iOS Release Automation

## Prerequisites

Before using the release automation, ensure this secret is configured:

### Configure API_REF_REPO_TOKEN

```bash
# Create a GitHub Personal Access Token with 'repo' scope
# Go to: GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
# Generate new token with 'repo' scope
# Add it as a repository secret named 'API_REF_REPO_TOKEN'
```

The token needs access to:
- `joyfill/api-references` repository
- `joyfill/docs` repository

## Releasing a New Version

### Step 1: Start the Release

Using GitHub CLI:
```bash
gh workflow run release-prepare.yml -f version=1.0.0
```

Or via GitHub UI:
1. Go to **Actions** tab
2. Select **Prepare iOS Release** workflow
3. Click **Run workflow**
4. Enter version number (e.g., `1.0.0`)
5. Click **Run workflow**

### Step 2: Fill in the Changelog

1. Wait for the release PR to be created (usually < 1 minute)
2. Open the PR titled "Release 1.0.0"
3. Edit `CHANGELOG.md` in the PR
4. Fill in the actual changes:

```markdown
## [1.0.0]

### Added
- New table view component with sorting
- Support for custom field validation
- Dark mode support for all UI components

### Changed
- Improved performance of form rendering
- Updated minimum iOS version to 15.0

### Fixed
- Fixed crash when loading large documents
- Resolved memory leak in image picker
```

### Step 3: Review the PRs

Two PRs will be created:

1. **Release PR** (in components-swift)
   - Check version in `Joyfill.podspec`
   - Review `CHANGELOG.md` entries
   - Ensure all tests pass

2. **API References PR** (in joyfill/api-references)
   - Review generated documentation
   - Check that all modules are documented

### Step 4: Merge Release PR

Once everything looks good:
1. Approve the release PR
2. Merge it to `main`

**The rest happens automatically!** 🎉

### Step 5: Monitor Automation

After merging, the automation will:
- ✅ Create git tag `v1.0.0`
- ✅ Create GitHub Release (automatically available for SPM)
- ✅ Create changelog docs PR

Check the Actions tab to monitor progress.

### Step 6: Merge Documentation PRs

After the release automation completes, merge:
1. API references PR in `joyfill/api-references`
2. Changelog docs PR in `joyfill/docs`

## Version Formats

### Stable Release
```bash
gh workflow run release-prepare.yml -f version=1.0.0
```

### Release Candidate
```bash
gh workflow run release-prepare.yml -f version=1.0.0-RC1
```

### Beta Release
```bash
gh workflow run release-prepare.yml -f version=1.0.0-beta.1
```

### Alpha Release
```bash
gh workflow run release-prepare.yml -f version=1.0.0-alpha.1
```

**Note**: RC/beta/alpha versions are automatically marked as pre-release on GitHub.

## Troubleshooting

### Release PR Not Created

Check the workflow logs:
```bash
gh run list --workflow=release-prepare.yml --limit 5
gh run view <RUN_ID>
```

### DocC Generation Failed

Test DocC locally:
```bash
xcodebuild docbuild -scheme Joyfill -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData
```

### PR Not Created in External Repo

Verify the `API_REF_REPO_TOKEN` secret:
- Has correct permissions (`repo` scope)
- Hasn't expired
- Owner has write access to target repos

## Testing the Automation

Before your first production release, test with a dummy version:

```bash
# Create a test release
gh workflow run release-prepare.yml -f version=0.0.1-test

# Follow the process
# After testing, delete the test tag and release
git push --delete origin v0.0.1-test
gh release delete v0.0.1-test
```

## Need More Help?

- 📖 [Complete Documentation](docs/iOS_RELEASE_AUTOMATION.md)
- 🔍 [Troubleshooting Guide](docs/iOS_RELEASE_AUTOMATION.md#troubleshooting)
- 🔄 [Comparison with Kotlin](docs/iOS_RELEASE_AUTOMATION.md#comparison-with-kotlin-release-process)
- 📝 [Manual Release Process](docs/iOS_RELEASE_AUTOMATION.md#manual-release-process-fallback)

## What Gets Published

After a successful release:

- **GitHub Releases**: https://github.com/joyfill/components-swift/releases
- **Swift Package Manager**: Automatically available via git tags
- **API Documentation**: Published to api-references repository
- **Changelog**: Published to docs repository

## Tips

1. **Test locally first**: Always run tests before releasing
2. **Write clear changelog entries**: Focus on user-facing changes
3. **Use semantic versioning**: Follow semver.org guidelines
4. **Review API docs**: Check generated documentation before merging
5. **Communicate releases**: Announce new releases to your team/users

## Example: Full Release

```bash
# 1. Start release
gh workflow run release-prepare.yml -f version=1.2.0

# 2. Wait for PR (check in browser or CLI)
gh pr list --label release

# 3. Edit changelog in the PR
# (Use GitHub UI or gh pr checkout)

# 4. Review and merge
gh pr review <PR_NUMBER> --approve
gh pr merge <PR_NUMBER> --squash

# 5. Monitor release
gh run list --workflow=release.yml --limit 1
gh run watch <RUN_ID>

# 6. Check release
gh release view v1.2.0

# 7. Merge docs PRs
# (In api-references and docs repositories)

# Done! 🎉
```

---

**Questions?** Check the [full documentation](docs/iOS_RELEASE_AUTOMATION.md) or reach out to the team.

