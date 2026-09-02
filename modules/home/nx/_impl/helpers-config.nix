{
  repoDir,
  pkgs,
  ...
}: {
  # -- nx: helpers for introspecting/editing the flake's own files --
  #
  # Adapted from upstream (github:Lunobe/Nx) for this repo's layout: the
  # package list lives in modules/home/apps.nix, nested one level deeper
  # (under `flake.homeModules.apps = { pkgs, lib, ... }: { home.packages =
  # ... }`) than upstream's flat modules/packages.nix, so the indent below
  # is 4/6 spaces instead of upstream's 2/4. Sorting was dropped entirely
  # (see cmd-format.nix) since this file groups packages under #UTILS/
  # #DEVELOPMENT/etc. comments that a blind alphabetical sort would scramble.

  programs.fish.functions = {
    __nx_config_files = ''
      # walk the import graph starting at flake.nix, following relative-path
      # references, so new modules are picked up automatically. a reference
      # may be a .nix file directly, or a bare directory (e.g. "./nx", the
      # nix equivalent of "./nx/default.nix") — resolved below. references
      # that are neither (e.g. a fish alias like "../..") are silently skipped
      set -l root ${repoDir}
      set -l seen $root/flake.nix
      set -l queue $root/flake.nix
      while test (count $queue) -gt 0
        set -l f $queue[1]
        set -e queue[1]
        set -l dir (path dirname $f)
        for rel in (sed -E 's/#.*$//' $f 2>/dev/null | grep -ohE '\.\.?/[A-Za-z0-9_./-]+')
          set -l full (realpath -m $dir/$rel)
          if test -d $full
            set full $full/default.nix
            if not test -e $full
              continue
            end
          else if not string match -q '*.nix' $full
            continue
          end
          if not contains $full $seen
            set -a seen $full
            set -a queue $full
          end
        end
      end
      for f in $seen
        echo $f
      end
    '';

    __nx_packages_bounds = ''
      set -l file ${repoDir}/modules/home/apps.nix
      set -l start (grep -n '^    home\.packages = with pkgs; \[$' $file | head -n1 | cut -d: -f1)
      if test -z "$start"
        return 1
      end
      # search only after $start, not the whole file — otherwise an
      # earlier "];" belonging to some other list would be picked up
      set -l tail_start (math $start + 1)
      set -l end (sed -n "$tail_start,\$ p" $file | grep -n '^    \];$' | head -n1 | cut -d: -f1)
      if test -z "$end"
        return 1
      end
      set end (math $end + $start)
      echo $start
      echo $end
    '';

    __nx_format = ''
      ${pkgs.alejandra}/bin/alejandra -q ${repoDir}
    '';

    __nx_list_packages = ''
      set -l file ${repoDir}/modules/home/apps.nix
      set -l bounds (__nx_packages_bounds)
      or return 0
      set -l items_start (math $bounds[1] + 1)
      set -l items_end (math $bounds[2] - 1)
      # drop blank lines and #-comment section headers — only actual
      # package attrs are meaningful for install/uninstall/list
      sed -n "$items_start,$items_end p" $file | string trim | string match -v -r '^(#.*)?$'
    '';
  };
}
