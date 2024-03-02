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

/*QUAKED item_ctfflag (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
CTF Flag/Goal-Item

# KEYS
- "model" : Model path for this item
- "skin" : Skin to use
- "goal_no" : Team
- "goal_min" : Minimum Bounding Box
- "goal_max" : Maximum Bounding Box

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/flag.mdl"
*/

class item_ctfflag:OP4CTFItem
{
	entity m_eActivator;

	void item_ctfflag(void);

	virtual void Respawn(void);
	virtual void Touch(entity);

	nonvirtual void FlagTaken(void);
	nonvirtual void FlagDrop(NSClientPlayer);
	nonvirtual void FlagReturns(void);
	nonvirtual void _AfterSpawn(void);
};

void
item_ctfflag::item_ctfflag(void)
{
	m_eActivator = __NULL__;
}

void
item_ctfflag::_AfterSpawn(void)
{
	classname = strcat("info_ctfflag_", ftos(m_iTeamID));
}

void
item_ctfflag::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize([-16, -16, 0], [16, 16, 72]);
	SetSolid(SOLID_TRIGGER);
	DropToFloor();
	SetFrame(4);
	
	botinfo = BOTINFO_TEAM_GOALITEM;

	forceinfokey(world, strcat("ctfflag_", ftos(m_iTeamID)), ftos(CTFFLAG_IDLE));
	m_eActivator = __NULL__;
	team = m_iTeamID;
	ScheduleThink(_AfterSpawn, 0.0f);
}

void
item_ctfflag::Touch(entity eToucher)
{
	player pl = (player)eToucher;

	if (!(eToucher.flags & FL_CLIENT))
		return;
	if (eToucher.team == 0)
		return;
	if (eToucher.team == m_iTeamID) {
		if (m_eActivator == __NULL__) { /* only on flags that haven't been dropped */
			if (pl.g_items & ITEM_GOALITEM) {
				OP4CTFRules rule = (OP4CTFRules)g_grMode;
				rule.CaptureFlag((NSClientPlayer)pl);
			}
			return;
		} else {
			/* return the flag, give 1 point */
			FlagReturns();
			pl.score += 1;
			return;
		}
	}

	m_eActivator = pl;
	pl.g_items |= ITEM_GOALITEM;
	pl.flags |= FL_GOALITEM;
	forceinfokey(pl, "*icon1", "score_flag");

	if (eToucher.team == 1) {
		forceinfokey(pl, "*icon1_r", "0");
		forceinfokey(pl, "*icon1_g", "1");
		forceinfokey(pl, "*icon1_b", "0");
	} else {
		forceinfokey(pl, "*icon1_r", "1");
		forceinfokey(pl, "*icon1_g", "1");
		forceinfokey(pl, "*icon1_b", "0");
	}

	pl.flagmodel = GetModelindex();
	pl.flagskin = GetSkin();
	pl.score += 1;
	FlagTaken();
}

void
item_ctfflag::FlagTaken(void)
{
	if (m_iTeamID == 1)
		StartSoundDef("op4ctf_bm.flag_taken", CHAN_ITEM, true);
	else
		StartSoundDef("op4ctf_op4.flag_taken", CHAN_ITEM, true);

	forceinfokey(world, strcat("ctfflag_", ftos(m_iTeamID)), ftos(CTFFLAG_TAKEN));
	Disappear();
}

void
item_ctfflag::FlagDrop(NSClientPlayer pp)
{
	player pl = (player)pp;

	/* make it available again, put it exactly where we died */
	Respawn();
	SetOrigin(pl.origin);
	DropToFloor();
	SetFrame(0);

	/* untag it from the player */
	pl.g_items &= ~ITEM_GOALITEM;
	pl.flagmodel = 0;
	m_eActivator = pp; /* to mark that who this was dropped by */
	forceinfokey(world, strcat("ctfflag_", ftos(m_iTeamID)), ftos(CTFFlAG_MISSING));
	forceinfokey(pl, "*icon1", "");

	/* return after N secs */
	ScheduleThink(FlagReturns, 30.0f);
}

void
item_ctfflag::FlagReturns(void)
{
	Respawn();

/*
	for (entity e = world; (e = find(e, ::classname, "player")); ) {
		if (e.team == m_iTeamUses)
			env_message_single(e, m_returnTeam);
		else if (e.team == m_iTeamOwner)
			env_message_single(e, m_returnOwner);
	}
*/
}