{ self, inputs, ... }:
let
  # Shared with modules/hosts/*/configuration.nix's XCURSOR_THEME /
  # XCURSOR_SIZE session variables -- keep both in sync via this file.
  cursorTheme = import ../../lib/cursor-theme.nix;
  tokyoNight = import ../../lib/palette-tokyo-night.nix;
  everforest = import ../../lib/palette-everforest.nix;

  # Shared between hosts (desktop, laptop, ...): everything that isn't
  # tied to a specific physical monitor layout. `outputs`, `gameOutput` and
  # `palette` are the per-host knobs -- see the two perSystem.packages below.
  mkNiriSettings = { pkgs, lib, self', outputs, palette, gameOutput ? null, brightnessKeys ? false, noctaliaPackage ? "myNoctalia" }: {
    prefer-no-csd = _:{ };

    spawn-at-startup = [
      (lib.getExe self'.packages.${noctaliaPackage})
    ];

    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

    input.keyboard.xkb = {
      layout = "br";
      variant = "abnt2";
    };

    # Without this, libinput only registers a physical click (pressing the
    # whole clickpad down), not a light tap -- a no-op on the desktop's
    # mouse, but needed on the laptop's touchpad.
    input.touchpad.tap = _: { };

    # libinput's accel-speed range is -1 (slowest) .. 0 (default) .. 1
    # (fastest); with the default "adaptive" accel-profile (unset here),
    # 0.4 is ~40% faster than neutral (two +20% bumps stacked).
    input.mouse.accel-speed = 0.4;

    # Capped with max-scroll-amount so it only kicks in when it won't
    # scroll the view -- niri's own recommended default. Without the
    # cap, moving the mouse near a partially-off-screen window can
    # yank the view sideways to follow it, which feels jarring on a
    # scrolling-columns layout. Drop the props block entirely if you'd
    # rather have it always follow, scroll or not.
    input.focus-follows-mouse = _: { props = { max-scroll-amount = "0%"; }; };

    cursor = {
      xcursor-theme = cursorTheme.name;
      xcursor-size = cursorTheme.size;
    };

    inherit outputs;

    layout.gaps = 8;
    layout.focus-ring.active-color = palette.accent; # matches kitty's accent on this host
    layout.focus-ring.width = 2;

    window-rules = [
      {
        # No `matches` -- applies to every window. Small radius for a
        # subtle rounded look rather than a pronounced pill shape.
        geometry-corner-radius = 6;
        clip-to-geometry = true;
      }
    ] ++ lib.optional (gameOutput != null) {
      # Send games to gameOutput and open them fullscreen, rather than
      # letting them land on whichever output happens to be focused.
      # niri OR's the `matches` entries: any one hit applies the rule.
      # Note these are regexes, so they anchor with ^.
      matches = [
        # Steam sets app-id "steam_app_<appid>" on the game window
        # (both native and Proton titles). Anchored so it can't also
        # catch the Steam client itself, whose app-id is bare "steam".
        { app-id = "^steam_app_"; }
        # A game run through gamescope is one nested gamescope window,
        # so the game's own app-id is never visible to niri.
        { app-id = "^gamescope$"; }
      ];
      open-on-output = gameOutput;
      open-fullscreen = true;
      # Required for the target output's on-demand VRR to actually kick
      # in -- niri gates that on a visible window whose rule sets this
      # true, so without it the output setting alone would never engage.
      variable-refresh-rate = true;
    };

    binds = let
      # Generates Mod+1.."9" -> focus-workspace N, and Mod+Shift+1.."9" ->
      # move-window-to-workspace N, instead of writing out 18 lines by hand.
      workspaceBinds = lib.listToAttrs (lib.concatMap (i: [
        { name = "Mod+${toString i}"; value.focus-workspace = i; }
        { name = "Mod+Shift+${toString i}"; value.move-window-to-workspace = i; }
      ]) (lib.range 1 9));
    in {
      "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
      "Mod+Q".close-window = _:{ };
      "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

      # Move focus between columns / windows within a column
      "Mod+Left".focus-column-left = _:{ };
      "Mod+Right".focus-column-right = _:{ };

      # Move the focused column / window itself
      "Mod+Shift+Left".move-column-left = _:{ };
      "Mod+Shift+Right".move-column-right = _:{ };

      # Switch workspaces up/down on the current monitor
      "Mod+Down".focus-workspace-down = _:{ };
      "Mod+Up".focus-workspace-up = _:{ };
      "Mod+Shift+Down".move-window-to-workspace-down = _:{ };
      "Mod+Shift+Up".move-window-to-workspace-up = _:{ };

      # Jump straight to a workspace by number (Mod+1 .. Mod+9)
      # and Mod+Shift+1..9 to send the focused window there instead.

      # Move focus / windows between monitors (a no-op with a single
      # output, harmless to keep bound for hosts with more than one).
      "Mod+Ctrl+Left".focus-monitor-left = _:{ };
      "Mod+Ctrl+Right".focus-monitor-right = _:{ };
      "Mod+Ctrl+Shift+Left".move-window-to-monitor-left = _:{ };
      "Mod+Ctrl+Shift+Right".move-window-to-monitor-right = _:{ };

      "Mod+F".fullscreen-window = _:{ };
      # Maximizes the focused COLUMN to fill the screen width -- windows
      # stay in the tiling flow and keep their borders/gaps, unlike
      # fullscreen above. This is niri's native "maximize" concept; it's
      # a different thing from a traditional floating-WM maximize.
      "Mod+M".maximize-column = _:{ };

      # Zoomed-out view of all workspaces/windows on this monitor --
      # niri's answer to "where did I put that window".
      "Mod+O".toggle-overview = _:{ };

      # Screenshots -- niri's built-in tool, saves to ~/Pictures/Screenshots
      # and copies to clipboard. No extra packages needed.
      "Print".screenshot = _:{ };               # interactive region select
      "Ctrl+Print".screenshot-screen = _:{ };    # whole current monitor
      "Alt+Print".screenshot-window = _:{ };     # focused window
    } // workspaceBinds // lib.optionalAttrs brightnessKeys {
      # Laptop backlight keys -- no-op on hosts without a `brightnessctl`-
      # controllable panel, so gated behind brightnessKeys rather than
      # bound unconditionally on every host.
      "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set +5%";
      "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 5%-";
    };
  };
