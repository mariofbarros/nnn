{
  repoDir,
  hostName,
  ...
}: {
  # -- nx: dispatcher, help, completions --
  #
  # Trimmed from upstream: no `secret` (needs agenix, not used in this
  # repo) and no `vm` (needs a btrfs ~/vmware subvolume + Cloudflare R2,
  # not used here either). Two commands added beyond upstream: `switch`
  # and `noctalia-export`, ported from this repo's former standalone
  # `nrs`/`noctalia-export` fish functions into nx's dispatcher/style.

  programs.fish.functions = {
    __nx_help = ''
      echo "nx — manage the NixOS configuration in ${repoDir}"
      echo ""
      echo "Usage: nx <command>"
      echo ""
      echo "Commands:"
      set -l sep "  ────────────────────────────────────────────────────────────────────────"
      echo ""
      echo $sep
      echo ""
      echo "  format        format/lint every .nix file"
      echo "                1. format every .nix file (alejandra)"
      echo "                2. lint for antipatterns (statix) — prints findings, never fails"
      echo "                3. lint for dead code (deadnix) — prints findings, never fails"
      echo ""
      echo $sep
      echo ""
      echo "  switch        plain nixos-rebuild switch, verified against what's actually"
      echo "                running afterward — lighter than 'deploy': no git staging/"
      echo "                commit, no flake check, no scratch-dir build/rollback"
      echo "                1. warn if run from inside the graphical session (a"
      echo "                   users/shells/PAM change can disrupt activation mid-switch)"
      echo "                2. sudo nixos-rebuild switch --flake ${repoDir}#${hostName}"
      echo "                3. compare the registered generation against what's actually"
      echo "                   running — a display-manager restart mid-activation can"
      echo "                   report success without the system having switched over"
      echo ""
      echo $sep
      echo ""
      echo "  deploy        build and switch to the flake"
      echo "                1. stage everything (git add -A, no commit yet); if anything"
      echo "                   changed, show the diff and ask to proceed"
      echo "                2. commit the staged changes"
      echo "                3. nix flake check; nixos-rebuild build, into a scratch dir"
      echo "                4. if either fails: undo the commit from step 2 (leaving the"
      echo "                   changes staged) and stop — nothing broken ever lands in"
      echo "                   history"
      echo "                5. commit again if the build touched flake.lock, then print"
      echo "                   the closure diff (nvd) and switch to the new generation"
      echo ""
      echo $sep
      echo ""
      echo "  up            update flake inputs, then deploy"
      echo "                1. show pending local changes and ask to proceed"
      echo "                2. commit them (\"nx: auto-commit before update\")"
      echo "                3. nix flake update"
      echo "                4. if flake.lock didn't change, print that it's already"
      echo "                   up to date and stop — nothing to deploy"
      echo "                5. nx deploy"
      echo ""
      echo $sep
      echo ""
      echo "  clean --keep <n> | --all"
      echo "                garbage-collect the Nix store"
      echo "                every deploy/update leaves the previous system generation"
      echo "                and its packages behind in /nix/store, in case you need to"
      echo "                roll back — this deletes old generations and any store paths"
      echo "                no longer referenced by what's left, freeing disk space; you"
      echo "                lose the ability to roll back to whatever gets deleted"
      echo "                --keep <n>  delete generations older than <n> days"
      echo "                --all       delete all old generations (full gc)"
      echo "                no flags defaults to --keep 7"
      echo ""
      echo $sep
      echo ""
      echo "  list          print the packages currently in modules/home/apps.nix"
      echo ""
      echo $sep
      echo ""
      echo "  install <name>"
      echo "                add a package and deploy"
      echo "                1. try <name> as an exact attribute in the locked nixpkgs"
      echo "                2. if that fails, search nixpkgs and let you pick a match"
      echo "                   by number (cancel with an empty answer)"
      echo "                3. insert it into modules/home/apps.nix (skip if already there)"
      echo "                4. nx deploy"
      echo ""
      echo $sep
      echo ""
      echo "  uninstall <name>"
      echo "                remove a package and deploy (tab-completes against the"
      echo "                current package list)"
      echo "                1. remove <name> from modules/home/apps.nix (must already"
      echo "                   be listed)"
      echo "                2. nx deploy"
      echo ""
      echo $sep
      echo ""
      echo "  config        walk the import graph from flake.nix and open every file"
      echo "                it references in \$EDITOR"
      echo ""
      echo $sep
      echo ""
      echo "  noctalia-export"
      echo "                pull noctalia-shell's live settings back into the repo"
      echo "                1. dump live state via 'nix run ${repoDir}#<this host's noctalia"
      echo "                   package> -- ipc call state all', keep only its 'settings'"
      echo "                   blob (jq)"
      echo "                2. both steps write to scratch files first; only replace"
      echo "                   modules/features/noctalia/noctalia-<desktop|laptop>.json"
      echo "                   (whichever matches this host) if both succeeded"
      echo ""
      echo $sep
      echo ""
      echo "  push          commit pending changes and push to the remote"
      echo "                1. show pending local changes and ask to proceed"
      echo "                2. commit them (\"nx: update\")"
      echo "                3. git push"
      echo ""
      echo $sep
      echo ""
      echo "  nuke-history  squash all git history into one \"squashed into single commit\" and"
      echo "                force-push — rewrites remote history; a full backup is"
      echo "                saved locally first, but restoring from it is manual"
      echo "                1. warn about the consequences"
      echo "                2. show local changes and gitignored-but-tracked files that"
      echo "                   would be swept in / dropped"
      echo "                3. ask to confirm by typing NUKE"
      echo "                4. back up the full current history to .git-backups/"
      echo "                   (gitignored) as a timestamped git bundle"
      echo "                5. squash everything into one orphan commit, replacing"
      echo "                   the branch"
      echo "                6. force-push, overwriting the remote's history"
      echo ""
      echo $sep
      echo ""
      echo "  doctor        nx format, update flake inputs, nx deploy, then nx clean"
      echo "                --keep 7, then nx push, in that order"
      echo ""
      echo $sep
      echo ""
      echo "  search [search|option|meta|lib] <name>"
      echo "                search <name>         (default) nix search nixpkgs <name>"
      echo "                option <name>         nixos-option's exact lookup, falling"
      echo "                                       back to a substring search across"
      echo "                                       all option names/descriptions"
      echo "                meta <name>           a package's full metadata, as JSON"
      echo "                lib <name>            nixpkgs/lib function docs and inline"
      echo "                                       comments (manix; builds a local cache"
      echo "                                       on first use)"
      echo ""
      echo $sep
      echo ""
    '';

    __nx_help_short = ''
      echo "nx — manage the NixOS configuration in ${repoDir}"
      echo ""
      echo "Usage: nx <command>"
      echo ""
      echo "  format        format/lint every .nix file"
      echo "  switch        plain nixos-rebuild switch, verified against what's running"
      echo "  deploy        build and switch to the flake"
      echo "  up            update flake inputs, then deploy (skipped if nothing changed)"
      echo "  clean         --keep <n> | --all — garbage-collect the Nix store"
      echo "  list          print the packages currently in modules/home/apps.nix"
      echo "  install       add a package and deploy"
      echo "  uninstall     remove a package and deploy"
      echo "  search        [search|option|meta|lib] <name>"
      echo "  config        open every file in the flake's import graph in \$EDITOR"
      echo "  noctalia-export  sync noctalia-shell's live settings back into the repo"
      echo "  push          commit pending changes and push to the remote"
      echo "  nuke-history  squash all git history into one commit and force-push"
      echo "  doctor        nx format, update flake inputs, deploy, clean, push, in that order"
      echo ""
      echo "Run 'nx --help' for details."
    '';

    nx = ''
      switch "$argv[1]"
        case format
          __nx_cmd_format $argv
        case switch
          __nx_cmd_switch $argv
        case deploy
          __nx_cmd_deploy $argv
        case up
          __nx_cmd_up $argv
        case clean
          __nx_cmd_clean $argv
        case list
          __nx_list_packages
        case install
          __nx_cmd_install $argv
        case uninstall
          __nx_cmd_uninstall $argv
        case search
          __nx_cmd_search $argv
        case config
          __nx_cmd_config $argv
        case noctalia-export
          __nx_cmd_noctalia_export $argv
        case push
          __nx_cmd_push $argv
        case nuke-history
          __nx_cmd_nuke_history $argv
        case doctor
          __nx_cmd_doctor $argv
        case --help
          __nx_help
        case -h
          __nx_help_short
        case '*'
          __nx_fail "Unknown command '$argv[1]'."
          echo "Run 'nx -h' for brief usage, or 'nx --help' for the full details."
          return 1
      end
    '';
  };

  programs.fish.completions.nx = ''
    complete -c nx -f
    complete -c nx -n __fish_use_subcommand -a format -d 'format/lint .nix files'
    complete -c nx -n __fish_use_subcommand -a switch -d 'plain nixos-rebuild switch, verified against what is running'
    complete -c nx -n __fish_use_subcommand -a deploy -d 'check, build and switch to the flake'
    complete -c nx -n __fish_use_subcommand -a up -d 'update flake inputs, then deploy (skipped if unchanged)'
    complete -c nx -n __fish_use_subcommand -a clean -d 'garbage-collect the system (defaults to --keep 7)'
    complete -c nx -n "__fish_seen_subcommand_from clean" -l keep -d 'delete generations older than N days' -x
    complete -c nx -n "__fish_seen_subcommand_from clean" -l all -d 'delete all old generations (full gc)'
    complete -c nx -n __fish_use_subcommand -a list -d 'list packages currently in modules/home/apps.nix'
    complete -c nx -n __fish_use_subcommand -a install -d 'add a package to modules/home/apps.nix and deploy'
    complete -c nx -n __fish_use_subcommand -a uninstall -d 'remove a package from modules/home/apps.nix and deploy'
    complete -c nx -n "__fish_seen_subcommand_from uninstall" -a "(__nx_list_packages)" -d 'installed package'
    complete -c nx -n __fish_use_subcommand -a config -d 'open config files in $EDITOR'
    complete -c nx -n __fish_use_subcommand -a noctalia-export -d 'sync noctalia-shell settings back into the repo'
    complete -c nx -n __fish_use_subcommand -a push -d 'commit and push changes'
    complete -c nx -n __fish_use_subcommand -a nuke-history -d 'squash all history into one commit and force-push'
    complete -c nx -n __fish_use_subcommand -a doctor -d 'format + up (which deploys) + clean + push'
    complete -c nx -n __fish_use_subcommand -a search -d 'search nixpkgs packages, or inspect a NixOS option'
    complete -c nx -n "__fish_seen_subcommand_from search" -a option -d 'inspect a NixOS option (e.g. nx search option programs.niri.enable)'
    complete -c nx -n "__fish_seen_subcommand_from search" -a search -d 'search nixpkgs packages'
    complete -c nx -n "__fish_seen_subcommand_from search" -a meta -d 'show a package full metadata (e.g. nx search meta niri)'
    complete -c nx -n "__fish_seen_subcommand_from search" -a lib -d 'search nixpkgs/lib function docs and comments (e.g. nx search lib optionalString)'
    complete -c nx -n __fish_use_subcommand -a '--help' -d 'show detailed help'
    complete -c nx -n __fish_use_subcommand -a '-h' -d 'show brief help'
  '';
}
