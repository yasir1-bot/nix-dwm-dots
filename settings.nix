# settings.nix — the one file you edit to make this setup yours.
# It is a plain Nix attribute set (no modules, no magic); the other files read from it.
{
  username  = "yasir";          # must match the user you created in the NixOS installer
  hostname  = "nixos";
  timezone  = "Europe/London";
  locale    = "en_GB.UTF-8";
  xkbLayout = "gb";             # keyboard layout inside X11 (see: localectl list-x11-keymap-layouts)
  ttyKeymap = "uk";             # keyboard layout on the text console (differs from X11 for the UK!)

  # Where you cloned this repository. Used so that plain `sudo nixos-rebuild switch` finds config.nix.
  dotfiles  = "/home/yasir/dotfiles";

  # THE theming switch: change this path, rebuild, restart dwm — every colour follows.
  wallpaper = ./wallpapers/default.png;
  lightTheme = false;           # true = pywal's light palette
}
