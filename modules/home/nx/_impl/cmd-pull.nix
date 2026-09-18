{repoDir, ...}: {
  # -- nx: pull — thin wrapper around __nx_git_sync (the same fetch +
  # fast-forward-only helper deploy/up/push already run as their first
  # step), for when you just want this checkout caught up with the remote
  # without building, committing, or pushing anything.

  programs.fish.functions = {
    __nx_cmd_pull = ''
      __nx_git_sync
      or return 1
      __nx_ok (git -C ${repoDir} log -1 --format='%h %s')
    '';
  };
}
