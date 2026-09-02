{
  self,
  inputs,
  ...
}: {
  # nx — fish CLI for managing this flake (build/deploy/update/packages),
  # vendored and trimmed from https://github.com/Lunobe/Nx for this repo's
  # layout. See docs/nx.md for what was changed and why.
  #
  # Implementation files live under _impl/ (not directly here) so
  # import-tree's directory walk skips them (it ignores any path
  # containing "/_") and only this default.nix -- the real flake-parts
  # module -- gets auto-discovered; the cmd-*/helpers-*/dispatcher files
  # are plain home-manager modules, not flake-parts modules, and would
  # error if import-tree tried to import them directly.
  flake.homeModules.nx = {...}: {
    imports = [
      ./_impl/helpers-ui-git.nix
      ./_impl/helpers-config.nix
      ./_impl/cmd-deploy.nix
      ./_impl/cmd-switch.nix
      ./_impl/cmd-noctalia-export.nix
      ./_impl/cmd-format.nix
      ./_impl/cmd-maintenance.nix
      ./_impl/cmd-packages.nix
      ./_impl/cmd-search-config.nix
      ./_impl/cmd-nuke-history.nix
      ./_impl/dispatcher.nix
    ];
  };
}
