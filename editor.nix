# editor.nix — Neovim: a small readable init.lua, one plugin, pywal colours.
{ pkgs, theme, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      # Lua run at startup: our options first, then the generated colour scheme.
      customLuaRC = ''
        dofile("${./nvim/init.lua}")
        dofile("${theme.nvimColors}")
      '';
      packages.dotfiles.start = [
        pkgs.vimPlugins.vim-nix    # syntax highlighting + indentation for .nix files
      ];
    };
  };
}
