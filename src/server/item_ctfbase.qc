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

/*QUAKED item_ctfbase (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
CTF Capture-Point/Goal

# KEYS
- "model" : Model path for this item
- "skin" : Skin to use
- "goal_no" : Team
- "goal_min" : Minimum Bounding Box
- "goal_max" : Maximum Bounding Box

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/civ_stand.mdl"
*/

class item_ctfbase:OP4CTFItem
{
	void item_ctfbase(void);

	virtual void Respawn(void);
};

void
item_ctfbase::item_ctfbase(void)
{

}

void
item_ctfbase::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize([-16, -16, 0], [16, 16, 72]);
	DropToFloor();
	botinfo = BOTINFO_TEAM_GOALCAPTURE;
}