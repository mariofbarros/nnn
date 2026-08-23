{ self, inputs, ... }:
let
  # Shared with modules/features/niri.nix's cursor.xcursor-theme/xcursor-size
  # -- keep both in sync via this file.
  cursorTheme = import ../../../lib/cursor-theme.nix;
in {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }: {
    # import any other modules from here
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
      self.nixosModules.apps
      self.nixosModules.portals
      self.nixosModules.fetch
      self.nixosModules.theming
      self.nixosModules.starship
      self.nixosModules.searxng
      self.nixosModules.gaming
      self.nixosModules.defaultApps
      self.nixosModules.homeManager
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];

    networking.hostName = "nix-btw";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Sao_Paulo";
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };

    services.xserver.enable = true;

    services.xserver.xkb = { layout = "br"; variant = "abnt2"; };
    console.keyMap = "br-abnt2";

    fonts = {
      packages = with pkgs; [
        nerd-fonts.iosevka
      ];
      fontconfig.enable = true; # usually on by default, explicit for clarity
    };

    environment.sessionVariables = {
      XCURSOR_THEME = cursorTheme.name;
      XCURSOR_SIZE = toString cursorTheme.size;
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    users.users.mario = {
      isNormalUser = true;
      description = "mario";
      extraGroups = [ "networkmanager" "wheel" "plugdev" ];
      packages = with pkgs; [ ];
      shell = pkgs.fish;
    };

    programs.fish.enable = true;

    programs.steam.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [];

    system.stateVersion = "26.05";
  };
}
