{ self, inputs, ... }:
let
  tokyoNight = import ../../lib/palette-tokyo-night.nix;
  everforest = import ../../lib/palette-everforest.nix;

  # ANSI colors 1-3/5-7/9-14 aren't in lib/palette-*.nix (only the handful of
  # roles other consumers like niri/greetd need are), so each theme gets its
  # own full 16-color set here.
  ansi = {
    tokyoNight = {
      normal = { red = "#f7768e"; green = "#9ece6a"; yellow = "#e0af68"; magenta = "#bb9af7"; cyan = "#7dcfff"; white = "#a9b1d6"; };
      bright = { black = "#414868"; red = "#ff899d"; green = "#9fe044"; yellow = "#faba4a"; blue = "#8db0ff"; magenta = "#c7a9ff"; cyan = "#a4daff"; };
    };
    everforest = {
      normal = { red = "#e67e80"; green = "#a7c080"; yellow = "#dbbc7f"; magenta = "#d699b6"; cyan = "#83c092"; white = "#9da9a0"; };
      bright = { black = "#7a8478"; red = "#e67e80"; green = "#a7c080"; yellow = "#dbbc7f"; blue = "#7fbbb3"; magenta = "#d699b6"; cyan = "#83c092"; };
    };
  };
in {
  flake.homeModules.kitty = { pkgs, hostName, ... }:
    let
      isLaptop = hostName == "nixbook";
      palette = if isLaptop then everforest else tokyoNight;
      a = if isLaptop then ansi.everforest else ansi.tokyoNight;
    in {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;

      font = {
        name = "Iosevka Nerd Font Mono";
        size = 15.0;
      };

      # Tokyo Night on the desktop, Everforest on the laptop -- matches
      # Noctalia's colorSchemes.predefinedScheme on each host (see
      # modules/features/noctalia/noctalia-{desktop,laptop}.json).
      # Options the home-manager module doesn't expose as structured settings
      # (colors, opacity, padding, borders) live here as raw kitty.conf lines.
      extraConfig = ''
        background               ${palette.bg}
        foreground                ${palette.fg}
        selection_background     ${palette.bg2}
        selection_foreground      ${palette.fg}
        url_color                 ${palette.teal}
        cursor                    ${palette.fg}
        cursor_text_color         ${palette.bg}

        active_tab_background     ${palette.accent}
        active_tab_foreground     ${palette.bg0}
        inactive_tab_background   ${palette.bg1}
        inactive_tab_foreground   ${palette.fgMuted}
        tab_bar_background        ${palette.black}

        active_border_color       ${palette.accent}
        inactive_border_color     ${palette.bg1}

        # normal
        color0  ${palette.black}
        color1  ${a.normal.red}
        color2  ${a.normal.green}
        color3  ${a.normal.yellow}
        color4  ${palette.accent}
        color5  ${a.normal.magenta}
        color6  ${a.normal.cyan}
        color7  ${a.normal.white}

        # bright
        color8  ${a.bright.black}
        color9  ${a.bright.red}
        color10 ${a.bright.green}
        color11 ${a.bright.yellow}
        color12 ${a.bright.blue}
        color13 ${a.bright.magenta}
        color14 ${a.bright.cyan}
        color15 ${palette.fg}

        background_opacity   0.5
        background_blur 1
        window_padding_width 8
      '';
    };
  };
}
