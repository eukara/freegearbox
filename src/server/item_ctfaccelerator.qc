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

/*QUAKED item_ctfaccelerator (0 0.8 0.8) (-16 -16 0) (16 16 36) x x CTFITEM_RANDOM
# OVERVIEW
CTF Double Damage Powerup

# KEYS
- "team_no" : Team

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_accelerator.mdl"
*/

class item_ctfaccelerator:OP4CTFItem
{
	void item_ctfaccelerator(void);

	virtual void Spawned(void);
};

void
item_ctfaccelerator::item_ctfaccelerator(void)
{

}

void
item_ctfaccelerator::Spawned(void)
{
	m_iItemID = ITEM_CTF_DEATH;
	m_strScoreIcon = "score_ctfaccel";
	m_vecScoreColor = [1,0,0];
	model = "models/w_accelerator.mdl";
	super::Spawned();
}