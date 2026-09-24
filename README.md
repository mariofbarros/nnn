# nnn | NixOS + Niri + Noctalia

A personal NixOS flake configuration for a niri-based Wayland desktop. Built around a scrollable-tiling workflow, a modular file-per-concern structure, and a per-host theme (Tokyo Night on the desktop, Everforest on the laptop) across the terminal and compositor.
<img width="1917" height="1075" alt="image" src="https://github.com/user-attachments/assets/9062f4f3-0431-42d2-a3bb-48eaf4d6849b" />


## Documentation

- [docs/nx.md](docs/nx.md) — the `nx` fish CLI: what it wraps, what was
  changed from upstream, how it's wired in
- [docs/steam-launch-options.md](docs/steam-launch-options.md) — what
  Steam/Proton config is declarative versus per-game
- [docs/secrets.md](docs/secrets.md) — how agenix is wired up, adding or
  rotating a secret, registering a new host as a recipient
- [docs/new-machine.md](docs/new-machine.md) — bootstrapping a third host
  (or reinstalling one) from scratch, disko partitioning included

## Overview

This repo defines a full NixOS system (`nix-btw`) from a single flake, using [flake-parts](https://flake.parts/) and [import-tree](https://github.com/vic/import-tree) so that every concern — the compositor, the shell, individual applications, theming — lives in its own file under `modules/` with no manual import list to maintain. Window management and the desktop shell are wrapped declaratively with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules), which turns plain Nix attribute sets into the native config formats (KDL for niri, JSON for noctalia-shell) at build time.

## Tech stack

**System**
- NixOS (flake-based, `nixpkgs` unstable)
- flake-parts + import-tree for automatic module discovery
- nix-wrapper-modules for niri and noctalia-shell

**Kernel**
- CachyOS kernel, via the `xddxdd/nix-cachyos-kernel` overlay

**Desktop**
- [niri](https://github.com/YaLTeR/niri) — scrollable-tiling Wayland compositor
- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) — Quickshell-based desktop shell (bar, dock, notifications, OSD, app launcher, lock screen, wallpaper management)
- greetd + tuigreet — themed to match, launches niri directly (see `modules/features/greetd.nix`)

**Shell & terminal**
- fish (login shell)
- kitty (terminal)
- starship (prompt)
- [fetch](https://github.com/areofyl/fetch) (system info)

**Media**
- [Sung](https://github.com/yappologistic/Sung) — Material 3 music player (YouTube Music, local files, Subsonic/Navidrome), packaged from source in `modules/home/sung/`
- [yt-dlp](https://github.com/yt-dlp/yt-dlp), [Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) (desktop app), [AppFlowy](https://github.com/AppFlowy-IO/AppFlowy) — home-manager packages, `modules/home/apps.nix`

**Self-hosted services** (`modules/features/`)
- [SearXNG](https://github.com/searxng/searxng) — metasearch, native NixOS service
- [homepage](https://github.com/gethomepage/homepage) — dashboard linking the services below, native NixOS service
- [Reactive Resume](https://github.com/reactive-resume/reactive-resume) — resume builder, docker compose (no nixpkgs package)
- All bound to loopback only; see `modules/features/*/docker-compose.yml` for what was changed from upstream

**Security**
- ClamAV (`services.clamav`) — daemon + freshclam updater + weekly scan of `/home`, `modules/features/clamav.nix`

**Secrets**
- [agenix](https://github.com/ryantm/agenix) — each host decrypts with its own SSH host key (`modules/features/secrets.nix`); recipients are managed in `secrets/secrets.nix`. See [docs/secrets.md](docs/secrets.md).

**CI**
- GitHub Actions (`.github/workflows/ci.yml`) — `nix flake check` plus a build matrix over both `nixosConfigurations`, using [magic-nix-cache](https://github.com/DeterminateSystems/magic-nix-cache-action) so no external cache account is needed. Catches a broken host config before it reaches `nx deploy`.

**CLI tools** (`modules/home/apps.nix`, no nixpkgs package)
- [tfm-tui](https://github.com/clarkarch/tfm-tui) — mouse-first terminal file manager, packaged from a prebuilt release binary
- [portop](https://github.com/padovanl/portop) — htop-style view of what's using your ports, packaged from a prebuilt release binary
- [late](https://github.com/mpiorowski/late-sh) — companion CLI for `ssh late.sh` (a public SSH social space), built from its own flake (`late-sh` input); local audio playback synced to that session, nothing self-hosted

**Theming**
- Per-host palette — Tokyo Night on the desktop (`lib/palette-tokyo-night.nix`), Everforest on the laptop (`lib/palette-everforest.nix`) — kitty, niri's window borders, tuigreet, SearXNG's web UI, and noctalia-shell's own color scheme all follow whichever palette matches the host
- Bibata cursors
- Iosevka Nerd Font
- adw-gtk3, Papirus icons, and qt6ct as a shared dark baseline for the GTK/Qt applications

**Screen sharing**
- xdg-desktop-portal-gnome + xdg-desktop-portal-gtk, wired specifically for niri's screencast interface (the more commonly recommended `xdg-desktop-portal-wlr` does not support niri)

## Notable features

- **Modular by design.** Every component — compositor, shell, terminal, theming, individual apps — is its own file under `modules/`, auto-discovered by import-tree. Adding a new concern means adding a new file, not editing a central import list.
- **Declarative niri config.** Keybinds, output layout, input settings, and window rules are all plain Nix, compiled to niri's KDL config through nix-wrapper-modules.
- **Niri details worth knowing:**
  - Native screenshot bindings (region, monitor, window) with no extra packages
  - `prefer-no-csd` to drop redundant client-side title bars where the app supports it
  - `focus-follows-mouse`, capped so it doesn't yank the view sideways to follow the cursor
  - Explicit per-output positioning for the dual-monitor setup
  - Separate binds for column maximize, window fullscreen, and the workspace overview
- **A rebuild command that actually checks itself.** `nx switch` runs `nixos-rebuild switch` and then compares the registered generation against what's actually running, rather than trusting the exit code — useful because a display-manager restart mid-activation can report success without the system having actually switched over.
- **A safe noctalia-shell settings export.** `nx noctalia-export` writes to scratch files first and only replaces the tracked `noctalia.json` if the whole export succeeded, avoiding a self-truncation bug where redirecting straight onto the tracked file could wipe it before the export ran.
- **Proper ABNT2 support.** Brazilian keyboard layout configured as separate `layout`/`variant` fields (`br` / `abnt2`) rather than a combined string, in both niri's input config and the console keymap.
- **Gaming configurations** for an optimized AMD gaming experience: full Vulkan/OpenGL driver stack (radv + 32-bit), Steam's gamescope session, gamemode, gamescope, MangoHud, LACT, protonup, lutris, heroic, bottles, plus gaming-friendly sysctl tunables. Proton tuning and window placement are declarative; the three overlay/wrapper tools stay per-game by design — see [Steam launch options](docs/steam-launch-options.md).
- **Sung, packaged from source.** [Sung](https://github.com/yappologistic/Sung) is a native Material 3 music player (YouTube Music, local files, Subsonic/Navidrome) that isn't in nixpkgs and ships an Arch-oriented installer. `modules/home/sung/` packages it properly instead: the Qt6/C++ app builds via CMake, and the Python backend gets a Nix-built `ytmusicapi`/`yt-dlp` environment wired in through `SUNG_PYTHON` rather than the upstream script's pip venv, with ffmpeg and Node.js (needed by yt-dlp's JS challenge solver) on its `PATH`.
- **Unattended GC as a variation of `nx clean`.** `modules/features/gc.nix` runs the exact same `nix-collect-garbage --delete-older-than 7d` that `nx clean`'s default does (see `modules/home/nx/_impl/cmd-maintenance.nix`), just on a weekly systemd timer via the native `nix.gc` option — no external GC tool, just the manual command's own logic run automatically.
- **CI-checked before it's deploy-checked.** Every push/PR builds both hosts' full system closure in GitHub Actions (`.github/workflows/ci.yml`), so a broken module is caught before `nx deploy` ever touches real hardware.
- **A disko template, ready but inert.** `modules/features/disko.nix` declares a GPT/ESP/swap/ext4 layout via [disko](https://github.com/nix-community/disko), but neither host imports it — both are already partitioned. It's there for the next fresh install (see [docs/new-machine.md](docs/new-machine.md)), not applied to a running system.
- **Centralized, per-host theming constants.** Cursor theme lives in one shared file under `lib/` (`cursor-theme.nix`); the color palette instead has one file per host theme (`palette-tokyo-night.nix`, `palette-everforest.nix`), and each consumer (kitty, niri, greetd) picks between them by `hostName`/`networking.hostName` rather than hand-copying colors. noctalia-shell's `predefinedScheme` and the static SearXNG CSS (which can't consume Nix values directly) are kept in sync with the same two palettes by hand.

## Repository structure

```
.github/workflows/ci.yml  flake check + build matrix over both hosts (magic-nix-cache, no cache account needed)
secrets/                agenix-encrypted secrets + the recipients manifest
  secrets.nix           per-host SSH pubkeys -> which .age files they can decrypt
  searxng-secret.env.age
lib/                    shared constants, imported by multiple modules
  palette-tokyo-night.nix  desktop (my-machine) color palette
  palette-everforest.nix   laptop (nixbook) color palette
  cursor-theme.nix      cursor name/size, shared by niri + session vars
assets/                 static files consumed via absolute paths (not Nix-built)
  profile/pp.png        noctalia-shell avatar image
  walls/                wallpaper directory
  noctalia-everforest-scheme.json  custom noctalia-shell color scheme, dropped into
                                    ~/.config/noctalia/colorschemes on the laptop
modules/
  parts.nix             flake-parts perSystem `systems` list
  schemas.nix           flake-schemas wiring, cosmetic `nix flake show` output only
  features/             system-level modules (auto-discovered by import-tree)
    niri.nix            compositor: keybinds, outputs, input, cursor
    secrets.nix          agenix wiring; enables sshd solely to mint each host's
                         SSH host key, used as its agenix identity
    gc.nix               weekly unattended GC (`nix.gc`) -- the automated
                         counterpart to `nx clean`'s default
    disko.nix            GPT/ESP/swap/ext4 layout template; not imported by
                         either host, kept for the next fresh install
    noctalia/           desktop shell package + settings
      noctalia.nix
      noctalia-desktop.json  my-machine's settings (regenerated by `nx noctalia-export`)
      noctalia-laptop.json   nixbook's settings (regenerated by `nx noctalia-export`)
    portals.nix         xdg-desktop-portal setup for screen sharing
    theming.nix         GTK/Qt package + session variable baseline
    fetch.nix           fetch package + fish abbr
    starship.nix        prompt config
    searxng/            SearXNG service
      searxng.nix
      searxng-tokyo-night.css  desktop reskin
      searxng-everforest.css  laptop reskin
    homepage.nix        homepage dashboard, links to the services below
    reactive-resume/    Reactive Resume, docker compose (no nixpkgs package)
      reactive-resume.nix
      docker-compose.yml  trimmed from upstream's compose.yml
    clamav.nix          ClamAV daemon + updater + scheduled scan
    gaming.nix          gaming stack: AMD drivers, Steam/gamescope, gamemode, LACT, sysctl
    greetd.nix          greetd + tuigreet display manager
    apps.nix            rescue/admin CLI tools + bibata-cursors (needed system-wide by greetd)
    default-apps.nix    $BROWSER session variable
  home/                 home-manager modules for the mario user
    default.nix         option declaration + aggregation, stateVersion
    apps.nix            personal apps + dev tooling (home.packages)
    kitty.nix           terminal config (per-user ~/.config/kitty)
    theming.nix         gsettings-backed GTK4/libadwaita + Qt theming
    noctalia-theme.nix  drops the Everforest scheme into ~/.config/noctalia (laptop only)
    fetch.nix           fetch config
    xdg.nix             mimeapps.list defaults
    gaming.nix          per-user MangoHud overlay + gamemode settings
    fish.nix            login shell config
    nvim/               neovim: home-manager module + LazyVim-style config
      nvim.nix
      config/           init.lua, lua/, stylua.toml (symlinked to ~/.config/nvim)
    nx/                 nx fish CLI (deploy/switch/install/search/etc.);
                         see docs/nx.md
      default.nix       flake.homeModules.nx entry point
      _impl/            cmd-*/helpers-*/dispatcher — not auto-discovered
                         by import-tree (path contains "/_")
    sung/               Sung music player, packaged here (not in nixpkgs)
      default.nix       flake.homeModules.sung entry point
      _package.nix      the derivation — underscore-prefixed so import-tree
                         skips it; consumed via callPackage
  hosts/my-machine/     the nix-btw host definition
    configuration.nix   system-level config: users, locale, fish, fonts, cursor theme
    hardware.nix        hardware configuration
    default.nix         defines the nixosConfigurations.nix-btw output
    home.nix            home-manager NixOS module wiring
```

## Known issues

- **Intermittent freezes**, currently traced to a use-after-unmap race in the amdgpu framebuffer path (`drm_fb_helper_damage_work`). Under investigation — possibly CachyOS-kernel-specific, being narrowed down by comparing against `linuxPackages_latest`.
- **Rebuilding from inside the graphical session can misbehave.** Certain changes (anything touching users, shells, or PAM) can disrupt `nixos-rebuild switch` partway through when run from inside the active greetd-managed session — the generation gets registered but doesn't actually become the running system. Workaround: rebuild from a TTY (`Ctrl+Alt+F3`), which is what `nx switch` is meant to be run from.

## Usage

```fish
nx --help         # deploy/switch/update/install/search/etc. — see docs/nx.md
nx switch         # rebuild and switch, with a real check that it applied
nx noctalia-export  # sync noctalia-shell's live settings back into the repo
```

See [docs/steam-launch-options.md](docs/steam-launch-options.md) for what
Steam/Proton config is declarative versus what still needs a per-game
launch option.

#### Special Thanks

[tony](https://www.youtube.com/@tony-btw),
[Vimjoyer](https://www.youtube.com/@vimjoyer),
[Lunobe/Nx](https://github.com/Lunobe/Nx) (the `nx` fish CLI is vendored
from here, see [docs/nx.md](docs/nx.md)),
[yappologistic/Sung](https://github.com/yappologistic/Sung) (the music
player packaged in `modules/home/sung/`; upstream is MIT-licensed, all
credit for the application itself goes to its authors — this repo only
adds the Nix packaging),
[gvolpe/nix-config](https://github.com/gvolpe/nix-config) (inspiration for
the CI build matrix in `.github/workflows/ci.yml`, the per-topic runbook
docs under `docs/`, and the cosmetic `flake-schemas` wiring in
`modules/schemas.nix`),
[muhammadtalha-quant/nucleus](https://github.com/muhammadtalha-quant/nucleus)
(inspiration for the `disko` partition template in
`modules/features/disko.nix` and for scheduling unattended store cleanup —
implemented here as a native `nix.gc` variation of `nx clean` rather than
adopting nucleus's `programs.nh` directly)
