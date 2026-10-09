/* dwm configuration — compiled into the binary by Nix (see suckless.nix).
 * Edit, then run `sudo nixos-rebuild switch` and restart dwm (Super+Shift+q, log in again).
 * Colours come from colors.h, which theme.nix generates from your wallpaper. */

#include <X11/XF86keysym.h>
#include "colors.h"

/* appearance */
static const unsigned int borderpx  = 2;        /* window border width */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* inner gap, horizontal */
static const unsigned int gappiv    = 10;       /* inner gap, vertical */
static const unsigned int gappoh    = 10;       /* outer gap (screen edge), horizontal */
static const unsigned int gappov    = 10;       /* outer gap (screen edge), vertical */
static       int smartgaps          = 0;        /* 1 = no outer gap with a single window */
static const int showbar            = 1;
static const int topbar             = 1;
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=11" };

/* alpha patch: 0x00 = invisible .. 0xff (OPAQUE) = solid. Needs picom running. */
static const unsigned int baralpha    = 0xd0;
static const unsigned int borderalpha = OPAQUE;

static const char *colors[][3] = {
	/*               fg       bg          border      */
	[SchemeNorm] = { col_fg,  col_bg,     col_dim     },
	[SchemeSel]  = { col_bg,  col_accent, col_accent  },
};
static const unsigned int alphas[][3] = {
	/*               fg      bg        border      */
	[SchemeNorm] = { OPAQUE, baralpha, borderalpha },
	[SchemeSel]  = { OPAQUE, OPAQUE,   borderalpha },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* class      instance    title       tags mask     isfloating   monitor */
	{ NULL,       NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 0;    /* 0 = ignore size hints: no gaps around terminals */
static const int lockfullscreen = 1;

#define FORCE_VSPLIT 1             /* required by vanitygaps.c (nrowgrid layout, unused here) */
#include "vanitygaps.c"            /* added by the vanitygaps patch */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle },
	{ "><>",      NULL },    /* floating */
	{ "|M|",      centeredmaster },
};

/* key definitions: Mod4 = Super (Windows key). Use Mod1Mask for Alt instead. */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands. dmenu and st find their own colours/fonts: they are built by Nix too. */
static char dmenumon[2] = "0"; /* filled in by dwm */
static const char *dmenucmd[]  = { "dmenu_run", "-m", dmenumon, NULL };
static const char *termcmd[]   = { "st", NULL };
static const char *lockcmd[]   = { "slock", NULL };

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY|ShiftMask,             XK_x,      spawn,          {.v = lockcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	/* vanitygaps: all gaps together; g toggles, Shift+g resets */
	{ MODKEY,                       XK_minus,  incrgaps,       {.i = -2 } },
	{ MODKEY,                       XK_equal,  incrgaps,       {.i = +2 } },
	{ MODKEY,                       XK_g,      togglegaps,     {0} },
	{ MODKEY|ShiftMask,             XK_g,      defaultgaps,    {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	/* media keys (wpctl = PipeWire, brightnessctl = laptop backlight) */
	{ 0, XF86XK_AudioRaiseVolume,  spawn, SHCMD("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+") },
	{ 0, XF86XK_AudioLowerVolume,  spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
	{ 0, XF86XK_AudioMute,         spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },
	{ 0, XF86XK_MonBrightnessUp,   spawn, SHCMD("brightnessctl set 5%+") },
	{ 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 5%-") },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* mouse buttons */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[1]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
