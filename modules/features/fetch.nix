{ self, inputs, ... }: {
  flake.nixosModules.fetch = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.fetch ];

    programs.fish.shellAbbrs.fetch = "command fetch -l NixOS";

    system.activationScripts.fetchConfig = let
      configFile = pkgs.writeText "fetch-config" ''

        host

        os
        kernel
        packages

        shell
        terminal
        de
        wm

        cpu
        gpu
        memory
        disk
        display
        uptime
        colors

        # appearance
        label_color=blue
        separator=-
        box=1

        # 3d
        spin=xy
        speed=1.0
        shading_mode=sextants

      '';
    in ''
      install -Dm644 -o mario ${configFile} /home/mario/.config/fetch/config
    '';
  };
}
