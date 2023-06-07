/*
 * Copyright (c) 2023 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*QUAKED info_ctfdetect (0 0.8 0.8) (-8 -8 -8) (8 8 8)
# OVERVIEW
CTF Map Parameters

When detected, will enable Capture The Flag on the map that it's on.

# KEYS
- "basedefenddist" : Base Defend Distance, default is "30"
- "defendcarriertime" : Defend Carrier Time, default is "192"
- "captureassisttime" : Capture Assist Time, default is "10"
- "poweruprespawntime" : Powerup Respawn Time, default is "30"
- "score_icon_namebm" : Non-Flag Black Mesa icon, default is "item_ctfscorebm"
- "score_icon_nameof" : Non-Flag Opposing Force icon, default is "item_ctfscoreof"
- "map_score_max" : Maximum Map Team Score, default is "0"

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)
*/

class info_ctfdetect
{
	void info_ctfdetect(void);
};
info_ctfdetect g_ctf;

void
info_ctfdetect::info_ctfdetect(void)
{
	g_ctf = this;
}