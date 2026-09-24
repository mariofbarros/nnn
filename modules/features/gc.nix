{ ... }: {
  # Unattended counterpart to `nx clean` (see
  # modules/home/nx/_impl/cmd-maintenance.nix's __nx_cmd_clean, which runs
  # `nix-collect-garbage --delete-older-than <keep>d`, default 7). Same
  # mechanism, same 7-day default, just on a weekly timer instead of by
  # hand -- native `nix.gc`, no external GC tool.
  flake.nixosModules.gc = { ... }: {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
