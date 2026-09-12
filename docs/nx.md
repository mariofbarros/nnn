# nx

`nx` is a fish CLI, exposed as `flake.homeModules.nx` from
`modules/home/nx/`, that wraps this repo's day-to-day flake workflow into
one command: `nx <subcommand>`. Run `nx --help` for full docs on every
subcommand, or `nx -h` for a one-line summary of each.

Vendored and trimmed from [Lunobe/Nx](https://github.com/Lunobe/Nx) —
copied into this repo (rather than pulled in as a flake input) since it's
a single person's personal tool with no stability guarantees, and needed
local edits anyway to fit this repo's layout.

## Commands

- **`format`** — format every `.nix` file (alejandra), then lint for
  antipatterns (statix) and dead code (deadnix); lint findings are
  printed but never fail the command.
- **`switch`** — plain `nixos-rebuild switch`, verified against what's
  actually running afterward. Lighter than `deploy`: no git
  staging/commit, no flake check, no scratch-dir build/rollback — for
  iterating locally when you already trust what's about to be built.
- **`deploy`** — the full build-and-switch: stage and (after confirming
  the diff) commit changes, `nix flake check`, build into a scratch dir,
  roll the commit back if either fails, then print the closure diff
  (nvd) and switch to the new generation.
- **`up`** — `nix flake update`, then `deploy` — skipped if the update
  left `flake.lock` unchanged.
- **`clean --keep <n> | --all`** — garbage-collect the Nix store;
  defaults to `--keep 7` (days).
- **`list`** — print the packages currently in `modules/home/apps.nix`.
- **`install <name>`** — resolve `<name>` in the locked nixpkgs (or
  search and let you pick), add it to `modules/home/apps.nix`, then
  `deploy`.
- **`uninstall <name>`** — remove `<name>` from `modules/home/apps.nix`,
  then `deploy`.
- **`search [search|option|meta|lib] <name>`** — `search` (default)
  searches nixpkgs; `option` looks up a NixOS option; `meta` prints a
  package's full metadata as JSON; `lib` searches nixpkgs/lib docs
  (manix).
- **`config`** — walk the import graph from `flake.nix` and open every
  referenced file in `$EDITOR`.
- **`noctalia-export`** — pull noctalia-shell's live settings back into
  the repo, writing to scratch files first and only replacing
  `modules/features/noctalia/noctalia.json` if the whole export
  succeeded.
- **`push`** — commit pending changes (after confirming) and `git push`.
- **`nuke-history`** — squash all git history into one commit and
  force-push, after a confirmation prompt and a local backup bundle.
  Destructive; rewrites remote history.
- **`doctor`** — `format`, update flake inputs, `deploy`, `clean --keep
  7`, `push`, in that order.

## Multi-host sync

`deploy`, `up`, and `push` all fetch `origin` first. If local is only
behind, it's fast-forwarded automatically (always conflict-free). If
local and remote have both diverged, the command stops before making any
new commits and tells you to run `git pull --rebase` manually — this
keeps auto-commits from ever landing on top of a stale base, which
matters here since this repo is deployed from two machines (desktop and
laptop) against the same branch.

## Wiring

`repoDir`/`hostName` are supplied via `home-manager.extraSpecialArgs` in
`modules/hosts/my-machine/home.nix`, and the module itself is pulled into
the user's home config via `self.homeModules.nx` in
`modules/home/default.nix`.

## Layout

`modules/home/nx/default.nix` is the only file directly discovered by
import-tree; the rest lives under `modules/home/nx/_impl/` (path
containing `/_`, which import-tree's default filter skips) since those
files are home-manager modules that take `repoDir`/`hostName` as module
arguments — not flake-parts modules — and would error if import-tree
tried to import them as such.
