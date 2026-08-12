{ self, inputs, ... }: {
  flake.nixosModules.apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      vscode
      librewolf
      bibata-cursors
      unzip
      discord
      vlc
      ffmpeg
      obs-studio
      cmatrix
      python3
      chromium
      kdePackages.dolphin
      kdePackages.kio         # file-open-with associations
      kdePackages.kio-extras  # extra protocols: sftp, trash, etc.
      yazi
      htop
      love
    ];
  };
}
