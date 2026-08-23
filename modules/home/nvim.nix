{ self, inputs, ... }: {
  flake.homeModules.nvim = { pkgs, ... }: {
    home.packages = with pkgs; [
      neovim
      fd
      lazygit
    ];

    xdg.configFile."nvim" = {
      source = ./nvim;
      recursive = true;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
