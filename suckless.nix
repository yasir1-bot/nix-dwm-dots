# suckless.nix — dwm, dmenu and st, rebuilt from nixpkgs' source with OUR patches and config.
#
# How it works (same for all three):
#   1. nixpkgs downloads the pinned upstream tarball (dwm 6.6, dmenu 5.4, st 0.9.3 on NixOS 26.05).
#   2. `patches` are applied in order (plain `patch -p1`, files live in ./patches).
#   3. `postPatch` then drops in our config.def.h and the generated colors.h next to the source.
#   4. dwm/dmenu/st are compiled. Colours are therefore baked into the binaries:
#      a new wallpaper means a rebuild — that is the price of a fully declarative palette.
{ pkgs, colorsH }:

{
  dwm = pkgs.dwm.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/dwm/alpha-6.3.diff         # translucent bar (needs picom)
      ./patches/dwm/vanitygaps-6.6.diff    # gaps between windows and screen edge
    ];
    buildInputs = old.buildInputs ++ [ pkgs.libxrender ];   # alpha patch links -lXrender
    postPatch = (old.postPatch or "") + ''
      cp ${./suckless/dwm/config.def.h} config.def.h
      cp ${colorsH} colors.h

      # The last drw.c change of the alpha patch (draw text with the 32-bit visual) is done here
      # instead of in the .diff: dwm 6.6's drw_text() is laid out differently from the 6.3 the
      # patch was written for, and a diff hunk cannot find it. This substitution ignores layout.
      sed -z -E 's/XftDrawCreate\(drw->dpy, drw->drawable,[[:space:]]*DefaultVisual\(drw->dpy, drw->screen\),[[:space:]]*DefaultColormap\(drw->dpy, drw->screen\)\)/XftDrawCreate(drw->dpy, drw->drawable, drw->visual, drw->cmap)/' -i drw.c
      if grep -q DefaultVisual drw.c; then echo "alpha: XftDrawCreate substitution did not match" >&2; exit 1; fi
    '';
  });

  dmenu = pkgs.dmenu.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/dmenu/alpha-5.4.diff       # translucent menu (5.3 patch, ported to 5.4 by hand)
    ];
    buildInputs = old.buildInputs ++ [ pkgs.libxrender ];
    postPatch = (old.postPatch or "") + ''
      cp ${./suckless/dmenu/config.def.h} config.def.h
      cp ${colorsH} colors.h
    '';
  });

  st = pkgs.st.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/st/anysize-simple-0.9.diff # terminal fills its window exactly (no gap strip next to gaps)
      ./patches/st/config.diff             # OUR config: font, border, pywal colours (small diff of config.def.h)
    ];
    postPatch = (old.postPatch or "") + ''
      cp ${colorsH} colors.h
    '';
  });
}
