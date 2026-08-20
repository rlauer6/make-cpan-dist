# CPAN::Maker 2.0.9 Release Notes

**Release Date:** 2026-08-20
**Distribution:** CPAN-Maker
**Version:** 2.0.9

---

## Overview

This release adds Git provenance variables to the `CPAN::Maker`
module, adds `File::ShareDir::Install` as an explicit runtime
dependency, and includes build infrastructure improvements via
`CPAN::Maker::Bootstrapper`.

---

## What's New

### New Variables in `CPAN::Maker`

Two new package-level variables have been added to `CPAN::Maker` to
expose Git provenance information at runtime:

- **`$CPAN::Maker::GIT_SHA`** — the Git commit SHA at build time,
  populated from the `@GIT_SHA@` template variable.  `-
  **`$CPAN::Maker::GIT_DIRTY`** — indicates whether the working tree
  was dirty at build time, populated from the `@GIT_DIRTY@` template
  variable.

These variables complement the existing `$VERSION` and allow consumers
to determine the exact source state from which a given installed copy
was built.

---

## Dependency Changes

### New Runtime Dependency

- **`File::ShareDir::Install`** — added as an explicit runtime
  requirement in both `cpanfile` and the `requires` file. This module
  was already referenced in the generated `Makefile.PL` but was not
  previously declared as a formal dependency.

---

## Build Infrastructure

### `builder` Script Refactored

The CI `builder` script has been updated by
`CPAN::Maker::Bootstrapper` with the following changes:

- The `install_deps` function has been renamed to
  **`install_build_deps`** to better reflect its scope.
- Build dependencies are now installed into Perl's global include path
  using a dedicated `cpanfile.build` file rather than reusing the
  runtime `cpanfile`.
- The list of `EXTRA_DEPS` has been trimmed to only
  `CPAN::Maker::Bootstrapper`; other previously hardcoded extras
  (`File::ShareDir`, `File::ShareDir::Install`, `Pod::Markdown`,
  `Markdown::Render`, `CPAN::Maker`) are no longer forced into the
  build dependency set.
- A guard is added to ensure `build-requires` always contains at least
  `CPAN::Maker::Bootstrapper`, with a warning if the file is absent or
  missing that entry.
- `PERL5LIB` is now explicitly exported as `$(pwd)/local/lib/perl5`
  before invoking `make`.
- The installer invocations for both `cpanm` and `cpm` now use the
  generated `cpanfile.build` explicitly via `--cpanfile
  cpanfile.build`.

### `perl.mk` Updated

- The `local` order-only prerequisite on the `%.pm` and `%.pl` pattern
  rules is now conditional on `$(syntax_on)`, avoiding an unnecessary
  dependency on the `local` target when syntax checking is disabled.

---

## Files Changed

| File | Change |
|---|---|
| `lib/CPAN/Maker.pm.in` | Added `$GIT_SHA` and `$GIT_DIRTY` package variables |
| `cpanfile` | Added `File::ShareDir::Install` requirement |
| `requires` | Added `File::ShareDir::Install` |
| `builder` | Refactored build dependency installation; renamed `install_deps` → `install_build_deps` |
| `.includes/perl.mk` | Made `local` prerequisite conditional on `syntax_on` |
| `VERSION` | Bumped to `2.0.9` |

---

## Upgrading

No breaking changes are introduced in this release. Consumers who
install `CPAN::Maker` from CPAN will now have
`File::ShareDir::Install` declared as an explicit dependency and can
rely on it being present.
