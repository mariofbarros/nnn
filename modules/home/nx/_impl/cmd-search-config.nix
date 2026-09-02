{
  repoDir,
  hostName,
  pkgs,
  ...
}: {
  # -- nx: search, config --
  #
  # Trimmed from upstream's cmd-secret-search-config.nix: the `secret`
  # command needed agenix (not used in this repo), so it was dropped along
  # with this file's name. `search meta` uses pkgs.jq directly instead of
  # upstream's nix-index-database `,` shorthand, and `search option` uses
  # pkgs.nixos-option explicitly since it isn't guaranteed to be on PATH
  # here.

  programs.fish.functions = {
    __nx_cmd_search = ''
      switch "$argv[2]"
        case option
          ${pkgs.nixos-option}/bin/nixos-option $argv[3..-1] 2>/dev/null
          or begin
            __nx_stage "No exact path — searching option names/descriptions for '$argv[3]'"
            env NX_Q=$argv[3] nix eval --impure --raw --expr '
              let
                query = builtins.getEnv "NX_Q";
                sys = (builtins.getFlake "${repoDir}").nixosConfigurations.${hostName};
                lib = sys.lib;
                docs = lib.optionAttrSetToDocList sys.options;
                allMatches = builtins.filter (o: lib.hasInfix query (lib.concatStringsSep "." o.loc)) docs;
                matches = lib.take 30 allMatches;
                describe = o:
                  let d = if o ? description then (if builtins.isString o.description then o.description else o.description.text or "") else "";
                  in lib.head (lib.splitString "\n" d);
                formatted =
                  if matches == [] then "No matching options for ''${query}."
                  else lib.concatStringsSep "\n\n" (map (o: "''${lib.concatStringsSep "." o.loc}\n  ''${describe o}") matches);
                suffix = if builtins.length allMatches > 30 then "\n\n... and ''${toString (builtins.length allMatches - 30)} more (refine your query)" else "";
              in
                formatted + suffix
            '
          end
        case meta
          # locked flake's nixpkgs, not the registry — same reasoning
          # as the install exact-match check above
          nix eval --json "${repoDir}#nixosConfigurations.${hostName}.pkgs.$argv[3].meta" | ${pkgs.jq}/bin/jq .
        case search
          nix search nixpkgs $argv[3..-1]
        case lib
          __nx_manix_ensure_cache
          set -l query (string join ' ' $argv[3..-1])
          # scoped to nixpkgs/lib docs + inline comments — option lookup is
          # already covered, more accurately, by the 'option' case above
          # (live against this exact flake, not a prebuilt cache)
          ${pkgs.manix}/bin/manix --source nixpkgs-doc,nixpkgs-tree,nixpkgs-comments "$query"
        case '*'
          nix search nixpkgs $argv[2..-1]
      end
    '';

    # builds manix's doc cache on first use only — subsequent 'nx search lib'
    # calls reuse it; if nixpkgs moves on and the cache goes stale, delete
    # ~/.cache/manix by hand to force a rebuild
    __nx_manix_ensure_cache = ''
      if not test -d ~/.cache/manix
        __nx_stage "Building manix cache (first run only)"
        ${pkgs.manix}/bin/manix --update-cache
        __nx_ok
      end
    '';

    __nx_cmd_config = ''
      __nx_stage "Opening configuration files"
      set -q EDITOR
      or set -l EDITOR vi
      $EDITOR (__nx_config_files)
    '';
  };
}
