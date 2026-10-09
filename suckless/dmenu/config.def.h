/* dmenu configuration — compiled in by Nix (see suckless.nix). Colours: colors.h (from theme.nix). */
#include "colors.h"

static int topbar = 1;                      /* -b: 0 = bottom */
static const char *fonts[] = { "JetBrainsMono Nerd Font:size=11" };
static const char *prompt  = NULL;          /* -p */

/* alpha patch (needs picom) */
static const unsigned int baralpha    = 0xd0;
static const unsigned int borderalpha = OPAQUE;
static const unsigned int alphas[][3] = {
	/*               fg      bg        border     */
	[SchemeNorm] = { OPAQUE, baralpha, borderalpha },
	[SchemeSel]  = { OPAQUE, OPAQUE,   borderalpha },
};

static const char *colors[SchemeLast][2] = {
	/*               fg        bg         */
	[SchemeNorm] = { col_fg,   col_bg     },
	[SchemeSel]  = { col_bg,   col_accent },
	[SchemeOut]  = { col_bg,   col_urgent },
};

/* -l: number of lines in vertical list (0 = horizontal) */
static unsigned int lines = 0;

/* characters that delimit words when deleting words */
static const char worddelimiters[] = " ";
