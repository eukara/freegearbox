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

/*QUAKED item_ctfportablehev (0 0.8 0.8) (-16 -16 0) (16 16 36) x x CTFITEM_RANDOM
# OVERVIEW
CTF HEV Charger Powerup

# KEYS
- "team_no" : Team

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_porthev.mdl"
*/

class item_ctfportablehev:OP4CTFItem
{
	void item_ctfportablehev(void);

	virtual void Spawned(void);
};

void
item_ctfportablehev::item_ctfportablehev(void)
{

}

void
item_ctfportablehev::Spawned(void)
{
	m_iItemID = ITEM_CTF_SHIELD;
	model = "models/w_porthev.mdl";
	super::Spawned();

}