{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }: {
    # import any other modules from here
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
      self.nixosModules.apps
      self.nixosModules.portals
      self.nixosModules.kitty
      self.nixosModules.fastfetch
      self.nixosModules.theming
      self.nixosModules.starship
      self.nixosModules.tmux
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest;

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
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "24";
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

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        # A fresh, independent tmux session per window -- not a shared one.
        # (Previously used `new-session -A -s main`, which attached every
        # window to the same session/panes -- e.g. running yazi in one
        # window made it show up in every other window too, since they
        # were all just different views onto the same underlying session.)
        # The TMUX check stops this from re-firing when tmux itself opens
        # a new pane/window, which also starts a fresh fish shell.
        
        if status is-interactive; and not set -q TMUX
            exec tmux new-session
        end

        function nrs --description "nixos-rebuild switch, with a real check that it actually applied"
            if test "$XDG_SESSION_TYPE" = "wayland"
                echo "Note: running from inside the graphical session. If this rebuild touches" \
                     "users/shells/PAM, the display manager restart can disrupt activation" \
                     "partway through. Ctrl+Alt+F3 to a TTY first if that happens."
            end

            sudo nixos-rebuild switch --flake .#nix-btw
            or return 1

            set -l registered (readlink -f /nix/var/nix/profiles/system)
            set -l running (readlink -f /run/current-system)

            if test "$registered" = "$running"
                echo "Applied and running: "(basename $running)
            else
                echo "Registered as current, but not actually running yet:"
                echo "  registered: "(basename $registered)
                echo "  running:    "(basename $running)
                echo "Reboot to apply cleanly: sudo reboot"
            end
        end

        function noctalia-export --description "Export current noctalia-shell settings to noctalia.json"
            # Must be run from the flake root (uses the relative ./modules path below).
            nix run .#myNoctalia -- ipc call state all > /tmp/noctalia-state.json
            and cp /tmp/noctalia-state.json ./modules/features/noctalia.json
            and echo "noctalia.json updated"
        end
      '';
    };

    programs.steam.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [];

    system.stateVersion = "26.05";
  };
}
