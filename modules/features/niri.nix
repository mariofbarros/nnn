{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        # Ask apps to omit their own title bar / client-side decorations,
        # so you just get niri's own border instead of a redundant second
        # bar. Apps that support this negotiation (most GTK, most Qt) drop
        # it; some Electron apps (Discord included) ignore the request and
        # keep their own frame regardless -- that's an app-side limitation,
        # not a config mistake. Already-open windows need a restart to
        # actually lose their title bar; new ones pick it up immediately.
        prefer-no-csd = _:{ };

        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb = {
          layout = "br";
          variant = "abnt2";
        };

        # Capped with max-scroll-amount so it only kicks in when it won't
        # scroll the view -- niri's own recommended default. Without the
        # cap, moving the mouse near a partially-off-screen window can
        # yank the view sideways to follow it, which feels jarring on a
        # scrolling-columns layout. Drop the props block entirely if you'd
        # rather have it always follow, scroll or not.
        input.focus-follows-mouse = _: { props = { max-scroll-amount = "0%"; }; };

        cursor = {
          xcursor-theme = "Bibata-Modern-Classic";
          xcursor-size = 24;
        };

        # Run `niri msg outputs` (inside your niri session) to get the exact
        # output names for your machine (e.g. "DP-1", "HDMI-A-1"), then
        # replace the placeholders below and set positions to match your
        # physical monitor arrangement. Left-most monitor gets x=0; the next
        # one's x is the left monitor's width (e.g. 1920 for a 1920-wide
        # display), and so on.
        outputs = {
          "DP-3" = {
            position = _: { props = { x = 0; y = 0; }; };
          };
          "HDMI-A-1" = {
            position = _: { props = { x = 1920; y = 0; }; };
          };
        };

        layout.gaps = 5;
        layout.focus-ring.active-color = "#7aa2f7"; # Tokyo Night blue, matches kitty
        layout.focus-ring.width = 2;

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

          # Move focus / windows between your two monitors
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
        } // workspaceBinds;
      };
    };
  };
}