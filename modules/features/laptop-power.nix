{ self, ... }: {
  flake.nixosModules.laptopPower = { pkgs, lib, ... }: {
    services.upower.enable = true;

    # TLP owns CPU governor / power-saving policy; power-profiles-daemon
    # manages the same knobs and the two fight over them if both run.
    services.power-profiles-daemon.enable = false;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        # ASUS battery charge limiting goes through asus-wmi's
        # charge_control_end_threshold rather than TLP's ThinkPad-only
        # START/STOP_CHARGE_THRESH options -- add `asusctl` (asus-linux)
        # separately if the Vivobook's firmware exposes it and you want
        # to cap charging for battery longevity.
      };
    };

    # Backlight control for niri's laptop keybinds (see niriLaptop).
    environment.systemPackages = [ pkgs.brightnessctl ];

    # Suspend on lid close, on battery or AC alike -- logind's default,
    # kept explicit since it's the behavior a laptop config depends on.
    services.logind.settings.Login.HandleLidSwitch = "suspend";
    services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";

    # Noctalia's own "lock on suspend" setting only fires when *it*
    # initiates the suspend via its idle timer -- it has no listener on
    # logind's PrepareForSleep signal, so a lid-close (or `systemctl
    # suspend`) goes straight past it unlocked. Hook the actual sleep
    # event directly and call the same IPC lock command Noctalia uses
    # internally, so the screen is locked no matter what triggered sleep.
    environment.etc."systemd/system-sleep/lock-screen" = {
      mode = "0555";
      text = ''
        #!/bin/sh
        if [ "$1" = pre ]; then
          uid=$(id -u mario)
          runuser -u mario -- env \
            XDG_RUNTIME_DIR="/run/user/$uid" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
            ${lib.getExe self.packages.${pkgs.system}.myNoctaliaLaptop} ipc call lockScreen lock
        fi
      '';
    };
  };
}
