# CPAN::Maker 2.0.7 Release Notes

**Release Date:** 2026-08-05
**Distribution:** CPAN-Maker-2.0.7.tar.gz

---

## Overview

This release delivers a collection of bug fixes and robustness
improvements across the core library, the build toolchain, and the CI
infrastructure. The primary focus is on correctness in distribution
staging, dependency file handling, and build tooling hygiene.

---

## Bug Fixes

### `CPAN::Maker` (`lib/CPAN/Maker.pm`)

- **`_set_log_level`:** Fixed a missing `return` statement in the
  `else` branch of the `choose` block, which could produce unexpected
  behaviour when an unrecognised log level was supplied.
- **`stage_distribution`:** Ensured that `$builddir` is always set
  (falls back to `getcwd`) before iterating over the extra-files list,
  preventing a potential uninitialized-value error during distribution
  staging.
- **`stage_distribution`:** Added diagnostic `debug` log statements
  throughout the extra-files processing path to aid troubleshooting.

### `CPAN::Maker::Role::FileUtils` (`lib/CPAN/Maker/Role/FileUtils.pm`)

- **`fetch_file_list`:** `$project_root` now falls back to `getcwd`
  when not explicitly provided, preventing undef errors when called
  without a project root argument.
- **`fetch_file_list`:** Removed the code that stripped the project
  root prefix from expanded file paths. This stripping was incorrect
  and caused file-copy operations in `stage_distribution` to fail.
- **`fetch_file_list`:** Added `debug` logging of arguments and the
  final expanded file list.

---

## Toolchain & Build Infrastructure

### `bin/cpan-maker`

- Fixed `MODULINO_WRAPPER`: the value was incorrectly set to the
  module name (`CPAN::Maker`) rather than the script name
  (`cpan-maker`).

### `Makefile`

- **`cpanfile` generation** refactored into three intermediate targets
  (`cpanfile.requires`, `cpanfile.suggests`, `cpanfile.recommends`),
  each produced by a dedicated `cpan-maker create-cpanfile
  --dependency-type` invocation. The final `cpanfile` is assembled by
  concatenating them. This properly supports `suggests` and
  `recommends` dependency tiers alongside `requires`.
- **`$(TARBALL)` target:** `update-available` is now an order-only
  prerequisite (`|`), removing it from the dependency hash that
  affected rebuild decisions.
- **`all` target:** Simplified to depend directly on `$(TARBALL)`;
  `update-available` is no longer a prerequisite of `all`.
- **`deps.mk`:** Now depends on the built source files (`$(SOURCE_FILES)`) rather than `.pm.in` templates, correcting the dependency tracking.
- **`README.md`:** `$(MD_UTILS)` invocation now uses `|| true` to
  avoid failing the build on non-fatal rendering errors.
- **`modulino` target:** Replaced the inline recipe with `-include
  .includes/modulino.mk`.
- **Bash completion:** Added `-include .includes/bash-completion.mk`.
- **`MIN_PERL_VERSION_FLAG`:** Guards the `buildspec.yml` read with
  `test -e buildspec.yml` to avoid errors in projects without a
  buildspec.
- **Intermediate files** `requires.raw`, `recommends.raw`,
  `suggests.raw`, and `test-requires.raw` are now declared
  `.INTERMEDIATE`.
- **`test-requires` filter step:** `cmb filter` is now called
  unconditionally (the `if test -e "$@.xxx"` guard that previously
  caused it to be skipped on a first run has been removed).
- **`build-ci` target:** The Docker invocation now mounts the current
  working directory into the container and passes `REPO` via the
  environment, enabling local volume-based builds without requiring a
  network clone.

### `.includes/help.mk`

- Help output is now written to a temporary file and piped through
  `$PAGER` (defaulting to `less`, then `more`, then `cat`), making it
  usable in terminals with limited scroll-back.
- Added documentation for `SYNTAX_CHECKING=OFF` and `SKIP_TESTS=1`
  variables.
- Removed `MODULINO_NAME` from the variables list (no longer applicable).

### `.includes/perl.mk`

- `perlcritic` invocations in the `critic` target now pass `--theme`
  and `--severity` flags consistently.

### `.includes/release-notes.mk`

- `release-notes` target now supports a `DRYRUN` environment variable,
  passing `--dryrun` to `cmb release-notes` when set.
- Added `## …` doc comment so the target appears in `make help`
  output.

### `.includes/update.mk`

- Added `bash-completion.mk` and `modulino.mk` to the `MANAGED_FILES`
  list so they are kept in sync by `make update`.
- The `update` target now updates `.includes/` files **before**
  refreshing the `Makefile`, ensuring the post-update hook runs
  against current include files.

### `builder` (CI script)

- Default installer flags updated to include `--no-prebuilt` to ensure
  packages are always compiled from source in CI.
- Improved handling of the case where the repository directory already
  exists locally (avoids redundant `git clone`).
- Branch checkout is now skipped when running against a volume-mounted
  local directory (no `.git` checkout needed).
- Final `make` invocation passes `CMB_VERSION_DRIFT=ignore NO_ECHO=`
  for CI compatibility.
- Improved inline documentation with a worked local Docker example.

### `cpanfile`

- Added `recommends "JSON::Validator", "5.15"` — the validator is
  optional at runtime but recommended for `buildspec.yml` validation.

### `.gitignore`

- Added `buildspec.yml.current` to prevent the normalised buildspec
  copy from being committed accidentally.

---

## Dependency Changes

| Module | Change | Type |
|---|---|---|
| `JSON::Validator` ≥ 5.15 | Added | `recommends` |

---

## Upgrade Notes

- The `cpanfile` generation process has changed: projects using a
  custom `cpanfile` target in `project.mk` should review the new
  three-stage approach to avoid conflicts.
- If you use `make update` to synchronise bootstrapper files,
  `bash-completion.mk` and `modulino.mk` are now managed files and
  will be updated automatically.
- Run `make update` after upgrading to pull in the latest managed
  `.includes/` files from `CPAN::Maker::Bootstrapper`.
