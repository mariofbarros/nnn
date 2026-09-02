{ self, inputs, ... }: {
  flake.homeModules.apps = { pkgs, lib, ... }: {
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

      #DEVELOPMENT
      vscodium
      opencode
      claude-code
      python3
      nodejs
      # Both ship include/lua.h -- home.packages' buildEnv (unlike NixOS's
      # system profile, which sets ignoreCollisions) errors on that unless
      # one wins by priority. luajit stays default priority since love and
      # most Lua tooling here target it; lua is deprioritized, not dropped.
      (lib.lowPrio lua)
      luajit
      # rustup already ships its own proxy binaries for cargo/cargo-clippy/
      # rustc/etc. (dispatching to whatever toolchain rustup manages) --
      # separate cargo/clippy packages would just collide with those on
      # bin/cargo, bin/cargo-clippy, and completion files.
      rustup           # Rust toolchain manager
      go
      gopls
      gcc
      # Both wrappers ship bin/cpp and both already default to
      # meta.priority = 10 in nixpkgs, so lib.lowPrio (which also sets 10)
      # doesn't actually break the tie -- clang needs a number > 10 to
      # genuinely lose to gcc's cpp. clang/clang++ themselves don't
      # collide, only the bare `cpp` name does.
      (lib.setPrio 20 clang)
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
