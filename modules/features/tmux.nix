{ self, inputs, ... }: {
  flake.nixosModules.tmux = { pkgs, ... }: {
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set -g status-position bottom
        set -g status-style bg=#1a1b26,fg=#c0caf5
        set -g status-justify left

        set -g status-left "#[fg=#7aa2f7,bold]  #{pane_current_path} "
        set -g status-left-length 100
        set -g status-right ""

        set -g pane-border-style fg=#292e42
        set -g pane-active-border-style fg=#7aa2f7
        set -g mode-style bg=#283457,fg=#c0caf5

        # Each kitty window gets its own throwaway tmux session (see
        # programs.fish.interactiveShellInit). Closing the window kills
        # the client, not the session -- without this, those sessions
        # would sit around detached in the background forever. This
        # kills a session as soon as its one client goes away.
        set -g destroy-unattached on
      '';
    };
  };
}
