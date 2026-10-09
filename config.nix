# config.nix — main entry point. Read this file first; it imports everything else.
#
#   config.nix        (this file)  system basics: boot, network, user, locale
#   settings.nix                   your personal values (username, wallpaper, ...)
#   desktop.nix                    X11, ly, dwm session, picom, fonts, lock screen, audio
#   theme.nix                      wallpaper -> colours (pywal, at build time)
#   suckless.nix                   dwm / st / dmenu built with patches + our configs
#   shell.nix                      zsh
#   editor.nix                     Neovim
{ config, pkgs, ... }:

let
  settings = import ./settings.nix;
in
{
  imports = [
    ./hardware-configuration.nix   # copied from /etc/nixos — see README step 3
    ./desktop.nix
    ./shell.nix
    ./editor.nix
  ];

  # Values shared with the other files. Modules receive them as function arguments
  # (that is why desktop.nix starts with `{ pkgs, settings, theme, ... }:`).
  _module.args = {
    inherit settings;
    theme = import ./theme.nix {
      inherit pkgs;
      wallpaper = settings.wallpaper;
      light = settings.lightTheme;
    };
  };

  # --- Boot ---------------------------------------------------------------
  # HARDWARE-SPECIFIC: this is the UEFI setup. On an old BIOS/MBR machine use instead:
  #   boot.loader.grub = { enable = true; device = "/dev/sda"; };   # your disk, not a partition
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;   # keep 20 generations to roll back to

  # --- Network, time, language ---------------------------------------------
  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true;           # `nmtui` in a terminal to join Wi-Fi
  time.timeZone = settings.timezone;
  i18n.defaultLocale = settings.locale;
  console.keyMap = settings.ttyKeymap;

  # --- User -----------------------------------------------------------------
  # If this user already exists (created by the installer) its password is kept,
  # because users.mutableUsers defaults to true. Nothing here touches /home.
  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Plain `sudo nixos-rebuild switch` should use THIS repo, not /etc/nixos.
  nix.nixPath = [
    "nixos-config=${settings.dotfiles}/config.nix"
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  ];
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = with pkgs; [ git curl ];

  # IMPORTANT: set this to the NixOS release you FIRST installed (see /etc/nixos/configuration.nix
  # from your installer, or `nixos-version`). It is NOT "the version you run now"; do not bump it
  # casually — it protects old stateful data formats.
  system.stateVersion = "26.05";
}
