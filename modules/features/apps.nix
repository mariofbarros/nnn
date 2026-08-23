{ self, inputs, ... }: {
  flake.nixosModules.apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      
      #SYSTEM ESSENTIALS
      wget
      git
      which
      file
      curl
      nmap            # Port scanning/network discovery
      mtr             # Route tracing

      #UTILS
      kdePackages.dolphin
      kdePackages.kio         # file-open-with associations
      kdePackages.kio-extras  # extra protocols: sftp, trash, etc.
      unzip
      p7zip           # 7z/ZIP compatibility
      unrar           # Windows archive support
      vlc
      ffmpeg
      obs-studio
      yazi
      btop
      localsend

      #DEVELOPMENT
      # docker's CLI comes from virtualisation.docker.enable (configuration.nix)
      # -- listing it here too would be a duplicate install.
      vim
      vscodium
      opencode
      claude-code
      python3
      nodejs
      lua
      luajit
      rustup           # Rust toolchain manager
      cargo
      clippy
      go
      gopls
      gcc
      clang
      love

      #GAMING
      # gamemode, gamescope, mangohud, mesa, openrgb, and lact are already
      # pulled in by programs.gamemode/gamescope, home-manager's
      # programs.mangohud, hardware.graphics.extraPackages,
      # services.hardware.openrgb, and services.lact respectively -- listing
      # them here would be duplicate installs.
      protonup-qt
      lutris             # Non-Steam game launcher
      heroic             # Epic Games/GOG launcher
      bottles
      vulkan-tools       # Vulkan validation/debugging

      #OTHER
      librewolf
      bibata-cursors
      discord
      cmatrix
      chromium
    ];
  };
}
