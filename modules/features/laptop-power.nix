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

    # Lock (not suspend) on lid close. s2idle is the only sleep state this
    # hardware's firmware exposes, and it reliably hard-crashes on this
    # machine (rtw88_8821ce + AMD s2idle bug) -- every suspend entry in the
    # logs is followed by a silent hard reboot, never a resume. Locking
    # avoids triggering that path; `systemctl suspend` still works manually
    # if you want to risk it once a fix (BIOS update) is confirmed.
    services.logind.settings.Login.HandleLidSwitch = "lock";
    services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";

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
