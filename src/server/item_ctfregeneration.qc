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

/*QUAKED item_ctfregeneration (0 0.8 0.8) (-16 -16 0) (16 16 36) x x CTFITEM_RANDOM
# OVERVIEW
CTF Health-Regen Powerup

# KEYS
- "team_no" : Team

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)
*/

class item_ctfregeneration:OP4CTFItem
{
	void item_ctfregeneration(void);

	virtual void Spawned(void);
};

void
item_ctfregeneration::item_ctfregeneration(void)
{

}

void
item_ctfregeneration::Spawned(void)
{
	m_iItemID = ITEM_CTF_HEALTH;
	m_strScoreIcon = "score_ctfregen";
	m_vecScoreColor = [0, 1, 0];
	model = "models/w_health.mdl";
	super::Spawned();
}