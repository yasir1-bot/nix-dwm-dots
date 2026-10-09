# desktop.nix — X11 + ly login screen + dwm session + picom + fonts + lock screen + audio.
{ pkgs, settings, theme, ... }:

let
  suckless = import ./suckless.nix { inherit pkgs; inherit (theme) colorsH; };

  # The text in dwm's bar. dwm shows whatever is set as the X root window's name.
  statusbar = pkgs.writeShellApplication {
    name = "statusbar";
    runtimeInputs = [ pkgs.xsetroot pkgs.wireplumber pkgs.gawk pkgs.coreutils ];
    text = builtins.readFile ./scripts/statusbar.sh;
  };
in
{
  # --- X11 and the login screen -------------------------------------------
  services.xserver = {
    enable = true;
    xkb.layout = settings.xkbLayout;
    autoRepeatDelay = 250;       # ms before a held key repeats
    autoRepeatInterval = 30;     # ms between repeats

    # NixOS' dwm module registers an X session called "dwm" and runs dwm inside it.
    windowManager.dwm = {
      enable = true;
      package = suckless.dwm;

      # THE one place for startup programs (this is our ".xinitrc"). It runs once, after login,
      # just before dwm starts. Output/errors land in ~/.xsession-errors.
      # Every program is started here and only here, so nothing runs twice.
      extraSessionCommands = ''
        xsetroot -cursor_name left_ptr                 # replace the ugly default "X" cursor
        feh --no-fehbg --bg-fill ${theme.wallpaper} &  # wallpaper = the same file the colours came from
        picom --config ${./config/picom.conf} &        # compositor: transparency, blur, shadows
        ${statusbar}/bin/statusbar &                   # bar text; exits by itself when X closes
      '';
    };
  };

  # ly: a tiny text-mode login screen. It lists the sessions NixOS registered (here: just dwm).
  services.displayManager = {
    ly.enable = true;
    defaultSession = "none+dwm";
  };

  # --- Lock screen: slock (suckless). Super+Shift+x. Blank screen, type password, Enter. ---
  programs.slock.enable = true;

  # --- Fonts ---------------------------------------------------------------
  fonts = {
    packages = [ pkgs.nerd-fonts.jetbrains-mono ];   # also gives icon glyphs in terminal/Neovim
    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # --- Cursor and GTK look (GTK apps read /etc/xdg/gtk-*/settings.ini) -----------
  environment.pathsToLink = [ "/share/icons" ];
  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    XCURSOR_PATH = [ "/run/current-system/sw/share/icons" ];
  };
  programs.dconf.enable = true;    # GTK apps complain in the logs without it
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=24
    gtk-icon-theme-name=Adwaita
    gtk-font-name=Sans 10
  '';
  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=24
    gtk-font-name=Sans 10
  '';

  # --- Audio (volume keys use wpctl) and laptop brightness ---------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.udev.packages = [ pkgs.brightnessctl ];   # lets the "video" group change brightness

  # --- Programs on the PATH ------------------------------------------------------
  environment.systemPackages = [
    suckless.st
    suckless.dmenu
    pkgs.picom
    pkgs.feh
    pkgs.xsetroot
    pkgs.xclip              # clipboard for Neovim and shell
    pkgs.brightnessctl
    pkgs.wireplumber        # wpctl
    pkgs.adwaita-icon-theme # cursor theme
  ];
}
