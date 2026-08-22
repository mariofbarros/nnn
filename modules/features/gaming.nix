{ self, inputs, ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    # AMD Vulkan/OpenGL driver stack. mesa.drivers brings the radv Vulkan ICD,
    # radeonsi and the generic Vulkan loader; the 32-bit copy is what native
    # and Proton 32-bit games need on an AMD card.
    hardware.graphics = {
      enable = true;
      # enable32Bit installs the 32-bit driver set at /run/opengl-driver-32
      # (required for Steam/Proton 32-bit games); extraPackages32 is only
      # consulted when it is on.
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        vulkan-loader
      ];
      extraPackages32 = with pkgs; [
        pkgsi686Linux.mesa
      ];
    };

    # Early KMS so the console/splash doesn't flicker on the amdgpu path.
    hardware.amdgpu.initrd.enable = true;

    # Steam: keep the plain steam enable system-side (configuration.nix) and
    # add the gamescope session entry point + udev rules for controllers.
    programs.steam.gamescopeSession.enable = true;
    hardware.steam-hardware.enable = true;

    # GameMode: on-demand CPU governor/niceness boost while a game is running.
    programs.gamemode.enable = true;

    # gamescope as a micro-compositor. capSysNice lets gamescope raise its own
    # niceness/scheduling priority (via a root setuid wrapper). WSI layer is
    # intentionally off: only the Steam session routes through gamescope.
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # LACT daemon for AMD GPU monitoring/fan control (no overclocking --
    # hardware.amdgpu.overdrive deliberately left disabled).
    services.lact.enable = true;

    # Kernel/VM tunables that matter for gaming:
    # - vm.max_map_count: DXVK/VKD3D-proton map far more mmaps than the default
    # - vm.swappiness: avoid swapping out hot pages during gameplay
    # - net.core.*: roomier socket buffers for online gaming
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "vm.swappiness" = 10;
      "net.core.rmem_max" = 1048576;
      "net.core.wmem_max" = 1048576;
    };
  };
}
