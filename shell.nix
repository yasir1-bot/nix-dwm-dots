# shell.nix — zsh. The prompt uses terminal palette colours, so it follows the wallpaper for free.
{ pkgs, settings, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;       # grey history suggestion, → to accept
    syntaxHighlighting.enable = true;    # red = command not found
    histSize = 10000;

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
      ".." = "cd ..";
      v = "nvim";
      rebuild = "sudo nixos-rebuild switch";        # uses nix.nixPath from config.nix
      rebuild-test = "sudo nixos-rebuild test";     # activate without making it the boot default
      gens = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
    };

    # Replaces NixOS' default prompt. %F{4} = ANSI colour 4 = pywal's accent.
    promptInit = ''
      PROMPT='%F{4}%~%f %(?.%F{5}.%F{1})❯%f '
      RPROMPT='%F{8}%n@%m%f'
    '';

    interactiveShellInit = ''
      setopt auto_cd hist_ignore_dups share_history interactive_comments
      bindkey -e                                    # emacs-style line editing
      bindkey '^[[3~' delete-char                   # Delete key
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    '';
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # zsh runs a first-start wizard if ~/.zshrc is missing. The `f` rule creates an EMPTY file only
  # when none exists — it never overwrites yours. (Real config lives in /etc/zshrc, from above.)
  systemd.tmpfiles.rules = [
    "f /home/${settings.username}/.zshrc 0644 ${settings.username} users -"
  ];
}
