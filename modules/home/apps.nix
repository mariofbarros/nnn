{ self, inputs, ... }: {
  flake.homeModules.apps = { pkgs, lib, ... }: {
    home.packages = with pkgs; [

      kdePackages.dolphin
      kdePackages.kio
      kdePackages.kio-extras
      p7zip
      unrar
      vlc
      ffmpeg
      obs-studio
      yazi
      btop
      vscodium
      opencode
      claude-code
      python3
      nodejs
      (lib.lowPrio lua)
      luajit
      rustup
      go
      gopls
      gcc
      (lib.setPrio 20 clang)
      protonup-qt
      lutris 
      heroic 
      bottles
      vulkan-tools
      librewolf
      discord
      cmatrix
      chromium
      love
      
      docker
    ];
  };
}
