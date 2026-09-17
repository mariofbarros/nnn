{ self, inputs, ... }: {
  flake.homeModules.apps = { pkgs, lib, ... }: let
    system = pkgs.stdenv.hostPlatform.system;

    # Not in nixpkgs -- prebuilt release binary from clarkarch/tfm-tui.
    # Bun-compiled, so it's dynamically linked against glibc/libpthread/
    # libdl/libm; autoPatchelfHook rewrites the interpreter/rpath to the
    # store paths those actually resolve to on NixOS.
    tfm-tui = pkgs.stdenv.mkDerivation rec {
      pname = "tfm-tui";
      version = "0.1.0-beta.0";
      src = pkgs.fetchurl {
        url = "https://github.com/clarkarch/tfm-tui/releases/download/v${version}/tfm-x86_64-linux.gz";
        hash = "sha256-RuSDRLI6/6fm3IMysZyFeiAS3F3l6s2olct6nLVQ658=";
      };
      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        gunzip -c ${src} > $out/bin/tfm
        chmod 755 $out/bin/tfm
        runHook postInstall
      '';
      meta = {
        description = "Modern mouse-first terminal file manager";
        homepage = "https://github.com/clarkarch/tfm-tui";
        mainProgram = "tfm";
        platforms = [ "x86_64-linux" ];
      };
    };

    # Not in nixpkgs -- prebuilt release binary from padovanl/portop.
    # Statically linked (Go), so no patching needed.
    portop = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "portop";
      version = "0.0.7";
      src = pkgs.fetchurl {
        url = "https://github.com/padovanl/portop/releases/download/v${version}/portop_${version}_linux_amd64.tar.gz";
        hash = "sha256-joukdKD0WTgTTL1hSOUGGq8VMvQHng/KCWG9VcwvtDU=";
      };
      sourceRoot = ".";
      installPhase = ''
        runHook preInstall
        install -Dm755 portop $out/bin/portop
        runHook postInstall
      '';
      meta = {
        description = "htop-style TUI for what's using your ports";
        homepage = "https://github.com/padovanl/portop";
        mainProgram = "portop";
        platforms = [ "x86_64-linux" ];
      };
    };
  in {
    home.packages = with pkgs; [

      nemo-with-extensions
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

      yt-dlp
      stirling-pdf-desktop
      appflowy
      tfm-tui
      portop
      inputs.late-sh.packages.${system}.late

      docker
      docker-compose
      github-cli
    ];
  };
}
