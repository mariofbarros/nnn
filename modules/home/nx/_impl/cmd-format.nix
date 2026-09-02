{
  repoDir,
  pkgs,
  ...
}: {
  # -- nx: format --
  #
  # Upstream's "sort modules/packages.nix" stage was dropped — this repo's
  # package list groups entries under #UTILS/#DEVELOPMENT/etc. comments,
  # and a blind alphabetical sort would interleave those headers with
  # package names instead of respecting the grouping.

  programs.fish.functions = {
    __nx_cmd_format = ''
      __nx_stage "Formatting .nix files"
      __nx_format
      if test $status -ne 0
        __nx_fail "Formatting failed — likely a syntax error in one of the .nix files; run 'alejandra ${repoDir}' to see which."
        return 1
      end
      __nx_ok

      __nx_stage "Checking for lint issues (statix)"
      ${pkgs.statix}/bin/statix check ${repoDir}
      if test $status -eq 0
        __nx_ok
      else
        __nx_warn "issues found — see above"
      end

      __nx_stage "Checking for dead code (deadnix)"
      ${pkgs.deadnix}/bin/deadnix -f ${repoDir}
      if test $status -eq 0
        __nx_ok
      else
        __nx_warn "issues found — see above"
      end
    '';
  };
}
