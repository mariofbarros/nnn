{
  repoDir,
  pkgs,
  ...
}: {
  # -- nx: noctalia-export — ported from this repo's former standalone
  # `noctalia-export` fish function into nx's dispatcher/style. Both steps
  # write to scratch files first and only replace the tracked noctalia.json
  # if the whole export succeeded — a failing jq would otherwise have
  # already truncated the tracked file via its own `>` before erroring.
  # Uses `${repoDir}#myNoctalia` (absolute) rather than upstream's `.#`,
  # so unlike the original this no longer requires running from the repo
  # root.

  programs.fish.functions = {
    __nx_cmd_noctalia_export = ''
      __nx_stage "Exporting noctalia-shell settings"
      set -l state_tmp (mktemp)
      set -l settings_tmp (mktemp)
      # 'state all' dumps {settings, state}; the wrapper feeds settings.json
      # directly from this file, so keep only the flat 'settings' blob.
      nix run ${repoDir}#myNoctalia -- ipc call state all > $state_tmp
      and ${pkgs.jq}/bin/jq .settings $state_tmp > $settings_tmp
      set -l export_status $status
      if test $export_status -eq 0
        mv $settings_tmp ${repoDir}/modules/features/noctalia/noctalia.json
        __nx_ok "modules/features/noctalia/noctalia.json updated"
      else
        rm -f $settings_tmp
        __nx_fail "Export failed — is noctalia-shell running? (ipc call requires a live instance)"
      end
      rm -f $state_tmp
      return $export_status
    '';
  };
}
