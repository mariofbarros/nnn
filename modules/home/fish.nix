{
  self,
  inputs,
  ...
}: {
  flake.homeModules.fish = {pkgs, ...}: {
    # Pre-existing ~/.config/fish/config.fish (fish's stock template) would be
    # clobbered by the generated config; let home-manager take it over.
    xdg.configFile."fish/config.fish".force = true;

    programs.fish = {
      enable = true;

      # nrs/noctalia-export used to live here as standalone functions; both
      # were ported into the nx CLI (modules/home/nx/) as `nx switch` and
      # `nx noctalia-export`.
      shellAbbrs.fetch = "command fetch -l NixOS";
    };
  };
}
