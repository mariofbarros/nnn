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
- LightDM — display manager (NixOS's implicit default; not yet given its own dedicated module)

**Shell & terminal**
- fish (login shell)
- kitty (terminal)
- starship (prompt)
- [fetch](https://github.com/areofyl/fetch) (system info)

**Theming**
- Tokyo Night palette — kitty, niri's window borders
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

## Repository structure

```
modules/
  configuration.nix    system-level config: users, locale, fish, fonts, cursor theme
  hardware.nix         hardware configuration
  niri.nix             compositor: keybinds, outputs, input, cursor
  noctalia.nix         desktop shell package + settings
  apps.nix             general application packages
  portals.nix          xdg-desktop-portal setup for screen sharing
  theming.nix          shared GTK/Qt dark theme baseline
  kitty.nix            terminal package + theme
  fetch.nix            fetch package + config
  starship.nix         prompt config
```

## Known issues

- **Intermittent freezes**, currently traced to a use-after-unmap race in the amdgpu framebuffer path (`drm_fb_helper_damage_work`). Under investigation — possibly CachyOS-kernel-specific, being narrowed down by comparing against `linuxPackages_latest`.
- **Rebuilding from inside the graphical session can misbehave.** Certain changes (anything touching users, shells, or PAM) can disrupt `nixos-rebuild switch` partway through when run from inside the active LightDM-managed session — the generation gets registered but doesn't actually become the running system. Workaround: rebuild from a TTY (`Ctrl+Alt+F3`), which is what `nrs` is meant to be run from.

## Planned / under consideration

- **home-manager**, mainly to close the declarative gap in GTK4/libadwaita and qt6ct theming (both currently need a one-time manual step), and to manage per-user dotfiles like kitty's config directly instead of as a system-wide fallback that can be silently shadowed.
- **greetd + tuigreet** as a lighter-weight replacement for the current implicit LightDM default, better suited to a niri-only setup.
- **nvim full IDE configuration**
- **gaming configurations** for optmized gaming experience: gamemode, gamescope, openGL, lact, mangoHUD, protonup, lutris, heroic, bottles.

## Usage

```fish
nrs               # rebuild and switch, with a real check that it applied
noctalia-export   # sync noctalia-shell's live settings back into the repo
```
#### Special Thanks

[tony](https://www.youtube.com/@tony-btw),
[Vimjoyer](https://www.youtube.com/@vimjoyer)
