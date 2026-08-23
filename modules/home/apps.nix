{ self, inputs, ... }: {
  flake.homeModules.apps = { pkgs, ... }: {
    home.packages = with pkgs; [

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
      protonup-qt
      lutris             # Non-Steam game launcher
      heroic             # Epic Games/GOG launcher
      bottles
      vulkan-tools       # Vulkan validation/debugging

      #OTHER
      librewolf
      discord
      cmatrix
      chromium
    ];
  };
}
