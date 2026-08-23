# nnn | NixOS + Niri + Noctalia

A personal NixOS flake configuration for a niri-based Wayland desktop. Built around a scrollable-tiling workflow, a modular file-per-concern structure, and a mostly Tokyo Night-leaning look across the terminal and compositor.
<img width="1918" height="1080" alt="image" src="https://github.com/user-attachments/assets/c4ccdb9a-a6c4-4814-a360-c195bc1fca95" />

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

**Theming**
- Tokyo Night palette (single source of truth in `lib/palette.nix`) — kitty, niri's window borders, tuigreet, SearXNG's web UI
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
- **A rebuild command that actually checks itself.** `nrs` runs `nixos-rebuild switch` and then compares the registered generation against what's actually running, rather than trusting the exit code — useful because a display-manager restart mid-activation can report success without the system having actually switched over.
- **A safe noctalia-shell settings export.** `noctalia-export` writes to a temp file first and only copies it into the repo if the export actually succeeded, avoiding a self-truncation bug where redirecting straight onto the tracked file could wipe it before the export ran.
- **Proper ABNT2 support.** Brazilian keyboard layout configured as separate `layout`/`variant` fields (`br` / `abnt2`) rather than a combined string, in both niri's input config and the console keymap.
- **Gaming configurations** for an optimized AMD gaming experience: full Vulkan/OpenGL driver stack (radv + 32-bit), Steam's gamescope session, gamemode, gamescope, MangoHud, LACT, protonup, lutris, heroic, bottles, plus gaming-friendly sysctl tunables. Proton tuning and window placement are declarative; the three overlay/wrapper tools stay per-game by design — see [Steam launch options](#steam-launch-options).
- **Centralized theming constants.** Cursor theme and the Tokyo Night color palette each live in one file under `lib/` (`cursor-theme.nix`, `palette.nix`) instead of being hand-copied across every consumer — kitty, niri, and greetd all import the same `lib/palette.nix` values, so the colors can only drift where a file (like the static SearXNG CSS) genuinely can't consume Nix values directly.

## Repository structure

```
lib/                    shared constants, imported by multiple modules
  palette.nix           Tokyo Night colors (single source of truth)
  cursor-theme.nix      cursor name/size, shared by niri + session vars
assets/                 static files consumed via absolute paths (not Nix-built)
  profile/pp.png        noctalia-shell avatar image
  walls/                wallpaper directory
modules/
  parts.nix             flake-parts perSystem `systems` list
  features/             system-level modules (auto-discovered by import-tree)
    niri.nix            compositor: keybinds, outputs, input, cursor
    noctalia/           desktop shell package + settings
      noctalia.nix
      noctalia.json     exported settings (regenerated by `noctalia-export`)
    portals.nix         xdg-desktop-portal setup for screen sharing
    theming.nix         GTK/Qt package + session variable baseline
    fetch.nix           fetch package + fish abbr
    starship.nix        prompt config
    searxng/            SearXNG service
      searxng.nix
      searxng-tokyo-night.css
    gaming.nix          gaming stack: AMD drivers, Steam/gamescope, gamemode, LACT, sysctl
    greetd.nix          greetd + tuigreet display manager
    apps.nix            rescue/admin CLI tools + bibata-cursors (needed system-wide by greetd)
    default-apps.nix    $BROWSER session variable
  home/                 home-manager modules for the mario user
    default.nix         option declaration + aggregation, stateVersion
    apps.nix            personal apps + dev tooling (home.packages)
    kitty.nix           terminal config (per-user ~/.config/kitty)
    theming.nix         gsettings-backed GTK4/libadwaita + Qt theming
    fetch.nix           fetch config
    xdg.nix             mimeapps.list defaults
    gaming.nix          per-user MangoHud overlay + gamemode settings
    fish.nix            login shell config, hosts `nrs`/`noctalia-export`
    nvim/               neovim: home-manager module + LazyVim-style config
      nvim.nix
      config/           init.lua, lua/, stylua.toml (symlinked to ~/.config/nvim)
  hosts/my-machine/     the nix-btw host definition
    configuration.nix   system-level config: users, locale, fish, fonts, cursor theme
    hardware.nix        hardware configuration
    default.nix         defines the nixosConfigurations.nix-btw output
    home.nix            home-manager NixOS module wiring
```

## Known issues

- **Intermittent freezes**, currently traced to a use-after-unmap race in the amdgpu framebuffer path (`drm_fb_helper_damage_work`). Under investigation — possibly CachyOS-kernel-specific, being narrowed down by comparing against `linuxPackages_latest`.
- **Rebuilding from inside the graphical session can misbehave.** Certain changes (anything touching users, shells, or PAM) can disrupt `nixos-rebuild switch` partway through when run from inside the active greetd-managed session — the generation gets registered but doesn't actually become the running system. Workaround: rebuild from a TTY (`Ctrl+Alt+F3`), which is what `nrs` is meant to be run from.

## Usage

```fish
nrs               # rebuild and switch, with a real check that it applied
noctalia-export   # sync noctalia-shell's live settings back into the repo
```

### Steam launch options

Part of the gaming setup is declarative and part of it isn't, which is easy to
misremember. What applies on its own:

- **Proton tuning** — `RADV_PERFTEST=gpl` and `PROTON_ENABLE_WAYLAND=1` are set in
  `home.sessionVariables` (`modules/home/gaming.nix`), so Steam and every Proton
  child process inherit them.
- **Window placement** — the niri rule in `modules/features/niri.nix` opens games
  fullscreen on DP-3 and opts them into that output's on-demand VRR. It matches
  both `steam_app_*` (Steam's per-title app-id) and `gamescope`.

What still needs a per-game launch option, because all three are opt-in wrappers
by design:

- **MangoHud** — `enableSessionWide` is deliberately off, so `MANGOHUD=1` is never
  set session-wide (it would overlay every Vulkan/OpenGL app, not just games).
- **GameMode** — the daemon only acts when a process asks it to, and almost no
  game does that natively.
- **gamescope** — its flags are baked into a wrapper around the binary, but
  gamescope still has to actually be invoked.

```
gamemoderun mangohud %command%                    # the usual one
gamescope -- gamemoderun mangohud %command%       # ...routed through gamescope
```

`--adaptive-sync` and `--force-grab-cursor` come from `programs.gamescope.args`
and are already in the wrapper, so there's no need to repeat them above.

Note that `--adaptive-sync` mainly matters in Steam's gamescope *session*, where
gamescope drives the display directly. Nested inside niri it's an ordinary
Wayland client and niri's own on-demand VRR governs refresh — which is why the
window rule matches `^gamescope$` as well, so VRR engages on either path.

#### Special Thanks

[tony](https://www.youtube.com/@tony-btw),
[Vimjoyer](https://www.youtube.com/@vimjoyer)
