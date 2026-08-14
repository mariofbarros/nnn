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

      #DEVELOPMENT
      vim
      vscode
      python3
      nodejs
      npm
      rustup           # Rust toolchain manager
      cargo
      clippy
      go
      gopls
      gcc
      clang
      love

      #GAMING
      gamemode           # Game performance tuning
      gamescope          # Micro-compositor for games
      protonup
      lutris             # Non-Steam game launcher
      heroic             # Epic Games/GOG launcher
      bottles
      mangohud           # FPS overlay
      openrgb            # RGB controller (if supported hardware)
      vulkan-tools       # Vulkan validation/debugging
      openGL
      lact               #GPU Configuration Tool for AMD

      #OTHER
      librewolf
      bibata-cursors
      discord
      cmatrix
      chromium

    ];
  };
}
