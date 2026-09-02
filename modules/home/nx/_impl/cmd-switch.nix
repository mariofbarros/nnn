{
  repoDir,
  hostName,
  ...
}: {
  # -- nx: switch — ported from this repo's former standalone `nrs` fish
  # function into nx's dispatcher/style. Deliberately lighter than
  # `nx deploy`: plain `nixos-rebuild switch`, no git staging/commit, no
  # flake check, no scratch-dir build/nvd diff/rollback — just
  # rebuild-and-verify, for iterating locally when you already trust what's
  # about to be built and don't want the full deploy ceremony.

  programs.fish.functions = {
    __nx_cmd_switch = ''
      if test "$XDG_SESSION_TYPE" = "wayland"
        __nx_warn "Running from inside the graphical session. If this rebuild touches users/shells/PAM, the display manager restart can disrupt activation partway through. Ctrl+Alt+F3 to a TTY first if that happens."
      end

      __nx_stage "Building and switching to ${hostName}"
      sudo nixos-rebuild switch --flake ${repoDir}#${hostName}
      if test $status -ne 0
        __nx_fail "nixos-rebuild switch failed — see the build/activation output above."
        return 1
      end

      set -l registered (readlink -f /nix/var/nix/profiles/system)
      set -l running (readlink -f /run/current-system)
      if test "$registered" = "$running"
        __nx_ok "applied and running: "(basename $running)
      else
        __nx_warn "Registered as current, but not actually running yet:"
        echo "  registered: "(basename $registered)
        echo "  running:    "(basename $running)
        echo "Reboot to apply cleanly: sudo reboot"
      end
    '';
  };
}
