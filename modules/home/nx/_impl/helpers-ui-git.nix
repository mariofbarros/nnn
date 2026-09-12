{repoDir, ...}: {
  # -- nx: shared UI/git helpers --

  programs.fish.functions = {
    __nx_stage = ''
      echo ""
      set_color -o blue
      echo -n "==> "
      set_color normal
      echo "$argv[1]"
    '';

    # printed right after a stage's action finishes, so a step that
    # produces no output of its own doesn't leave it unclear whether it
    # actually ran — only call this once the action is known to have
    # succeeded (after any status check for that step); takes an
    # optional trailing note, e.g. __nx_ok "3 generations removed"
    __nx_ok = ''
      set_color -o green
      if test -n "$argv[1]"
        echo "OK — $argv[1]"
      else
        echo "OK"
      end
      set_color normal
    '';

    # short, best-guess diagnosis printed after a command fails, so the
    # relevant line isn't just lost above a wall of build/eval output
    __nx_fail = ''
      echo ""
      set_color -o red
      echo -n "!! "
      set_color normal
      echo "$argv[1]"
    '';

    # "found something, but it's not an error" — distinct from __nx_ok so a
    # genuinely clean pass and "review the report above" don't both read as
    # plain green OK; the caller still continues/returns 0 either way
    __nx_warn = ''
      set_color -o yellow
      echo -n "!  "
      set_color normal
      echo "$argv[1]"
    '';

    __nx_diff_dirty = ''
      # -N stages new files by path only (no content), so they show up
      # in the diff below as additions instead of being invisible
      git -C ${repoDir} add -N -A
      git -C ${repoDir} diff HEAD
    '';

    __nx_commit_if_dirty = ''
      set -l changes (git -C ${repoDir} status --porcelain)
      if test (count $changes) -gt 0
        __nx_stage "Changes to commit:"
        __nx_diff_dirty
        git -C ${repoDir} add -A
        git -C ${repoDir} commit -m "$argv[1]"
      end
    '';

    # like __nx_commit_if_dirty, but without the diff preview — for call
    # sites where the diff was already shown to the user just before
    __nx_commit_quiet = ''
      set -l changes (git -C ${repoDir} status --porcelain)
      if test (count $changes) -gt 0
        git -C ${repoDir} add -A
        git -C ${repoDir} commit -m "$argv[1]"
      end
    '';

    # prompts "$argv[1] [y/N] "; returns 0 on y/yes (any case), 1 otherwise
    __nx_confirm = ''
      echo ""
      read -l -P "$argv[1] [y/N] " confirm
      switch "$confirm"
        case y Y yes Yes YES
          return 0
        case '*'
          return 1
      end
    '';

    # if there are pending changes: shows the diff, asks "$argv[1] [y/N] ",
    # and on yes commits with message "$argv[2]" — used by up/push, which
    # (unlike deploy) commit immediately with no build step in between;
    # returns 1 (and prints "Aborted.") only when declined, not when there
    # was simply nothing to commit
    __nx_confirm_and_commit = ''
      set -l changes (git -C ${repoDir} status --porcelain)
      if test (count $changes) -eq 0
        return 0
      end
      __nx_stage "Changes to commit:"
      __nx_diff_dirty
      if __nx_confirm "$argv[1]"
        git -C ${repoDir} add -A
        git -C ${repoDir} commit -m "$argv[2]"
        return 0
      else
        echo "Aborted."
        return 1
      end
    '';

    # undoes a commit made by __nx_commit_quiet/__nx_commit_if_dirty, but
    # only if one actually happened (HEAD moved past $argv[1]) — leaves
    # the changes staged, as if the commit had never been made
    __nx_rollback_commit = ''
      if test (git -C ${repoDir} rev-parse HEAD) != "$argv[1]"
        git -C ${repoDir} reset --soft "$argv[1]"
      end
    '';

    # fetches origin and, if HEAD is only *behind* (never ahead), fast-
    # forwards local HEAD to match — always conflict-free by definition.
    # If HEAD has also diverged (both ahead and behind), refuses and tells
    # the caller to resolve manually rather than risk an unattended rebase.
    # Called before any staging/commit by deploy/up/push so a stale local
    # branch never gets new auto-commits piled on top of it. Offline or no
    # upstream configured is not an error -- just skip the check.
    __nx_git_sync = ''
      git -C ${repoDir} fetch origin >/dev/null 2>&1
      if test $status -ne 0
        __nx_warn "Couldn't reach 'origin' (offline?) — skipping remote sync check."
        return 0
      end

      set -l upstream (git -C ${repoDir} rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
      if test -z "$upstream"
        __nx_warn "No upstream branch configured — skipping remote sync check."
        return 0
      end

      set -l counts (git -C ${repoDir} rev-list --left-right --count 'HEAD...@{u}')
      set -l parts (string split -m1 \t -- $counts)
      set -l ahead $parts[1]
      set -l behind $parts[2]

      if test "$behind" -eq 0
        return 0
      end

      if test "$ahead" -eq 0
        __nx_stage "Fast-forwarding to $upstream"
        git -C ${repoDir} merge --ff-only "$upstream"
        if test $status -ne 0
          __nx_fail "Fast-forward failed unexpectedly — check 'git -C ${repoDir} status'."
          return 1
        end
        __nx_ok
        return 0
      end

      __nx_fail "Local and $upstream have diverged ($ahead ahead, $behind behind) — resolve manually with 'git -C ${repoDir} pull --rebase', then retry."
      return 1
    '';

    __nx_untrack_ignored = ''
      set -l tracked_ignored (git -C ${repoDir} ls-files -ci --exclude-standard)
      if test (count $tracked_ignored) -eq 0
        return 0
      end
      __nx_stage "Untracking files matching .gitignore"
      git -C ${repoDir} rm --cached -r -q -f $tracked_ignored
    '';
  };
}
