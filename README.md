# NixOS + dwm dotfiles

A small, readable, fully declarative X11 desktop for NixOS 26.05. No flakes, no overlays, no Home Manager:
plain NixOS modules and one patched copy each of dwm, dmenu and st.

| Part | Choice |
|---|---|
| Window manager | dwm 6.6 + `alpha` (translucent bar) + `vanitygaps` |
| Launcher | dmenu 5.4 + `alpha` |
| Terminal | st 0.9.3 + `anysize` + our config patch |
| Compositor | picom (shadows, fade, blur, terminal transparency) |
| Login screen | ly |
| Lock screen | slock (suckless), `Super+Shift+x` |
| Shell / editor | zsh / Neovim (+ `vim-nix`) |
| Wallpaper + colours | feh + pywal (`pywal16`), generated at build time |
| Font | JetBrainsMono Nerd Font |

## Repository layout

```
config.nix            entry point: boot, network, user, imports the rest (start reading here)
settings.nix          the only file you must edit: username, timezone, keyboard, wallpaper
desktop.nix           X11, ly, dwm session + startup programs, fonts, GTK/cursor, audio, slock
theme.nix             wallpaper -> palette (pywal) -> colors.h + Neovim colours
suckless.nix          builds dwm/dmenu/st: upstream source + patches + our config
shell.nix  editor.nix zsh, Neovim
suckless/{dwm,dmenu}/config.def.h   full configs (C, with comments). st: patches/st/config.diff
patches/              every patch applied, one file each
config/picom.conf     compositor settings
nvim/init.lua         Neovim options and keys
scripts/statusbar.sh  dwm bar text (volume, battery, date)
wallpapers/           default.png (replace it)
hardware-configuration.nix   NOT in the repo yet: you copy it in (step 3)
```

## Install

