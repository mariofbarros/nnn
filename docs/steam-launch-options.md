# Steam launch options

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
