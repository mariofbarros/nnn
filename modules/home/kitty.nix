{ self, inputs, ... }:
let
  palette = import ../../lib/palette.nix;
in {
  flake.homeModules.kitty = { pkgs, ... }: {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;

      font = {
        name = "Iosevka Nerd Font Mono";
        size = 15.0;
      };

      # Tokyo Night ("night" variant -- matches Noctalia's colorSchemes.predefinedScheme).
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
        color1  #f7768e
        color2  #9ece6a
        color3  #e0af68
        color4  ${palette.accent}
        color5  #bb9af7
        color6  #7dcfff
        color7  #a9b1d6

        # bright
        color8  #414868
        color9  #ff899d
        color10 #9fe044
        color11 #faba4a
        color12 #8db0ff
        color13 #c7a9ff
        color14 #a4daff
        color15 ${palette.fg}

        background_opacity   0.5
        background_blur 1
        window_padding_width 8
      '';
    };
  };
}