Assumes a normal NixOS 26.05 install already exists (graphical installer's "No desktop" is fine) and you are logged in on a text console.

1. **Get the repo**: `git clone <your-fork-url> ~/dotfiles` (or copy this folder to `~/dotfiles`).
2. **Edit `settings.nix`**: `username` must equal your installer user. If the repo is not in `~/dotfiles`, fix `dotfiles`. Check `timezone`, `xkbLayout`, `ttyKeymap`.
3. **Copy your hardware file**: `cp /etc/nixos/hardware-configuration.nix ~/dotfiles/`
4. **Check the bootloader in `config.nix`** (UEFI systemd-boot is the default; BIOS needs the GRUB lines shown there). Compare `system.stateVersion` with `/etc/nixos/configuration.nix` and use that value.
5. **Build without activating first**: `sudo nixos-rebuild build -I nixos-config=$HOME/dotfiles/config.nix`
   (compiles pywal colours + three small C programs; a few minutes at most). Fix any error before continuing.
6. **Switch**: `sudo nixos-rebuild switch -I nixos-config=$HOME/dotfiles/config.nix`
   From now on `rebuild` (an alias) or plain `sudo nixos-rebuild switch` works.
7. **Reboot.** ly appears; log in; you land in dwm. Press `Super+Return` for a terminal.

## Keys (Super = Windows key; change `MODKEY` in `suckless/dwm/config.def.h` to `Mod1Mask` for Alt)

| Key | Action |
|---|---|
| `Super+Return` / `Super+p` | terminal / dmenu launcher |
| `Super+j` `k` | focus next / previous window |
| `Super+Shift+Return` | swap focused window with master |
| `Super+h` `l` | shrink / grow master area |
| `Super+i` `d` | more / fewer master windows |
| `Super+t` `m` `f` `c` | tile / monocle / floating / centred-master layout |
| `Super+Shift+Space` | toggle floating for this window |
| `Super+1..9`, `Super+Shift+1..9` | view tag / move window to tag |
| `Super+0` | view all tags |
| `Super+-` `=` | smaller / bigger gaps; `Super+g` toggle gaps; `Super+Shift+g` reset |
| `Super+b` | hide/show bar |
| `Super+Shift+c` | close window |
| `Super+Shift+x` | lock screen (slock) |
| `Super+Shift+q` | quit dwm (back to ly) |
| volume / brightness keys | `wpctl` / `brightnessctl` |

## How the theme works (declarative vs runtime)

```
wallpapers/default.png --(pywal inside the Nix sandbox)--> palette --> colors.h
                                                               |--> dwm, dmenu, st are compiled with it
                                                               |--> Neovim highlight groups
                                                               '--> zsh prompt (uses the terminal's own palette)
```

* **Declarative (everything):** the palette is computed during `nixos-rebuild`, so the same wallpaper always gives the same colours and nothing is written to the immutable store afterwards.
* **Not runtime:** there is no `wal` run at login and no files in `~/.cache/wal`. The trade-off: *changing the wallpaper needs a rebuild and a restart of dwm*. Open terminals keep their old colours until closed.
* **To change the theme:** put an image in `wallpapers/`, point `wallpaper` in `settings.nix` at it, then `rebuild`, then `Super+Shift+q` and log in again.
* **Tip:** pywal reads the *image*, so busy or very bright pictures give odd palettes. We pass `--contrast 4.5` so text stays readable regardless. Dark, smooth images look best.
* **Roles** (`bg fg dim accent urgent`) are defined once in `theme.nix`; change which pywal colour fills a role there and the whole desktop follows.

### Why not `Fuwn/pywal.nix`?
It is a Home Manager module, imported through flake-compat, and its colour step builds four extra back-ends (some from git with submodules) every time. That is more machinery than this setup wants, so `theme.nix` does the same thing in a few lines with nixpkgs' `pywal16` (nixpkgs 26.05 has no plain `pywal`). Same idea: run pywal at evaluation time, read the JSON.

## Patches

| Patch | For | What it does | Notes |
|---|---|---|---|
| `alpha-6.3` | dwm | Translucent bar (`baralpha` in config) | Needs picom running (it is) |
| `vanitygaps-6.6` | dwm | Gaps between windows and screen edge | Config: `gapp*` variables, gap keys |
| `alpha-5.4` | dmenu | Translucent menu | Upstream patch is for 5.3; two hunks ported by hand to 5.4 |
| `anysize-simple-0.9` | st | Terminal fills its tile exactly | Otherwise st leaves a blank strip next to the gaps |
| `config.diff` | st | Font, border, pywal palette | Our own small diff of `config.def.h` |

dwm/dmenu/st patches come from the suckless.org patch pages (via bakkeby's mirror on GitHub); each file keeps its original header.

**st background alpha is intentionally not patched in.** Terminal transparency comes from picom (`opacity-rule` in `config/picom.conf`). That makes the text slightly translucent too, but keeps st on a tiny patch list. To switch later, add an st alpha patch for 0.9.3 to `patches/st/` and remove the rule.

## Everyday tasks

* **Add a program:** add it to `environment.systemPackages` in `desktop.nix` (e.g. `pkgs.firefox`), then `rebuild`. Search names at search.nixos.org.
* **Change a key / gap / font in dwm:** edit `suckless/dwm/config.def.h`, `rebuild`, restart dwm. (dmenu: `suckless/dmenu/config.def.h`. st: edit `patches/st/config.diff`, or add more lines to it.)
* **Add a patch:** drop the `.diff` in `patches/<app>/`, list it in `suckless.nix`. If it conflicts the *build fails* with the rejected hunk, nothing breaks.
* **Startup programs:** `extraSessionCommands` in `desktop.nix` is the single place. Do not also add them elsewhere.
* **Change the picom look:** `config/picom.conf`; run `pkill picom; picom --config config/picom.conf &` to try changes live, rebuild to keep them.
* **Clean old generations:** `sudo nix-collect-garbage --delete-older-than 14d` (this removes rollback points).

## Recovery

* **Build fails:** nothing changed. Read the last lines of the error; `rebuild` again after fixing.
* **New config boots but the desktop is broken:** at the systemd-boot menu choose an older generation, or on a text console (`Ctrl+Alt+F3`) run `sudo nixos-rebuild switch --rollback`.
* **Can't log in graphically:** `Ctrl+Alt+F3` gives a text login. Look at `~/.xsession-errors` and `journalctl -b -u display-manager`.
* **Try before committing:** `sudo nixos-rebuild test` activates the config but does *not* make it the boot default; a reboot returns to the previous one.
* **Black screen / flicker after picom starts:** change `backend = "glx"` to `"xrender"` in `config/picom.conf`.
* **Wrong keyboard layout in ly/console:** `ttyKeymap` (console) vs `xkbLayout` (X11) in `settings.nix`.
* Your files in `/home` are never touched by a rebuild. The only file created there is an empty `~/.zshrc` if you have none (prevents zsh's first-run wizard).

## What has and has not been tested

Checked while writing this (Linux container, no NixOS machine available):

* The full NixOS configuration **evaluates** against the nixos-26.05 nixpkgs tree (option names, module wiring, `theme.nix` text generation, package overrides).
* pywal16 with exactly the flags used in `theme.nix` produces the expected `colors.json`.
* The patches apply to upstream sources and all three programs **compile and link** with our configs. Exact versions: dmenu 5.4 and st 0.9.3 identical to nixpkgs 26.05; for dwm the container only had 6.5 (nixpkgs ships 6.6, and the patch files are the ones published for 6.6), so dwm is verified against the nearest release.
* `statusbar.sh` passes shellcheck.

**Not tested:** an actual `nixos-rebuild` on real hardware, ly + dwm session start, picom on your GPU, audio/brightness keys, slock. If the dwm patch step fails on first build, it fails loudly in the patch phase with the rejected hunk. The nearest fix is to rebase `patches/dwm/alpha-6.3.diff` against dwm 6.6 or pin an older dwm tarball.

Hardware-specific settings: bootloader (UEFI vs BIOS), `brightnessctl` (laptops only), picom backend, `hardware-configuration.nix`, keyboard layout.

## Learning path

Read in this order: `settings.nix` -> `config.nix` -> `desktop.nix` -> `theme.nix` -> `suckless.nix` -> `suckless/dwm/config.def.h`.
