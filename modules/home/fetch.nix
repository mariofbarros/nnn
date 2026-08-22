{ self, inputs, ... }: {
  flake.homeModules.fetch = { pkgs, ... }: {
    xdg.configFile."fetch/config".text = ''

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
  };
}
