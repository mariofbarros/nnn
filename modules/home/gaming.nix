{ self, inputs, ... }: {
  flake.homeModules.gaming = { pkgs, ... }: {
    # MangoHud overlay. enableSessionWide stays off: launch games with
    # `mangohud %command%` in Steam, or flip the overlay toggle (Shift+F12).
    programs.mangohud = {
      enable = true;
      settings = {
        fps = true;
        fps_limit = 0;
        vsync = 0;
        gpu_stats = true;
        gpu_temp = true;
        gpu_power = true;
        cpu_stats = true;
        cpu_temp = true;
        core_load = true;
        vram = true;
        ram = true;
        frametime = true;
        position = "top-left";
        font_size = 18;
        background_alpha = 0.4;
        text_color = "#c0caf5";
        gpu_color = "#7aa2f7";
        cpu_color = "#bb9af7";
        vram_color = "#9ece6a";
        frametime_color = "#7dcfff";
        toggle_hud = "Shift_F12";
      };
    };

    # Per-user GameMode config: raise priority and CPU/GPU governor only while
    # a GameMode session is active (system-side daemon is in features/gaming.nix).
    xdg.configFile."gamemode.ini".text = ''
      [general]
      renice = 10
      desiredGov = performance
      reaper_freq = 5
      softrealtime = auto
      inhibit_screensaver = 1

      [gpu]
      apply_gpu_optimisations = accept-responsibility
      amd_performance_level = high

      [custom]
      start = notify-send "GameMode started"
      end = notify-send "GameMode ended"
    '';
  };
}
