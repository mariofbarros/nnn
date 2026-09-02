# nx

`nx` is a fish CLI, exposed as `flake.homeModules.nx`, that wraps this
repo's day-to-day flake workflow into one command: `nx <subcommand>`. Run
`nx --help` for full docs on every subcommand, or `nx -h` for a one-line
summary of each.

Vendored and trimmed from [Lunobe/Nx](https://github.com/Lunobe/Nx) —
copied into this repo (rather than pulled in as a flake input) since it's
a single person's personal tool with no stability guarantees, and needed
local edits anyway to fit this repo's layout. Its own README says as
much: "I don't know how this will work on your machine."

## What changed from upstream

- **`secret` dropped.** It edits an agenix-encrypted secret; this repo
  doesn't use agenix.
- **`vm push/pull/log/del` dropped.** It backs up a btrfs `~/vmware`
  subvolume to Cloudflare R2 via restic; not applicable here.
- **Package list path/indent.** Upstream expects a flat
  `modules/packages.nix` with `home.packages` at 2-space indent. This
  repo's packages live in `modules/home/apps.nix`, nested one level
  deeper (`flake.homeModules.apps = { pkgs, lib, ... }: { home.packages =
  ... }`), so the bounds-detection and install/uninstall patterns in
  `_impl/helpers-config.nix` and `_impl/cmd-packages.nix` use 4/6-space
  indent instead of upstream's 2/4.
- **No package-list sorting.** Upstream's `nx format` starts by
  alphabetically sorting the package list. This repo's list is grouped
  under `#UTILS`/`#DEVELOPMENT`/`#GAMING`/`#OTHER` comments, which a blind
  sort would scramble (comment lines would all float to the top of the
  block). Dropped from `_impl/cmd-format.nix`; `nx list` still filters out
  blank/comment lines so its output stays just the package names.
  Re-ordering within a category, if wanted, is still manual.
- **No `nix-index-database` comma shorthand.** Upstream uses `, jq` (via
  `programs.nix-index-database.comma.enable`, not an input here) in
  `install`/`search meta`; replaced with `${pkgs.jq}/bin/jq`.
- **`nixos-option` referenced via `pkgs`** in `search option`, rather than
  assumed to be on `$PATH`.
- **Two commands added beyond upstream: `switch` and `noctalia-export`.**
  Ported from this repo's former standalone `nrs`/`noctalia-export` fish
  functions (previously in `modules/home/fish.nix`) into nx's
  dispatcher/style — same `__nx_stage`/`__nx_ok`/`__nx_fail`/`__nx_warn`
  helpers, same `_impl/cmd-*.nix` structure, wired into the same help
  text/completions. `switch` stays deliberately lighter than `deploy` (no
  git staging/commit, no flake check, no scratch-dir build/rollback) —
  it's for iterating locally when you already trust what's about to be
  built. `noctalia-export` also gained a real fix while being ported: the
  original redirected `jq`'s output straight onto the tracked
  `noctalia.json` with `>`, which truncates the file before `jq` even
  runs, so a failing `jq` could wipe it — the exact bug its own comment
  claimed to avoid. It now writes to a scratch file and only `mv`s it
  over the tracked file once the whole export has actually succeeded.

## Wiring

`repoDir`/`hostName` are supplied via `home-manager.extraSpecialArgs` in
`modules/hosts/my-machine/home.nix`, and the module itself is pulled into
the user's home config via `self.homeModules.nx` in
`modules/home/default.nix`.

## Layout

`default.nix` is the only file directly discovered by import-tree; the
rest lives under `_impl/` (path containing `/_`, which import-tree's
default filter skips) since those files are home-manager modules that
take `repoDir`/`hostName` as module arguments — not flake-parts modules —
and would error if import-tree tried to import them as such.
