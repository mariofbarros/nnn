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
      vim
      vscodium
      docker
      opencode
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
      # gamemode, gamescope, mangohud, and mesa are already pulled in by
      # programs.gamemode/gamescope, home-manager's programs.mangohud, and
      # hardware.graphics.extraPackages respectively -- listing them here
      # would be duplicate installs.
      protonup-qt
      lutris             # Non-Steam game launcher
      heroic             # Epic Games/GOG launcher
      bottles
      openrgb            # RGB controller (if supported hardware)
      vulkan-tools       # Vulkan validation/debugging
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
