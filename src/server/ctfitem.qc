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

class OP4CTFItem:NSRenderableEntity
{
public:
	void OP4CTFItem(void);

	virtual void Respawn(void);
	virtual void Touch(entity);
	nonvirtual bool CanPlayerGrabPowerup(entity);
	virtual void SpawnKey(string, string);

private:
	int m_iItemID;
	float m_iTeamID;
	string m_strScoreIcon;
	vector m_vecScoreColor;
};

void
OP4CTFItem::OP4CTFItem(void)
{
	m_iItemID = 0i;
	m_strScoreIcon = __NULL__;
	m_iTeamID = 0;
	m_vecScoreColor = [1,1,1];
}

void
OP4CTFItem::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize([-16, -16, 0], [16, 16, 72]);
	DropToFloor();
}

void
OP4CTFItem::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "goal_no":
		m_iTeamID = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
OP4CTFItem::Touch(entity toucherEntity)
{
	player pl = (player)toucherEntity;

	if (!m_iItemID)
		return;

	if (!(toucherEntity.flags & FL_CLIENT))
		return;

	if (CanPlayerGrabPowerup(toucherEntity) == false)
		return;

	pl.g_items |= m_iItemID; /* add to inventory */
	
	forceinfokey(pl, "*icon2", m_strScoreIcon);
	forceinfokey(pl, "*icon2_r", ftos(m_vecScoreColor[0]));
	forceinfokey(pl, "*icon2_g", ftos(m_vecScoreColor[1]));
	forceinfokey(pl, "*icon2_b", ftos(m_vecScoreColor[2]));
	Destroy();
}

bool
OP4CTFItem::CanPlayerGrabPowerup(entity playerEntity)
{
	player pl = (player)playerEntity;

	if (pl.g_items & ITEM_CTF_JUMPPACK)
		return false;
	if (pl.g_items & ITEM_CTF_SHIELD)
		return false;
	if (pl.g_items & ITEM_CTF_HEALTH)
		return false;
	if (pl.g_items & ITEM_CTF_DEATH)
		return false;
	if (pl.g_items & ITEM_CTF_BACKPACK)
		return false;

	return true;
}