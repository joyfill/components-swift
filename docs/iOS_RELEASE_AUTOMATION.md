# iOS SDK Release Process

## Overview

Releases of the Joyfill iOS SDK are **cut manually**. Publishing the GitHub Release is
the trigger that kicks off all downstream automation: release notes are pushed to the
docs site and DocC API references are regenerated, each as a pull request in its own
repository for a human to review and merge.

There is no automation that creates the tag or the release for you, and no automated
CocoaPods publishing.

```
  You: create tag  ──▶  You: publish GitHub Release
                                    │
                                    │ (release: published)
                                    ▼
                        update-docs.yml
                          ├─▶ create-docs-pr          ──▶ PR on joyfill/docs
                          └─▶ create-api-references    ──▶ PR on joyfill/api-references
                              (calls api-references.yml)
```

## Prerequisites

### Required secret

- `UPDATE_DOCS_TOKEN`: GitHub Personal Access Token with write access to
  - `joyfill/docs`
  - `joyfill/api-references`

  Needs `repo` scope for private repositories, `public_repo` for public ones. Both the
  cross-repo checkout and the PR creation authenticate with this token — the workflows'
  own `GITHUB_TOKEN` is read-only and never writes anything.

### Permissions note

This repository's default workflow permission is **read**
(Settings → Actions → Workflow permissions). A reusable workflow cannot request more
than its caller's token holds, so `api-references.yml` declares `contents: read`. If you
ever add a `contents: write` job to it, every caller breaks with a validation error:

> The nested job '…' is requesting 'contents: write', but is only allowed 'contents: read'.

For the same reason, `update-docs.yml` keeps its `permissions:` block at the **job**
level rather than the workflow level — a workflow-level block also caps the reusable
workflow it calls.

## Cutting a release

### 1. Update `CHANGELOG.md`

Add a section for the new version on `main` and merge it before tagging.

```markdown
## [3.0.0-rc25]

### Added
- ...

### Changed
- ...

### Fixed
- ...
```

### 2. Create and push the tag

Recent releases use a bare version tag with no `v` prefix (`3.0.0-rc24`). Match the
existing convention:

```bash
git checkout main && git pull
git tag -a 3.0.0-rc25 -m "Release 3.0.0-rc25"
git push origin 3.0.0-rc25
```

### 3. Publish the GitHub Release

Releases → Draft a new release → pick the tag → paste the changelog section as the
release body → Publish.

Two things about the body, because it is consumed verbatim by the docs automation:

- Use `### Added` / `### Changed` / `### Fixed` headings — the script converts them to
  styled badges on the docs site.
- Do **not** write a `**Release Date:**` line. The workflow generates it.

Mark it as a pre-release for `-rc`, `-beta`, and `-alpha` versions.

### 4. Review and merge the two generated PRs

Publishing the release opens:

- a PR on `joyfill/docs` adding the release notes to `ios/changelogs/RELEASE_NOTES.mdx`
- a PR on `joyfill/api-references` replacing `ios/{Joyfill,JoyfillModel,JoyfillFormulas,JoyfillAPIService}`
  with freshly generated DocC HTML

Neither publishes anything until you merge it.

## Workflows

### `update-docs.yml` — Post-Release Automation (Docs + API References)

| | |
|---|---|
| Trigger | `release: published`, plus `workflow_dispatch` for testing |
| Runner | `ubuntu-latest` |

**`create-docs-pr`** checks out this repo at the release tag and `joyfill/docs`, renders
the release body through `scripts/update_release_mdx.sh`, and opens a PR.

**`create-api-references`** calls `api-references.yml`, passing the tag as both the
version label and the ref to document.

On manual dispatch, `create-api-references` is **opt-in** via the `run_api_references`
input (default `false`). Leave it off when you are only testing docs formatting —
otherwise a throwaway `3.0.0-test` run burns a macOS runner and opens a real PR on
`joyfill/api-references`.

### `api-references.yml` — Create iOS API References PR

| | |
|---|---|
| Trigger | `workflow_call` (from `update-docs.yml`), or `workflow_dispatch` |
| Runner | `macos-14` |
| Inputs | `version` (required, label only), `ref` (optional, defaults to `main`) |

Runs `xcodebuild docbuild` for `Joyfill`, `JoyfillModel`, `JoyfillFormulas`, and
`JoyfillAPIService`, converts each `.doccarchive` with
`xcrun docc process-archive transform-for-static-hosting --hosting-base-path /api-references/ios/{Module}`,
copies the output into `joyfill/api-references`, and opens a PR.

`ref` controls what actually gets documented. `update-docs.yml` passes the release tag so
the generated docs match the version in the PR title; a bare manual dispatch documents
`main`.

### `pr_pipeline_workflow.yml` — iOS Advanced CI Pipeline

Builds and tests on every pull request. Unrelated to releases, listed here so the
workflow directory is fully accounted for.

## Helper scripts

- `scripts/update_release_mdx.sh` — wrapper invoked by `update-docs.yml`
- `scripts/update_release_mdx.py` — inserts the styled release-notes entry into
  `RELEASE_NOTES.mdx`

## Version management

Swift Package Manager resolves versions from git tags, so the tag **is** the version.
There is no version constant to bump in the source tree.

Supported formats: `3.0.0`, `3.0.0-rc1`, `3.0.0-beta.1`, `3.0.0-alpha.1`.

`Joyfill.podspec` exists but is not wired into any automation and is currently pinned to
`1.2.0`, well behind the SDK. Do not treat it as a release artifact without checking
whether the pod is still published.

## Troubleshooting

### No PRs appeared after publishing a release

1. Check the Actions tab for the `Post-Release Automation` run on the release event.
2. A `create-api-references` job skipped as expected on manual dispatch means
   `run_api_references` was left at `false`.
3. Verify `UPDATE_DOCS_TOKEN` exists and has not expired.

### Workflow fails immediately with a permissions error

See [Permissions note](#permissions-note) — something is requesting `contents: write`
above the caller's cap.

### DocC generation fails

1. Check Xcode version compatibility on the `macos-14` runner.
2. All four schemes must be shared — `xcodebuild` cannot see unshared schemes.
3. Check for compilation errors at the ref being documented.

### Documentation links are broken after publishing

The `--hosting-base-path` must be `/api-references/ios/{Module}`. If it drifts,
navigation and internal links break site-wide; fix the path and regenerate.

### PR creation in `joyfill/docs` or `joyfill/api-references` fails

1. `UPDATE_DOCS_TOKEN` missing, expired, or lacking `repo` scope.
2. Token owner lacks write access to the target repository.
3. A branch from a previous failed run may already exist — `docs-update-{version}` or
   `docs/ios-api-references-{version}`.

## Manual fallback

If the automation is down, both PRs can be produced by hand:

```bash
# API references, per module
xcodebuild docbuild -scheme Joyfill -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData
xcrun docc process-archive transform-for-static-hosting \
  "$(find ./DerivedData -name 'Joyfill.doccarchive' | head -n 1)" \
  --output-path ./docs-output/Joyfill \
  --hosting-base-path /api-references/ios/Joyfill
```

Then copy `docs-output/` into a branch of `joyfill/api-references`, and add the release
notes section to `ios/changelogs/RELEASE_NOTES.mdx` in a branch of `joyfill/docs`.

## References

- [`docs/KOTLIN_RELEASE_PROCESS.md`](./KOTLIN_RELEASE_PROCESS.md) — the Kotlin SDK
  process, kept for reference
- [Swift Package Manager versioning](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)
- [DocC static hosting](https://www.swift.org/documentation/docc/publishing-to-github-pages)