in {
  flake.nixosModules.niriDesktop = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiriDesktop;
    };
  };

  flake.nixosModules.niriLaptop = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiriLaptop;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    # Run `niri msg outputs` (inside your niri session) to get the exact
    # output names for your machine (e.g. "DP-1", "HDMI-A-1"), then
    # replace the placeholders below and set positions to match your
    # physical monitor arrangement. Left-most monitor gets x=0; the next
    # one's x is the left monitor's width (e.g. 1920 for a 1920-wide
    # display), and so on.
    packages.myNiriDesktop = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = mkNiriSettings {
        inherit pkgs lib self';
        palette = tokyoNight;
        outputs = {
          "DP-3" = {
            position = _: { props = { x = 0; y = 0; }; };
            # VRR on the 144 Hz Acer, but on-demand rather than always-on:
            # niri only engages it while a window whose rule opts in with
            # `variable-refresh-rate true` is visible here. Keeps the
            # desktop at a fixed refresh, since VRR at idle desktop
            # framerates is what tends to cause brightness flicker on VA
            # panels.
            variable-refresh-rate = _: { props = { on-demand = true; }; };
          };
          "HDMI-A-1" = {
            position = _: { props = { x = 1920; y = 0; }; };
          };
        };
        gameOutput = "DP-3";
      };
    };

    # Single built-in panel -- adjust the output name below to match
    # `niri msg outputs` on the actual laptop (commonly "eDP-1").
    packages.myNiriLaptop = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = mkNiriSettings {
        inherit pkgs lib self';
        palette = everforest;
        outputs = {
          "eDP-1" = {
            position = _: { props = { x = 0; y = 0; }; };
          };
        };
        brightnessKeys = true;
        noctaliaPackage = "myNoctaliaLaptop";
      };
    };
  };
}
